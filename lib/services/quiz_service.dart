import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';
import '../config/app_config.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get quiz by ID
  Future<QuizModel?> getQuizById(String quizId) async {
    try {
      final doc = await _firestore
          .collection(AppConfig.quizzesCollection)
          .doc(quizId)
          .get();

      if (doc.exists) {
        return QuizModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get quiz: $e');
    }
  }

  // Get quizzes by course
  Future<List<QuizModel>> getQuizzesByCourse(String courseId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConfig.quizzesCollection)
          .where('courseId', isEqualTo: courseId)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => QuizModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get quizzes: $e');
    }
  }

  // Get quiz by lesson
  Future<QuizModel?> getQuizByLesson(String lessonId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConfig.quizzesCollection)
          .where('lessonId', isEqualTo: lessonId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return QuizModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get quiz: $e');
    }
  }

  // Submit quiz attempt
  Future<QuizAttempt> submitQuizAttempt({
    required String userId,
    required String quizId,
    required Map<String, int> answers,
    required int timeSpent,
  }) async {
    try {
      // Get quiz to calculate score
      final quiz = await getQuizById(quizId);
      if (quiz == null) {
        throw Exception('Quiz not found');
      }

      int correctAnswers = 0;
      int totalPoints = 0;

      for (var question in quiz.questions) {
        if (answers[question.id] == question.correctAnswer) {
          correctAnswers++;
          totalPoints += question.points;
        }
      }

      final score = (correctAnswers / quiz.questions.length * 100).round();
      final isPassed = score >= quiz.passingScore;

      final attempt = QuizAttempt(
        id: '',
        userId: userId,
        quizId: quizId,
        answers: answers,
        score: score,
        totalQuestions: quiz.questions.length,
        correctAnswers: correctAnswers,
        startedAt: DateTime.now().subtract(Duration(seconds: timeSpent)),
        completedAt: DateTime.now(),
        timeSpent: timeSpent,
        isPassed: isPassed,
      );

      // Save attempt to Firestore
      final docRef = await _firestore
          .collection('quiz_attempts')
          .add(attempt.toFirestore());

      // Update user progress
      if (isPassed) {
        await _firestore.collection('users').doc(userId).update({
          'totalPoints': FieldValue.increment(totalPoints),
        });
      }

      return QuizAttempt(
        id: docRef.id,
        userId: userId,
        quizId: quizId,
        answers: answers,
        score: score,
        totalQuestions: quiz.questions.length,
        correctAnswers: correctAnswers,
        startedAt: attempt.startedAt,
        completedAt: attempt.completedAt,
        timeSpent: timeSpent,
        isPassed: isPassed,
      );
    } catch (e) {
      throw Exception('Failed to submit quiz: $e');
    }
  }

  // Get user's quiz attempts
  Future<List<QuizAttempt>> getUserQuizAttempts({
    required String userId,
    String? quizId,
  }) async {
    try {
      Query query = _firestore
          .collection('quiz_attempts')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true);

      if (quizId != null) {
        query = query.where('quizId', isEqualTo: quizId);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => QuizAttempt.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get quiz attempts: $e');
    }
  }

  // Get best attempt for a quiz
  Future<QuizAttempt?> getBestAttempt({
    required String userId,
    required String quizId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('quiz_attempts')
          .where('userId', isEqualTo: userId)
          .where('quizId', isEqualTo: quizId)
          .orderBy('score', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return QuizAttempt.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get best attempt: $e');
    }
  }

  // Create mini quiz
  Future<QuizModel> createMiniQuiz({
    required String courseId,
    required String title,
    required List<QuizQuestion> questions,
  }) async {
    try {
      final quiz = QuizModel(
        id: '',
        title: title,
        description: 'Mini quiz luyện tập nhanh',
        courseId: courseId,
        questions: questions,
        timeLimit: 10, // 10 minutes for mini quiz
        passingScore: 60,
        difficulty: 'easy',
        isAutoGenerated: false,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection(AppConfig.quizzesCollection)
          .add(quiz.toFirestore());

      return QuizModel(
        id: docRef.id,
        title: quiz.title,
        description: quiz.description,
        courseId: quiz.courseId,
        questions: quiz.questions,
        timeLimit: quiz.timeLimit,
        passingScore: quiz.passingScore,
        difficulty: quiz.difficulty,
        isAutoGenerated: quiz.isAutoGenerated,
        createdAt: quiz.createdAt,
      );
    } catch (e) {
      throw Exception('Failed to create mini quiz: $e');
    }
  }

  // Get quiz statistics
  Future<Map<String, dynamic>> getQuizStatistics({
    required String userId,
    required String quizId,
  }) async {
    try {
      final attempts = await getUserQuizAttempts(
        userId: userId,
        quizId: quizId,
      );

      if (attempts.isEmpty) {
        return {
          'totalAttempts': 0,
          'averageScore': 0,
          'bestScore': 0,
          'lastAttempt': null,
        };
      }

      final totalAttempts = attempts.length;
      final averageScore = attempts.map((a) => a.score).reduce((a, b) => a + b) / totalAttempts;
      final bestScore = attempts.map((a) => a.score).reduce((a, b) => a > b ? a : b);
      final lastAttempt = attempts.first;

      return {
        'totalAttempts': totalAttempts,
        'averageScore': averageScore.round(),
        'bestScore': bestScore,
        'lastAttempt': lastAttempt,
      };
    } catch (e) {
      throw Exception('Failed to get quiz statistics: $e');
    }
  }
}
