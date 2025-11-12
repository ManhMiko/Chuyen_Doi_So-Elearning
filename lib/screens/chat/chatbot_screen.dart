import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme_config.dart';
import '../../config/ai_config.dart';
import '../../models/chat_model.dart';
import 'widgets/message_bubble.dart';
import 'mini_quiz_screen.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    if (aiProvider.messages.isEmpty) {
      // Add welcome message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (aiProvider.messages.isEmpty) {
          aiProvider.messages.add(_createWelcomeMessage());
        }
      });
    }
  }

  ChatMessage _createWelcomeMessage() {
    return ChatMessage(
      id: 'welcome',
      userId: 'bot',
      message: AIConfig.chatbotWelcomeMessage,
      sender: 'bot',
      timestamp: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final aiProvider = Provider.of<AIProvider>(context, listen: false);

    _messageController.clear();
    
    await aiProvider.sendMessage(
      message,
      userId: authProvider.currentUser?.id,
    );

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = Provider.of<AIProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: ThemeConfig.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AIConfig.chatbotName,
                  style: ThemeConfig.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Trợ lý AI',
                  style: ThemeConfig.bodySmall.copyWith(
                    color: ThemeConfig.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                aiProvider.clearMessages();
                _initializeChat();
              } else if (value == 'mini_quiz') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MiniQuizScreen(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mini_quiz',
                child: Row(
                  children: [
                    Icon(Icons.quiz),
                    SizedBox(width: 8),
                    Text('Tạo Mini Quiz'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 8),
                    Text('Xóa lịch sử'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Actions
          Container(
            padding: const EdgeInsets.all(12),
            color: ThemeConfig.backgroundColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickAction(
                    'Giải thích khái niệm',
                    Icons.lightbulb_outline,
                    () {
                      _messageController.text = 'Giải thích cho tôi về ';
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildQuickAction(
                    'Tạo quiz',
                    Icons.quiz,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MiniQuizScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildQuickAction(
                    'Gợi ý học tập',
                    Icons.tips_and_updates,
                    () {
                      _messageController.text = 'Gợi ý cho tôi cách học hiệu quả về ';
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildQuickAction(
                    'Tóm tắt nội dung',
                    Icons.summarize,
                    () {
                      _messageController.text = 'Tóm tắt nội dung về ';
                    },
                  ),
                ],
              ),
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: aiProvider.messages.length,
              itemBuilder: (context, index) {
                final message = aiProvider.messages[index];
                return MessageBubble(
                  message: message.message,
                  isUser: message.sender == 'user',
                  timestamp: message.timestamp,
                );
              },
            ),
          ),

          // Loading Indicator
          if (aiProvider.isLoading)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.grey[600]!,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Đang suy nghĩ...',
                          style: ThemeConfig.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Input Field
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
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Nhập câu hỏi của bạn...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: ThemeConfig.backgroundColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: ThemeConfig.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: aiProvider.isLoading ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: ThemeConfig.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: ThemeConfig.primaryColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: ThemeConfig.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
