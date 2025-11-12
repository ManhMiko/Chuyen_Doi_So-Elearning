import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/progress_model.dart';
import '../config/app_config.dart';

class ProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user progress for a course
  Future<ProgressModel?> getCourseProgress({
    required String userId,
    required String courseId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(AppConfig.progressCollection)
          .where('userId', isEqualTo: userId)
          .where('courseId', isEqualTo: courseId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return ProgressModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get progress: $e');
    }
  }

  // Create initial progress
  Future<ProgressModel> createProgress({
    required String userId,
    required String courseId,
  }) async {
    try {
      final progress = ProgressModel(
        id: '',
        userId: userId,
        courseId: courseId,
        enrolledAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection(AppConfig.progressCollection)
          .add(progress.toFirestore());

      return ProgressModel(
        id: docRef.id,
        userId: userId,
        courseId: courseId,
        enrolledAt: progress.enrolledAt,
      );
    } catch (e) {
      throw Exception('Failed to create progress: $e');
    }
  }

  // Update lesson progress
  Future<void> updateLessonProgress({
    required String userId,
    required String courseId,
    required String lessonId,
    required double progress,
    int? videoPosition,
    bool? isCompleted,
  }) async {
    try {
      // Get or create progress document
      var progressDoc = await getCourseProgress(
        userId: userId,
        courseId: courseId,
      );

      if (progressDoc == null) {
        progressDoc = await createProgress(
          userId: userId,
          courseId: courseId,
        );
      }

      // Update lesson progress
      final lessonProgress = LessonProgress(
        lessonId: lessonId,
        progress: progress,
        isCompleted: isCompleted ?? progress >= 100,
        lastAccessedAt: DateTime.now(),
        videoPosition: videoPosition ?? 0,
        timeSpent: progressDoc.lessonProgress[lessonId]?.timeSpent ?? 0,
      );

      final updatedLessonProgress = Map<String, LessonProgress>.from(
        progressDoc.lessonProgress,
      );
      updatedLessonProgress[lessonId] = lessonProgress;

      // Calculate overall progress
      final totalLessons = updatedLessonProgress.length;
      final completedLessons = updatedLessonProgress.values
          .where((lp) => lp.isCompleted)
          .length;
      final overallProgress = totalLessons > 0
          ? (completedLessons / totalLessons * 100)
          : 0.0;

      // Update Firestore
      final lessonProgressMap = <String, dynamic>{};
      updatedLessonProgress.forEach((key, value) {
        lessonProgressMap[key] = value.toMap();
      });

      await _firestore
          .collection(AppConfig.progressCollection)
          .doc(progressDoc.id)
          .update({
        'lessonProgress': lessonProgressMap,
        'overallProgress': overallProgress,
        'lastAccessedAt': FieldValue.serverTimestamp(),
        if (lessonProgress.isCompleted)
          'completedLessons': FieldValue.arrayUnion([lessonId]),
      });

      // Check if course is completed
      if (overallProgress >= 100) {
        await _markCourseCompleted(
          userId: userId,
          courseId: courseId,
          progressId: progressDoc.id,
        );
      }
    } catch (e) {
      throw Exception('Failed to update lesson progress: $e');
    }
  }

  // Mark course as completed
  Future<void> _markCourseCompleted({
    required String userId,
    required String courseId,
    required String progressId,
  }) async {
    try {
      final batch = _firestore.batch();

      // Update progress
      final progressRef = _firestore
          .collection(AppConfig.progressCollection)
          .doc(progressId);
      batch.update(progressRef, {
        'completedAt': FieldValue.serverTimestamp(),
      });

      // Update user
      final userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'completedCourses': FieldValue.arrayUnion([courseId]),
        'totalPoints': FieldValue.increment(100), // Bonus points for completion
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark course completed: $e');
    }
  }

  // Get all user progress
  Future<List<ProgressModel>> getUserProgress(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConfig.progressCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('lastAccessedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ProgressModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user progress: $e');
    }
  }

  // Get learning statistics
  Future<Map<String, dynamic>> getLearningStatistics(String userId) async {
    try {
      final progressList = await getUserProgress(userId);
      
      final totalCourses = progressList.length;
      final completedCourses = progressList
          .where((p) => p.completedAt != null)
          .length;
      final inProgressCourses = totalCourses - completedCourses;
      final totalTimeSpent = progressList
          .map((p) => p.totalTimeSpent)
          .fold(0, (sum, time) => sum + time);
      final averageProgress = totalCourses > 0
          ? progressList.map((p) => p.overallProgress).reduce((a, b) => a + b) / totalCourses
          : 0.0;

      // Get user data for points and streak
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();

      return {
        'totalCourses': totalCourses,
        'completedCourses': completedCourses,
        'inProgressCourses': inProgressCourses,
        'totalTimeSpent': totalTimeSpent,
        'averageProgress': averageProgress.round(),
        'totalPoints': userData?['totalPoints'] ?? 0,
        'streak': userData?['streak'] ?? 0,
      };
    } catch (e) {
      throw Exception('Failed to get learning statistics: $e');
    }
  }

  // Update learning streak
  Future<void> updateStreak(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      
      // Check last activity date
      final progressList = await getUserProgress(userId);
      if (progressList.isEmpty) return;

      final lastActivity = progressList
          .map((p) => p.lastAccessedAt)
          .where((date) => date != null)
          .map((date) => date!)
          .reduce((a, b) => a.isAfter(b) ? a : b);

      final now = DateTime.now();
      final daysDifference = now.difference(lastActivity).inDays;

      int newStreak = userData?['streak'] ?? 0;

      if (daysDifference == 0) {
        // Same day, no change
        return;
      } else if (daysDifference == 1) {
        // Consecutive day, increment streak
        newStreak++;
      } else {
        // Streak broken, reset to 1
        newStreak = 1;
      }

      await _firestore.collection('users').doc(userId).update({
        'streak': newStreak,
      });
    } catch (e) {
      throw Exception('Failed to update streak: $e');
    }
  }
}
