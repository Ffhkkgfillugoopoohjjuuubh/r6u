import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../config/app_config.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';
import '../models/chat_session.dart';
import '../widgets/session_drawer.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';
import 'main_scaffold.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _inputController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _onPromptSelected(String prompt) {
    _inputController.text = prompt;
    _startNewChat(prompt);
  }

  void _startNewChat([String? initialMessage]) {
    ref.read(chatProvider.notifier).clearCurrentSession();
    if (initialMessage != null && initialMessage.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 100), () {
        ref.read(chatProvider.notifier).sendMessage(initialMessage);
      });
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      drawer: SessionDrawer(
        onNewChat: () {
          Navigator.pop(context);
          _startNewChat();
        },
        onHomePressed: () {},
        onSettingsPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const SettingsScreen(),
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                      .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                  child: child,
                );
              },
            ),
          );
        },
      ),
      body: SafeArea(
        child: chatState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.menu, color: textColor),
                          onPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
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
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => const SettingsScreen(),
                                transitionDuration: const Duration(milliseconds: 300),
                                transitionsBuilder: (_, animation, __, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                                        .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildWelcomeContent(isDark, textColor, secondaryTextColor, l10n),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildWelcomeContent(bool isDark, Color textColor, Color secondaryTextColor, AppLocalizations l10n) {
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryPurple.withValues(alpha: 0.3),
                    AppColors.primaryPurple.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
            const SizedBox(height: 32),
            Text(
              'Hello, I am Echo',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideY(begin: 0.2),
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
            const SizedBox(height: 48),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _suggestedPrompts.asMap().entries.map((entry) {
                return ActionChip(
                  label: Text(
                    entry.value,
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  backgroundColor: backgroundColor,
                  side: BorderSide(
                    color: AppColors.primaryPurple.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.chipRadius),
                  ),
                  onPressed: () => _onPromptSelected(entry.value),
                )
                    .animate()
                    .fadeIn(delay: (600 + entry.key * 100).ms, duration: 400.ms)
                    .slideX(begin: 0.1);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  static const List<String> _suggestedPrompts = [
    'Explain a concept to me',
    'Help me with math',
    'Translate something',
    'Quiz me on a topic',
  ];
}