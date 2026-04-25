import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                  color: AppColors.primaryBlue,
                ),
                onPressed: widget.onOcrPressed,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBackground : Colors.grey[100],
                    borderRadius: BorderRadius.circular(AppDimens.inputRadius),
                  ),
                  child: TextField(
                    controller: widget.controller,
                    style: GoogleFonts.inter(color: textColor),
                    decoration: InputDecoration(
                      hintText: l10n.typeMessage,
                      hintStyle: GoogleFonts.inter(color: secondaryTextColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
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
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: AppDimens.animationDuration,
                curve: AppDimens.animationCurve,
                decoration: BoxDecoration(
                  color: widget.isLoading 
                      ? AppColors.primaryBlue.withValues(alpha: 0.5)
                      : _hasText 
                          ? AppColors.primaryBlue 
                          : AppColors.primaryBlue.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  boxShadow: _hasText && !widget.isLoading
                      ? [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: widget.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
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
            ],
          ),
        ],
      ),
    );
  }
}