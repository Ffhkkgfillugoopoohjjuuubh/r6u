import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_config.dart';
import '../providers/chat_provider.dart';
import '../models/chat_session.dart';
import '../widgets/session_drawer.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onPromptSelected(String prompt) {
    ref.read(chatProvider.notifier).clearCurrentSession();
    Future.delayed(const Duration(milliseconds: 100), () {
      ref.read(chatProvider.notifier).sendMessage(prompt);
    });
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
  }

  void _startNewChat() {
    ref.read(chatProvider.notifier).clearCurrentSession();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      drawer: SessionDrawer(
        onNewChat: _startNewChat,
        onSettingsPressed: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.menu, color: textColor),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  Text(
                    'Echo AI',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: textColor),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'E',
                            style: GoogleFonts.inter(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .scale(begin: const Offset(0.8, 0.8)),
                      const SizedBox(height: 24),
                      Text(
                        'Echo AI',
                        style: GoogleFonts.inter(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 600.ms),
                      const SizedBox(height: 8),
                      Text(
                        'How can I help you today',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: secondaryTextColor,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 600.ms),
                      const SizedBox(height: 32),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: _suggestedPrompts.asMap().entries.map((entry) {
                          return ActionChip(
                            label: Text(entry.value, style: GoogleFonts.inter(fontSize: 14)),
                            backgroundColor: Colors.transparent,
                            side: BorderSide(color: AppColors.primaryPurple),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onPressed: () => _onPromptSelected(entry.value),
                          )
                              .animate()
                              .fadeIn(delay: (600 + entry.key * 100).ms, duration: 400.ms);
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<String> _suggestedPrompts = [
    'Explain quantum physics simply',
    'Help me solve a math problem',
    'Translate text to Hindi',
    'Test my knowledge on history',
  ];
}