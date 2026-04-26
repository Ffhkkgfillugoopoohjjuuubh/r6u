import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../l10n/app_localizations.dart';
import '../config/app_config.dart';

class ChatInputWidget extends StatefulWidget {
  final Function(String) onSend;
  final VoidCallback onOcrPressed;
  final bool isLoading;
  final TextEditingController controller;
  final Function(String)? onTextChanged;

  const ChatInputWidget({
    super.key,
    required this.onSend,
    required this.onOcrPressed,
    required this.isLoading,
    required this.controller,
    this.onTextChanged,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final backgroundColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimens.inputRadius),
        border: Border.all(
          color: isDark 
              ? AppColors.darkTextSecondary.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.add_circle_outline,
                  color: AppColors.primaryPurple,
                ),
                onPressed: widget.onOcrPressed,
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  style: GoogleFonts.inter(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Message Echo',
                    hintStyle: GoogleFonts.inter(color: secondaryTextColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onChanged: (value) {
                    widget.onTextChanged?.call(value);
                  },
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      widget.onSend(value);
                      widget.controller.clear();
                    }
                  },
                ),
              ),
              AnimatedContainer(
                duration: AppDimens.animationDuration,
                curve: AppDimens.animationCurve,
                child: widget.isLoading
                    ? Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                        ),
                      )
                    : AnimatedOpacity(
                        opacity: _hasText ? 1.0 : 0.5,
                        duration: AppDimens.animationDuration,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _hasText 
                                ? AppColors.primaryPurple 
                                : AppColors.primaryPurple.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                            boxShadow: _hasText
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryPurple.withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
                            onPressed: _hasText
                                ? () {
                                    final text = widget.controller.text.trim();
                                    if (text.isNotEmpty) {
                                      widget.onSend(text);
                                      widget.controller.clear();
                                    }
                                  }
                                : null,
                          ),
                        ),
                      ).animate().fadeIn(duration: 200.ms),
              ),
            ],
          ),
        ],
      ),
    );
  }
}