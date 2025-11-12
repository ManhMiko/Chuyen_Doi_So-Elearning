import 'package:flutter/foundation.dart';
import '../models/quiz_model.dart';
import '../services/quiz_service.dart';

class QuizProvider with ChangeNotifier {
  final QuizService _quizService = QuizService();

  QuizModel? _currentQuiz;
  QuizAttempt? _currentAttempt;
  List<QuizAttempt> _attemptHistory = [];
  Map<String, int> _currentAnswers = {};
  bool _isLoading = false;
  String? _errorMessage;
  int _timeSpent = 0;

  QuizModel? get currentQuiz => _currentQuiz;
  QuizAttempt? get currentAttempt => _currentAttempt;
  List<QuizAttempt> get attemptHistory => _attemptHistory;
  Map<String, int> get currentAnswers => _currentAnswers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get timeSpent => _timeSpent;

  Future<void> loadQuiz(String quizId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _currentQuiz = await _quizService.getQuizById(quizId);
      _currentAnswers.clear();
      _timeSpent = 0;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadQuizzesByCourse(String courseId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _quizService.getQuizzesByCourse(courseId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void selectAnswer(String questionId, int optionIndex) {
    _currentAnswers[questionId] = optionIndex;
    notifyListeners();
  }

  void incrementTimeSpent() {
    _timeSpent++;
    notifyListeners();
  }

  Future<bool> submitQuiz(String userId) async {
    try {
      if (_currentQuiz == null) {
        throw Exception('No quiz loaded');
      }

      _isLoading = true;
      notifyListeners();

      _currentAttempt = await _quizService.submitQuizAttempt(
        userId: userId,
        quizId: _currentQuiz!.id,
        answers: _currentAnswers,
        timeSpent: _timeSpent,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadAttemptHistory({
    required String userId,
    String? quizId,
  }) async {
    try {
      _attemptHistory = await _quizService.getUserQuizAttempts(
        userId: userId,
        quizId: quizId,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getQuizStatistics({
    required String userId,
    required String quizId,
  }) async {
    try {
      return await _quizService.getQuizStatistics(
        userId: userId,
        quizId: quizId,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return {};
    }
  }

  void resetQuiz() {
    _currentAnswers.clear();
    _timeSpent = 0;
    _currentAttempt = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
