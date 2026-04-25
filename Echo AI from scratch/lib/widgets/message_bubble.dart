import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final double fontSize;
  final String voiceLanguage;
  final VoidCallback onSpeak;

  const MessageBubble({
    super.key,
    required this.message,
    required this.fontSize,
    required this.voiceLanguage,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final timeFormat = DateFormat('HH:mm');
    final formattedTime = timeFormat.format(message.timestamp);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF2196F3) : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: TextStyle(
                fontSize: 14 * fontSize,
                color: isUser ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 10 * fontSize,
                    color: isUser ? Colors.white70 : Colors.black54,
                  ),
                ),
                if (!isUser) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onSpeak,
                    child: Icon(
                      Icons.volume_up,
                      size: 16 * fontSize,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}