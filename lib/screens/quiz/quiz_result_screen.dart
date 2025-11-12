import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../config/theme_config.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final attempt = quizProvider.currentAttempt;
    final quiz = quizProvider.currentQuiz;

    if (attempt == null || quiz == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Không tìm thấy kết quả')),
      );
    }

    final isPassed = attempt.isPassed;
    final scorePercentage = attempt.score;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Result Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPassed
                    ? ThemeConfig.successColor.withOpacity(0.1)
                    : ThemeConfig.errorColor.withOpacity(0.1),
              ),
              child: Icon(
                isPassed ? Icons.check_circle : Icons.cancel,
                size: 80,
                color: isPassed ? ThemeConfig.successColor : ThemeConfig.errorColor,
              ),
            ),

            const SizedBox(height: 24),

            // Result Text
            Text(
              isPassed ? 'Chúc mừng!' : 'Chưa đạt',
              style: ThemeConfig.headingLarge.copyWith(
                color: isPassed ? ThemeConfig.successColor : ThemeConfig.errorColor,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              isPassed
                  ? 'Bạn đã vượt qua bài kiểm tra'
                  : 'Hãy cố gắng thêm lần sau',
              style: ThemeConfig.bodyLarge.copyWith(
                color: ThemeConfig.textSecondaryColor,
              ),
            ),

            const SizedBox(height: 32),

            // Score Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: ThemeConfig.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    'Điểm số',
                    style: ThemeConfig.bodyLarge.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$scorePercentage%',
                    style: ThemeConfig.headingLarge.copyWith(
                      color: Colors.white,
                      fontSize: 48,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Statistics
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Câu đúng',
                    '${attempt.correctAnswers}/${attempt.totalQuestions}',
                    Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Thời gian',
                    '${attempt.timeSpent ~/ 60}:${(attempt.timeSpent % 60).toString().padLeft(2, '0')}',
                    Icons.timer_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Review Answers
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeConfig.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chi tiết câu trả lời',
                    style: ThemeConfig.headingSmall,
                  ),
                  const SizedBox(height: 16),
                  ...quiz.questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value;
                    final userAnswer = attempt.answers[question.id];
                    final isCorrect = userAnswer == question.correctAnswer;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.cancel,
                                color: isCorrect
                                    ? ThemeConfig.successColor
                                    : ThemeConfig.errorColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Câu ${index + 1}: ${question.question}',
                                  style: ThemeConfig.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (!isCorrect) ...[
                            Text(
                              'Đáp án đúng: ${question.options[question.correctAnswer]}',
                              style: ThemeConfig.bodySmall.copyWith(
                                color: ThemeConfig.successColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            'Giải thích: ${question.explanation}',
                            style: ThemeConfig.bodySmall.copyWith(
                              color: ThemeConfig.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Quay lại'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      quizProvider.resetQuiz();
                      Navigator.pop(context);
                      // Reload quiz
                    },
                    child: const Text('Làm lại'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: ThemeConfig.primaryColor, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: ThemeConfig.headingSmall.copyWith(
              color: ThemeConfig.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: ThemeConfig.bodySmall,
          ),
        ],
      ),
    );
  }
}
