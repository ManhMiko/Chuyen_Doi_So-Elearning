import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressModel {
  final String id;
  final String userId;
  final String courseId;
  final Map<String, LessonProgress> lessonProgress;
  final double overallProgress; // 0-100
  final DateTime enrolledAt;
  final DateTime? lastAccessedAt;
  final DateTime? completedAt;
  final int totalTimeSpent; // in minutes
  final List<String> completedLessons;
  final List<String> completedQuizzes;
  final int totalPoints;

  ProgressModel({
    required this.id,
    required this.userId,
    required this.courseId,
    this.lessonProgress = const {},
    this.overallProgress = 0.0,
    required this.enrolledAt,
    this.lastAccessedAt,
    this.completedAt,
    this.totalTimeSpent = 0,
    this.completedLessons = const [],
    this.completedQuizzes = const [],
    this.totalPoints = 0,
  });

  factory ProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    Map<String, LessonProgress> lessonProgressMap = {};
    if (data['lessonProgress'] != null) {
      (data['lessonProgress'] as Map<String, dynamic>).forEach((key, value) {
        lessonProgressMap[key] = LessonProgress.fromMap(value as Map<String, dynamic>);
      });
    }
    
    return ProgressModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      courseId: data['courseId'] ?? '',
      lessonProgress: lessonProgressMap,
      overallProgress: (data['overallProgress'] ?? 0).toDouble(),
      enrolledAt: (data['enrolledAt'] as Timestamp).toDate(),
      lastAccessedAt: data['lastAccessedAt'] != null 
          ? (data['lastAccessedAt'] as Timestamp).toDate() 
          : null,
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      totalTimeSpent: data['totalTimeSpent'] ?? 0,
      completedLessons: List<String>.from(data['completedLessons'] ?? []),
      completedQuizzes: List<String>.from(data['completedQuizzes'] ?? []),
      totalPoints: data['totalPoints'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> lessonProgressMap = {};
    lessonProgress.forEach((key, value) {
      lessonProgressMap[key] = value.toMap();
    });
    
    return {
      'userId': userId,
      'courseId': courseId,
      'lessonProgress': lessonProgressMap,
      'overallProgress': overallProgress,
      'enrolledAt': Timestamp.fromDate(enrolledAt),
      'lastAccessedAt': lastAccessedAt != null ? Timestamp.fromDate(lastAccessedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'totalTimeSpent': totalTimeSpent,
      'completedLessons': completedLessons,
      'completedQuizzes': completedQuizzes,
      'totalPoints': totalPoints,
    };
  }
}

class LessonProgress {
  final String lessonId;
  final bool isCompleted;
  final double progress; // 0-100
  final int timeSpent; // in seconds
  final DateTime? lastAccessedAt;
  final int videoPosition; // in seconds for video lessons

  LessonProgress({
    required this.lessonId,
    this.isCompleted = false,
    this.progress = 0.0,
    this.timeSpent = 0,
    this.lastAccessedAt,
    this.videoPosition = 0,
  });

  factory LessonProgress.fromMap(Map<String, dynamic> map) {
    return LessonProgress(
      lessonId: map['lessonId'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      progress: (map['progress'] ?? 0).toDouble(),
      timeSpent: map['timeSpent'] ?? 0,
      lastAccessedAt: map['lastAccessedAt'] != null 
          ? (map['lastAccessedAt'] as Timestamp).toDate() 
          : null,
      videoPosition: map['videoPosition'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'isCompleted': isCompleted,
      'progress': progress,
      'timeSpent': timeSpent,
      'lastAccessedAt': lastAccessedAt != null ? Timestamp.fromDate(lastAccessedAt!) : null,
      'videoPosition': videoPosition,
    };
  }
}
