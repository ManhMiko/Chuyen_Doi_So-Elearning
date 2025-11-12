import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_provider.dart';
import '../../config/theme_config.dart';
import '../../models/quiz_model.dart';

class MiniQuizScreen extends StatefulWidget {
  const MiniQuizScreen({super.key});

  @override
  State<MiniQuizScreen> createState() => _MiniQuizScreenState();
}

class _MiniQuizScreenState extends State<MiniQuizScreen> {
  final TextEditingController _topicController = TextEditingController();
  String _selectedDifficulty = 'medium';
  int _questionCount = 5;
  List<QuizQuestion>? _generatedQuestions;
  bool _isGenerating = false;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generateQuiz() async {
    if (_topicController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập chủ đề'),
          backgroundColor: ThemeConfig.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    
    try {
      final questions = await aiProvider.generateQuiz(
        topic: _topicController.text.trim(),
        questionCount: _questionCount,
        difficulty: _selectedDifficulty,
      );

      setState(() {
        _generatedQuestions = questions;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tạo quiz: $e'),
            backgroundColor: ThemeConfig.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Mini Quiz'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: ThemeConfig.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'AI sẽ tạo quiz tự động',
                    style: ThemeConfig.headingSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nhập chủ đề và để AI tạo câu hỏi cho bạn',
                    style: ThemeConfig.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Topic Input
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Chủ đề',
                hintText: 'VD: Lập trình Flutter, Tiếng Anh giao tiếp...',
                prefixIcon: Icon(Icons.topic),
              ),
            ),

            const SizedBox(height: 16),

            // Question Count
            Text(
              'Số câu hỏi: $_questionCount',
              style: ThemeConfig.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Slider(
              value: _questionCount.toDouble(),
              min: 3,
              max: 10,
              divisions: 7,
              label: '$_questionCount câu',
              onChanged: (value) {
                setState(() {
                  _questionCount = value.toInt();
                });
              },
            ),

            const SizedBox(height: 16),

            // Difficulty
            Text(
              'Độ khó',
              style: ThemeConfig.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Dễ'),
                  selected: _selectedDifficulty == 'easy',
                  onSelected: (selected) {
                    setState(() {
                      _selectedDifficulty = 'easy';
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Trung bình'),
                  selected: _selectedDifficulty == 'medium',
                  onSelected: (selected) {
                    setState(() {
                      _selectedDifficulty = 'medium';
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Khó'),
                  selected: _selectedDifficulty == 'hard',
                  onSelected: (selected) {
                    setState(() {
                      _selectedDifficulty = 'hard';
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Generate Button
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateQuiz,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isGenerating ? 'Đang tạo...' : 'Tạo Quiz'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            // Generated Questions
            if (_generatedQuestions != null) ...[
              const SizedBox(height: 32),
              Text(
                'Quiz đã tạo',
                style: ThemeConfig.headingSmall,
              ),
              const SizedBox(height: 16),
              ..._generatedQuestions!.asMap().entries.map((entry) {
                final index = entry.key;
                final question = entry.value;
                return _buildQuestionCard(question, index + 1);
              }),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Start quiz with generated questions
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng đang phát triển'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Bắt đầu làm bài'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestion question, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Câu $index',
            style: ThemeConfig.bodySmall.copyWith(
              color: ThemeConfig.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.question,
            style: ThemeConfig.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...question.options.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            final option = entry.value;
            final isCorrect = optionIndex == question.correctAnswer;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCorrect
                          ? ThemeConfig.successColor.withOpacity(0.1)
                          : Colors.transparent,
                      border: Border.all(
                        color: isCorrect
                            ? ThemeConfig.successColor
                            : Colors.grey[400]!,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + optionIndex),
                        style: ThemeConfig.bodySmall.copyWith(
                          color: isCorrect
                              ? ThemeConfig.successColor
                              : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      option,
                      style: ThemeConfig.bodyMedium.copyWith(
                        color: isCorrect
                            ? ThemeConfig.successColor
                            : ThemeConfig.textPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
