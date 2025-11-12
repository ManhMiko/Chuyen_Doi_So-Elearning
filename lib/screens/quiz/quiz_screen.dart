import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/quiz_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme_config.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String? quizId;
  final String? lessonId;

  const QuizScreen({
    super.key,
    this.quizId,
    this.lessonId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    
    if (widget.quizId != null) {
      await quizProvider.loadQuiz(widget.quizId!);
    }

    if (quizProvider.currentQuiz != null) {
      _remainingSeconds = quizProvider.currentQuiz!.timeLimit * 60;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        
        final quizProvider = Provider.of<QuizProvider>(context, listen: false);
        quizProvider.incrementTimeSpent();
      } else {
        _submitQuiz();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _nextQuestion() {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    if (_currentQuestionIndex < quizProvider.currentQuiz!.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  Future<void> _submitQuiz() async {
    _timer?.cancel();
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    final success = await quizProvider.submitQuiz(authProvider.currentUser!.id);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const QuizResultScreen(),
        ),
      );
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final quiz = quizProvider.currentQuiz;

    if (quiz == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final question = quiz.questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / quiz.questions.length;

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thoát bài kiểm tra?'),
            content: const Text('Tiến trình của bạn sẽ không được lưu.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Thoát'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(quiz.title),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _remainingSeconds < 300
                        ? ThemeConfig.errorColor.withOpacity(0.1)
                        : ThemeConfig.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 20,
                        color: _remainingSeconds < 300
                            ? ThemeConfig.errorColor
                            : ThemeConfig.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(_remainingSeconds),
                        style: ThemeConfig.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _remainingSeconds < 300
                              ? ThemeConfig.errorColor
                              : ThemeConfig.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                ThemeConfig.primaryColor,
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Number
                    Text(
                      'Câu ${_currentQuestionIndex + 1}/${quiz.questions.length}',
                      style: ThemeConfig.bodyLarge.copyWith(
                        color: ThemeConfig.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Question
                    Text(
                      question.question,
                      style: ThemeConfig.headingSmall,
                    ),

                    const SizedBox(height: 24),

                    // Options
                    ...question.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final isSelected = quizProvider.currentAnswers[question.id] == index;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            quizProvider.selectAnswer(question.id, index);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? ThemeConfig.primaryColor.withOpacity(0.1)
                                  : ThemeConfig.surfaceColor,
                              border: Border.all(
                                color: isSelected
                                    ? ThemeConfig.primaryColor
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? ThemeConfig.primaryColor
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? ThemeConfig.primaryColor
                                          : Colors.grey[400]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index), // A, B, C, D
                                      style: ThemeConfig.bodyMedium.copyWith(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: ThemeConfig.bodyMedium.copyWith(
                                      color: isSelected
                                          ? ThemeConfig.primaryColor
                                          : ThemeConfig.textPrimaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeConfig.surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentQuestionIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousQuestion,
                        child: const Text('Câu trước'),
                      ),
                    ),
                  if (_currentQuestionIndex > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentQuestionIndex < quiz.questions.length - 1
                          ? _nextQuestion
                          : _submitQuiz,
                      child: Text(
                        _currentQuestionIndex < quiz.questions.length - 1
                            ? 'Câu tiếp'
                            : 'Nộp bài',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
