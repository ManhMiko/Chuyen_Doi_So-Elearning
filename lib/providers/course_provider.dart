import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../services/course_service.dart';

class CourseProvider with ChangeNotifier {
  final CourseService _courseService = CourseService();

  List<CourseModel> _courses = [];
  List<CourseModel> _enrolledCourses = [];
  List<CourseModel> _popularCourses = [];
  List<CourseModel> _recommendedCourses = [];
  CourseModel? _selectedCourse;
  bool _isLoading = false;
  String? _errorMessage;

  List<CourseModel> get courses => _courses;
  List<CourseModel> get enrolledCourses => _enrolledCourses;
  List<CourseModel> get popularCourses => _popularCourses;
  List<CourseModel> get recommendedCourses => _recommendedCourses;
  CourseModel? get selectedCourse => _selectedCourse;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCourses() async {
    try {
      _isLoading = true;
      notifyListeners();

      _courses = await _courseService.getAllCourses();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadPopularCourses() async {
    try {
      _popularCourses = await _courseService.getPopularCourses();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadRecommendedCourses(String userId) async {
    try {
      _recommendedCourses = await _courseService.getRecommendedCourses(
        userId: userId,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadEnrolledCourses(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _enrolledCourses = await _courseService.getUserEnrolledCourses(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> selectCourse(String courseId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _selectedCourse = await _courseService.getCourseById(courseId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<List<CourseModel>> searchCourses(String query) async {
    try {
      return await _courseService.searchCourses(query);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<List<CourseModel>> getCoursesByCategory(String category) async {
    try {
      return await _courseService.getCoursesByCategory(category);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<bool> enrollCourse({
    required String userId,
    required String courseId,
  }) async {
    try {
      await _courseService.enrollCourse(
        userId: userId,
        courseId: courseId,
      );
      
      // Reload enrolled courses
      await loadEnrolledCourses(userId);
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> isUserEnrolled({
    required String userId,
    required String courseId,
  }) async {
    return await _courseService.isUserEnrolled(
      userId: userId,
      courseId: courseId,
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSelectedCourse() {
    _selectedCourse = null;
    notifyListeners();
  }
}
