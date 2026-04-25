import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
            color: AppColors.primaryBlue,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.3),
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
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(20),
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
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 14 * fontSize,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Echo',
                    style: GoogleFonts.inter(
                      fontSize: 12 * fontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
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
              padding: const EdgeInsets.fromLTRB(12, 6, 8, 10),
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
                  const SizedBox(width: 8),
                  StreamBuilder<String?>(
                    stream: _ttsService.speakingIdStream,
                    builder: (context, snapshot) {
                      final speakingId = snapshot.data;
                      final showStop = speakingId == message.id;
                      return GestureDetector(
                        onTap: onSpeak,
                        child: AnimatedContainer(
                          duration: AppDimens.animationDuration,
                          curve: AppDimens.animationCurve,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isTtsPreparing 
                                ? AppColors.primaryBlue.withValues(alpha: 0.1)
                                : showStop 
                                    ? Colors.red.withValues(alpha: 0.1)
                                    : AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: isTtsPreparing
                              ? SizedBox(
                                  width: 16 * fontSize,
                                  height: 16 * fontSize,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryBlue,
                                  ),
                                )
                              : Icon(
                                  showStop ? Icons.stop_rounded : Icons.volume_up_rounded,
                                  size: 18 * fontSize,
                                  color: showStop ? Colors.red : AppColors.primaryBlue,
                                ),
                        ),
                      );
                    },
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
