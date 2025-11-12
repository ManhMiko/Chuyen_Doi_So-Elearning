import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';
import '../models/quiz_model.dart';
import '../services/ai_service.dart';

class AIProvider with ChangeNotifier {
  final AIService _aiService = AIService();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentCourseContext;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentCourseContext => _currentCourseContext;

  void setCourseContext(String? context) {
    _currentCourseContext = context;
    notifyListeners();
  }

  Future<void> sendMessage(String message, {String? userId}) async {
    try {
      // Add user message
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId ?? 'user',
        message: message,
        sender: 'user',
        timestamp: DateTime.now(),
        courseContext: _currentCourseContext,
      );
      
      _messages.add(userMessage);
      _isLoading = true;
      notifyListeners();

      // Get AI response
      final response = await _aiService.sendMessage(
        message: message,
        courseContext: _currentCourseContext,
      );

      // Add bot message
      final botMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'bot',
        message: response,
        sender: 'bot',
        timestamp: DateTime.now(),
        courseContext: _currentCourseContext,
      );
      
      _messages.add(botMessage);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      
      // Add error message as bot response
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'bot',
        message: '😔 Xin lỗi, EduBot hiện đang bận và không thể trả lời câu hỏi của bạn.\n\n'
            'Vui lòng thử lại sau vài phút hoặc kiểm tra kết nối internet của bạn.\n\n'
            '💡 Mẹo: Bạn có thể thử đặt câu hỏi khác hoặc làm mới trang!',
        sender: 'bot',
        timestamp: DateTime.now(),
        courseContext: _currentCourseContext,
      );
      
      _messages.add(errorMessage);
      notifyListeners();
    }
  }

  Future<List<QuizQuestion>> generateQuiz({
    required String topic,
    int questionCount = 5,
    String difficulty = 'medium',
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final questions = await _aiService.generateQuiz(
        topic: topic,
        questionCount: questionCount,
        difficulty: difficulty,
      );

      _isLoading = false;
      notifyListeners();
      return questions;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<String> explainConcept(String concept, {String? context}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final explanation = await _aiService.explainConcept(
        concept,
        context: context ?? _currentCourseContext,
      );

      _isLoading = false;
      notifyListeners();
      return explanation;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return 'Không thể giải thích khái niệm này.';
    }
  }

  Future<List<String>> getStudySuggestions({
    required String courseTitle,
    required List<String> completedTopics,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final suggestions = await _aiService.getStudySuggestions(
        courseTitle: courseTitle,
        completedTopics: completedTopics,
      );

      _isLoading = false;
      notifyListeners();
      return suggestions;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<String> summarizeContent(String content) async {
    try {
      _isLoading = true;
      notifyListeners();

      final summary = await _aiService.summarizeContent(content);

      _isLoading = false;
      notifyListeners();
      return summary;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return 'Không thể tóm tắt nội dung này.';
    }
  }

  void clearMessages() {
    _messages.clear();
    _aiService.clearHistory();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void loadHistory() {
    _messages = _aiService.getHistory();
    notifyListeners();
  }
}
