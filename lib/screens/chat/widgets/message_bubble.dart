import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    // Check if this is an error message
    final isErrorMessage = !isUser && message.contains('Xin lỗi, EduBot');
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: isErrorMessage ? null : ThemeConfig.primaryGradient,
                color: isErrorMessage ? ThemeConfig.warningColor : null,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isErrorMessage ? Icons.error_outline : Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: isUser ? ThemeConfig.primaryGradient : null,
                    color: isUser 
                        ? null 
                        : isErrorMessage 
                            ? ThemeConfig.warningColor.withOpacity(0.1)
                            : Colors.grey[200],
                    border: isErrorMessage 
                        ? Border.all(color: ThemeConfig.warningColor, width: 1.5)
                        : null,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                  ),
                  child: Text(
                    message,
                    style: ThemeConfig.bodyMedium.copyWith(
                      color: isUser 
                          ? Colors.white 
                          : isErrorMessage
                              ? ThemeConfig.warningColor.withOpacity(0.9)
                              : ThemeConfig.textPrimaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(timestamp),
                  style: ThemeConfig.bodySmall.copyWith(
                    color: ThemeConfig.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: ThemeConfig.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: ThemeConfig.primaryColor,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
