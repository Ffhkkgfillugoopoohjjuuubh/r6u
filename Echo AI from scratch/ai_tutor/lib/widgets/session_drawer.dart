import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../config/app_config.dart';
import '../models/chat_session.dart';

class SessionDrawer extends StatefulWidget {
  final VoidCallback? onNewChat;
  final VoidCallback? onHomePressed;
  final VoidCallback? onSettingsPressed;
  final Function(ChatSession)? onSessionSelected;
  final Function(String)? onSessionDeleted;
  final Function(ChatSession)? onSessionRename;
  final List<ChatSession> sessions;
  final ChatSession? currentSession;

  const SessionDrawer({
    super.key,
    this.onNewChat,
    this.onHomePressed,
    this.onSettingsPressed,
    this.onSessionSelected,
    this.onSessionDeleted,
    this.onSessionRename,
    this.sessions = const [],
    this.currentSession,
  });

  @override
  State<SessionDrawer> createState() => _SessionDrawerState();
}

class _SessionDrawerState extends State<SessionDrawer> {
  bool _chatHistoryExpanded = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final backgroundColor = isDark 
        ? AppColors.darkBackground.withValues(alpha: 0.95)
        : AppColors.lightBackground.withValues(alpha: 0.95);
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx > 0) {
          Navigator.pop(context);
        }
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 300,
          color: backgroundColor,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryBlue,
                        AppColors.primaryBlue.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.appName,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Personal Learning Assistant',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: widget.onNewChat,
                      icon: const Icon(Icons.add, size: 20),
                      label: Text(
                        l10n.newChat,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                _buildExpandableSection(
                  title: l10n.chatHistory,
                  icon: Icons.history,
                  isExpanded: _chatHistoryExpanded,
                  onToggle: () {
                    setState(() => _chatHistoryExpanded = !_chatHistoryExpanded);
                  },
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  surfaceColor: surfaceColor,
                  l10n: l10n,
                  children: [
                    if (widget.sessions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            l10n.noChatsYet,
                            style: GoogleFonts.inter(
                              color: secondaryTextColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ...widget.sessions.asMap().entries.map((entry) {
                        final session = entry.value;
                        final isSelected = session.id == widget.currentSession?.id;
                        return _buildSessionTile(
                          session: session,
                          isSelected: isSelected,
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          surfaceColor: surfaceColor,
                          l10n: l10n,
                          onTap: () {
                            widget.onSessionSelected?.call(session);
                            Navigator.pop(context);
                          },
                          onDelete: () {
                            widget.onSessionDeleted?.call(session.id);
                          },
                          onRename: () {
                            widget.onSessionRename?.call(session);
                          },
                        )
                            .animate()
                            .fadeIn(delay: (150 + entry.key * 50).ms, duration: 200.ms)
                            .slideX(begin: 0.1);
                      }),
                  ],
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: secondaryTextColor.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.settings, color: textColor, size: 22),
                        title: Text(
                          l10n.settings,
                          style: GoogleFonts.inter(color: textColor),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          widget.onSettingsPressed?.call();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.info_outline, color: textColor, size: 22),
                        title: Text(
                          l10n.about,
                          style: GoogleFonts.inter(color: textColor),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Color textColor,
    required Color secondaryTextColor,
    required Color surfaceColor,
    required AppLocalizations l10n,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryBlue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: AppDimens.animationDuration,
                  child: Icon(
                    Icons.chevron_right,
                    color: secondaryTextColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Column(children: children),
          secondChild: const SizedBox.shrink(),
          crossFadeState: isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: AppDimens.animationDuration,
        ),
      ],
    );
  }

  Widget _buildSessionTile({
    required ChatSession session,
    required bool isSelected,
    required Color textColor,
    required Color secondaryTextColor,
    required Color surfaceColor,
    required AppLocalizations l10n,
    required VoidCallback onTap,
    required VoidCallback onDelete,
    required VoidCallback onRename,
  }) {
    final dateFormat = DateFormat('d MMM y');
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.chipRadius),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Icon(
          Icons.chat_bubble_outline,
          color: isSelected ? AppColors.primaryBlue : secondaryTextColor,
          size: 20,
        ),
        title: Text(
          session.name,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: secondaryTextColor, size: 18),
          onSelected: (value) {
            if (value == 'rename') {
              onRename();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'rename',
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 18),
                  const SizedBox(width: 8),
                  Text(l10n.renameChat, style: GoogleFonts.inter(fontSize: 14)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 18, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(l10n.deleteChat, style: GoogleFonts.inter(fontSize: 14, color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}