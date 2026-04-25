import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../config/app_config.dart';

class HomeInputBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSend;

  const HomeInputBar({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  State<HomeInputBar> createState() => _HomeInputBarState();
}

class _HomeInputBarState extends State<HomeInputBar> {
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

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimens.inputRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              style: GoogleFonts.inter(color: textColor),
              decoration: InputDecoration(
                hintText: l10n.askMeAnything,
                hintStyle: GoogleFonts.inter(color: textColor.withValues(alpha: 0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  widget.onSend(value);
                  widget.controller.clear();
                }
              },
            ),
          ),
          AnimatedContainer(
            duration: AppDimens.animationDuration,
            curve: AppDimens.animationCurve,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _hasText 
                  ? AppColors.primaryBlue 
                  : AppColors.primaryBlue.withValues(alpha: 0.5),
              shape: BoxShape.circle,
              boxShadow: _hasText
                  ? [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
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
    );
  }
}