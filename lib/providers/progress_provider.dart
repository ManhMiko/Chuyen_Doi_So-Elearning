import 'package:flutter/foundation.dart';
import '../models/progress_model.dart';
import '../services/progress_service.dart';

class ProgressProvider with ChangeNotifier {
  final ProgressService _progressService = ProgressService();

  ProgressModel? _currentProgress;
  List<ProgressModel> _allProgress = [];
  Map<String, dynamic>? _statistics;
  bool _isLoading = false;
  String? _errorMessage;

  ProgressModel? get currentProgress => _currentProgress;
  List<ProgressModel> get allProgress => _allProgress;
  Map<String, dynamic>? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCourseProgress({
    required String userId,
    required String courseId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      _currentProgress = await _progressService.getCourseProgress(
        userId: userId,
        courseId: courseId,
      );

      if (_currentProgress == null) {
        _currentProgress = await _progressService.createProgress(
          userId: userId,
          courseId: courseId,
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateLessonProgress({
    required String userId,
    required String courseId,
    required String lessonId,
    required double progress,
    int? videoPosition,
    bool? isCompleted,
  }) async {
    try {
      await _progressService.updateLessonProgress(
        userId: userId,
        courseId: courseId,
        lessonId: lessonId,
        progress: progress,
        videoPosition: videoPosition,
        isCompleted: isCompleted,
      );

      // Reload progress
      await loadCourseProgress(userId: userId, courseId: courseId);
      
      // Update streak
      await _progressService.updateStreak(userId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadAllProgress(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _allProgress = await _progressService.getUserProgress(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadStatistics(String userId) async {
    try {
      _statistics = await _progressService.getLearningStatistics(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  double getLessonProgress(String lessonId) {
    if (_currentProgress == null) return 0.0;
    return _currentProgress!.lessonProgress[lessonId]?.progress ?? 0.0;
  }

  bool isLessonCompleted(String lessonId) {
    if (_currentProgress == null) return false;
    return _currentProgress!.lessonProgress[lessonId]?.isCompleted ?? false;
  }

  int getVideoPosition(String lessonId) {
    if (_currentProgress == null) return 0;
    return _currentProgress!.lessonProgress[lessonId]?.videoPosition ?? 0;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
