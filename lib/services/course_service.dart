import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import '../config/app_config.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all courses
  Future<List<CourseModel>> getAllCourses({
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConfig.coursesCollection)
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => CourseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get courses: $e');
    }
  }

  // Get course by ID
  Future<CourseModel?> getCourseById(String courseId) async {
    try {
      final doc = await _firestore
          .collection(AppConfig.coursesCollection)
          .doc(courseId)
          .get();

      if (doc.exists) {
        return CourseModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get course: $e');
    }
  }

  // Search courses
  Future<List<CourseModel>> searchCourses(String query) async {
    try {
      final snapshot = await _firestore
          .collection(AppConfig.coursesCollection)
          .where('isPublished', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => CourseModel.fromFirestore(doc))
          .where((course) =>
              course.title.toLowerCase().contains(query.toLowerCase()) ||
              course.description.toLowerCase().contains(query.toLowerCase()) ||
              course.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
          .toList();
    } catch (e) {
      throw Exception('Failed to search courses: $e');
    }
  }

  // Get courses by category
  Future<List<CourseModel>> getCoursesByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(AppConfig.coursesCollection)
          .where('category', isEqualTo: category)
          .where('isPublished', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CourseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get courses by category: $e');
    }
  }

  // Get popular courses
  Future<List<CourseModel>> getPopularCourses({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(AppConfig.coursesCollection)
          .where('isPublished', isEqualTo: true)
          .orderBy('totalStudents', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => CourseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get popular courses: $e');
    }
  }

  // Get recommended courses
  Future<List<CourseModel>> getRecommendedCourses({
    required String userId,
    int limit = 10,
  }) async {
    try {
      // Get user's enrolled courses to find similar ones
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final enrolledCourses = List<String>.from(userDoc.data()?['enrolledCourses'] ?? []);

      if (enrolledCourses.isEmpty) {
        // Return popular courses if no enrollment history
        return getPopularCourses(limit: limit);
      }

      // Get categories from enrolled courses
      final enrolledCourseDocs = await Future.wait(
        enrolledCourses.map((id) => 
          _firestore.collection(AppConfig.coursesCollection).doc(id).get()
        ),
      );

      final categories = enrolledCourseDocs
          .where((doc) => doc.exists)
          .map((doc) => doc.data()?['category'] as String?)
          .where((cat) => cat != null)
          .toSet()
          .toList();

      if (categories.isEmpty) {
        return getPopularCourses(limit: limit);
      }

      // Get courses from similar categories
      final snapshot = await _firestore
          .collection(AppConfig.coursesCollection)
          .where('category', whereIn: categories)
          .where('isPublished', isEqualTo: true)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => CourseModel.fromFirestore(doc))
          .where((course) => !enrolledCourses.contains(course.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get recommended courses: $e');
    }
  }

  // Enroll in course
  Future<void> enrollCourse({
    required String userId,
    required String courseId,
  }) async {
    try {
      final batch = _firestore.batch();

      // Update user's enrolled courses
      final userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'enrolledCourses': FieldValue.arrayUnion([courseId]),
      });

      // Update course's total students
      final courseRef = _firestore.collection(AppConfig.coursesCollection).doc(courseId);
      batch.update(courseRef, {
        'totalStudents': FieldValue.increment(1),
      });

      // Create enrollment record
      final enrollmentRef = _firestore.collection(AppConfig.enrollmentsCollection).doc();
      batch.set(enrollmentRef, {
        'userId': userId,
        'courseId': courseId,
        'enrolledAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to enroll in course: $e');
    }
  }

  // Get user's enrolled courses
  Future<List<CourseModel>> getUserEnrolledCourses(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final enrolledCourses = List<String>.from(userDoc.data()?['enrolledCourses'] ?? []);

      if (enrolledCourses.isEmpty) {
        return [];
      }

      final courseDocs = await Future.wait(
        enrolledCourses.map((id) => 
          _firestore.collection(AppConfig.coursesCollection).doc(id).get()
        ),
      );

      return courseDocs
          .where((doc) => doc.exists)
          .map((doc) => CourseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get enrolled courses: $e');
    }
  }

  // Check if user is enrolled
  Future<bool> isUserEnrolled({
    required String userId,
    required String courseId,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final enrolledCourses = List<String>.from(userDoc.data()?['enrolledCourses'] ?? []);
      return enrolledCourses.contains(courseId);
    } catch (e) {
      return false;
    }
  }
}
