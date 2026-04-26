import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/app_config.dart';
import '../models/chat_message.dart';
import '../services/tts_service.dart';

final _ttsService = TtsService();

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final double fontSize;
  final String voiceLanguage;
  final VoidCallback onSpeak;
  final bool isTtsPlaying;
  final bool isTtsPreparing;
  final String? progressiveText;

  const MessageBubble({
    super.key,
    required this.message,
    required this.fontSize,
    required this.voiceLanguage,
    required this.onSpeak,
    this.isTtsPlaying = false,
    this.isTtsPreparing = false,
    this.progressiveText,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeFormat = DateFormat('HH:mm');
    final formattedTime = timeFormat.format(message.timestamp);

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          padding: const EdgeInsets.all(14),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryPurple,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.content,
                style: GoogleFonts.inter(
                  fontSize: 15 * fontSize,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedTime,
                    style: GoogleFonts.inter(
                      fontSize: 11 * fontSize,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(
            color: isDark 
                ? AppColors.darkTextSecondary.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 10, right: 12),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'E',
                        style: GoogleFonts.inter(
                          fontSize: 12 * fontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Echo',
                    style: GoogleFonts.inter(
                      fontSize: 12 * fontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Text(
                progressiveText ?? message.content,
                style: GoogleFonts.inter(
                  fontSize: 15 * fontSize,
                  color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedTime,
                    style: GoogleFonts.inter(
                      fontSize: 11 * fontSize,
                      color: isDark ? AppColors.darkTextSecondary : Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildIconButton(
                    icon: Icons.copy,
                    size: 18 * fontSize,
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: message.content));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    icon: isTtsPlaying ? Icons.stop : Icons.volume_up,
                    size: 18 * fontSize,
                    isPlaying: isTtsPlaying,
                    isLoading: isTtsPreparing,
                    onTap: onSpeak,
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    icon: Icons.thumb_up_outlined,
                    size: 18 * fontSize,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    icon: Icons.thumb_down_outlined,
                    size: 18 * fontSize,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required double size,
    bool isPlaying = false,
    bool isLoading = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isPlaying 
              ? Colors.red.withValues(alpha: 0.1)
              : AppColors.primaryPurple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: isLoading
            ? SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryPurple,
                ),
              )
            : Icon(
                icon,
                size: size,
                color: isPlaying ? Colors.red : AppColors.primaryPurple,
              ),
      ),
    );
  }
}