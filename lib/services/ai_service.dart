import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import '../config/ai_config.dart';
import '../models/chat_model.dart';
import '../models/quiz_model.dart';

class AIService {
  late final GenerativeModel _model;
  final List<ChatMessage> _conversationHistory = [];

  AIService() {
    _model = GenerativeModel(
      model: AIConfig.geminiModel,
      apiKey: AIConfig.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );
  }

  // Send message to chatbot
  Future<String> sendMessage({
    required String message,
    String? courseContext,
  }) async {
    try {
      // Build context from conversation history
      String context = AIConfig.systemPrompt;
      
      if (courseContext != null) {
        context += '\n\nCourse Context: $courseContext';
      }

      // Add conversation history
      if (_conversationHistory.isNotEmpty) {
        context += '\n\nConversation History:\n';
        for (var msg in _conversationHistory.take(10)) {
          context += '${msg.sender}: ${msg.message}\n';
        }
      }

      // Create prompt
      final prompt = '$context\n\nUser: $message\n\nAssistant:';

      // Generate response
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final botResponse = response.text ?? 'Xin lỗi, tôi không thể trả lời câu hỏi này.';

      // Add to conversation history
      _conversationHistory.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'user',
        message: message,
        sender: 'user',
        timestamp: DateTime.now(),
        courseContext: courseContext,
      ));

      _conversationHistory.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'bot',
        message: botResponse,
        sender: 'bot',
        timestamp: DateTime.now(),
        courseContext: courseContext,
      ));

      return botResponse;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Generate quiz from topic
  Future<List<QuizQuestion>> generateQuiz({
    required String topic,
    int questionCount = 5,
    String difficulty = 'medium',
  }) async {
    try {
      final prompt = AIConfig.quizGenerationPrompt
          .replaceAll('{topic}', topic)
          .replaceAll('{count}', questionCount.toString())
          .replaceAll('{difficulty}', difficulty);

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final responseText = response.text ?? '';
      
      // Parse JSON response
      final jsonStart = responseText.indexOf('{');
      final jsonEnd = responseText.lastIndexOf('}') + 1;
      
      if (jsonStart == -1 || jsonEnd == 0) {
        throw Exception('Invalid response format');
      }

      final jsonString = responseText.substring(jsonStart, jsonEnd);
      final jsonData = json.decode(jsonString);

      final questions = <QuizQuestion>[];
      for (var i = 0; i < (jsonData['questions'] as List).length; i++) {
        final q = jsonData['questions'][i];
        questions.add(QuizQuestion(
          id: 'q_${DateTime.now().millisecondsSinceEpoch}_$i',
          question: q['question'],
          options: List<String>.from(q['options']),
          correctAnswer: q['correctAnswer'],
          explanation: q['explanation'],
          points: 1,
        ));
      }

      return questions;
    } catch (e) {
      throw Exception('Failed to generate quiz: $e');
    }
  }

  // Explain concept
  Future<String> explainConcept(String concept, {String? context}) async {
    try {
      String prompt = 'Hãy giải thích khái niệm "$concept" một cách đơn giản và dễ hiểu.';
      
      if (context != null) {
        prompt += ' Trong ngữ cảnh: $context';
      }

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? 'Không thể giải thích khái niệm này.';
    } catch (e) {
      throw Exception('Failed to explain concept: $e');
    }
  }

  // Get study suggestions
  Future<List<String>> getStudySuggestions({
    required String courseTitle,
    required List<String> completedTopics,
  }) async {
    try {
      final prompt = '''
Dựa trên khóa học "$courseTitle" và các chủ đề đã hoàn thành:
${completedTopics.join(', ')}

Hãy đề xuất 5 gợi ý học tập tiếp theo để người học tiến bộ tốt nhất.
Trả về dưới dạng danh sách, mỗi gợi ý trên một dòng, bắt đầu bằng số thứ tự.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final responseText = response.text ?? '';
      
      // Parse suggestions
      final suggestions = responseText
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim())
          .where((line) => line.isNotEmpty)
          .toList();

      return suggestions;
    } catch (e) {
      throw Exception('Failed to get study suggestions: $e');
    }
  }

  // Summarize lesson content
  Future<String> summarizeContent(String content) async {
    try {
      final prompt = '''
Hãy tóm tắt nội dung sau đây thành các điểm chính, ngắn gọn và dễ hiểu:

$content

Tóm tắt:
''';

      final content_text = [Content.text(prompt)];
      final response = await _model.generateContent(content_text);

      return response.text ?? 'Không thể tóm tắt nội dung này.';
    } catch (e) {
      throw Exception('Failed to summarize content: $e');
    }
  }

  // Clear conversation history
  void clearHistory() {
    _conversationHistory.clear();
  }

  // Get conversation history
  List<ChatMessage> getHistory() {
    return List.from(_conversationHistory);
  }
}
