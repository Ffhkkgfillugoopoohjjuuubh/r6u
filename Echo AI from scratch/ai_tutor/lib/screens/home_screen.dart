import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../config/app_config.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';
import '../models/chat_session.dart';
import '../widgets/session_drawer.dart';
import '../widgets/home_input_bar.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

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
    final themeState = ref.watch(themeProvider);
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
                          l10n.echo,
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
                    child: chatState.sessions.isEmpty
                        ? _buildWelcomeContent(isDark, textColor, secondaryTextColor, l10n)
                        : _buildSessionsList(chatState.sessions, isDark, textColor, secondaryTextColor, l10n),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: HomeInputBar(
                      controller: _inputController,
                      onSend: _startNewChat,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildWelcomeContent(bool isDark, Color textColor, Color secondaryTextColor, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue.withValues(alpha: 0.3),
                    AppColors.primaryBlue.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 64,
                color: AppColors.primaryBlue,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: 32),
            Text(
              l10n.helloImEcho,
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
              l10n.personalAiAssistant,
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
                  backgroundColor: isDark 
                      ? AppColors.darkSurface 
                      : AppColors.lightSurface,
                  side: BorderSide(
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
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
    'Explain quantum computing simply',
    'Help me write a poem about nature',
    'What is machine learning?',
    'Teach me about photosynthesis',
  ];

  Widget _buildSessionsList(List<ChatSession> sessions, bool isDark, Color textColor, Color secondaryTextColor, AppLocalizations l10n) {
    final dateFormat = DateFormat('d MMM y');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppDimens.cardRadius),
            border: Border.all(
              color: AppColors.primaryBlue.withValues(alpha: 0.2),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                color: AppColors.primaryBlue,
                size: 24,
              ),
            ),
            title: Text(
              session.name,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              dateFormat.format(session.updatedAt),
              style: GoogleFonts.inter(
                fontSize: 12,
                color: secondaryTextColor,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: secondaryTextColor,
            ),
            onTap: () {
              ref.read(chatProvider.notifier).selectSession(session);
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const ChatScreen(),
                  transitionDuration: const Duration(milliseconds: 300),
                  transitionsBuilder: (_, animation, __, child) {
                    return SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                          .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
        )
            .animate()
            .fadeIn(delay: (index * 100).ms, duration: 300.ms)
            .slideX(begin: 0.1);
      },
    );
  }
}