import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../config/app_config.dart';
import '../models/chat_session.dart';
import '../models/project_model.dart';
import '../providers/chat_provider.dart';
import '../providers/projects_provider.dart';

class SessionDrawer extends ConsumerStatefulWidget {
  final VoidCallback? onNewChat;
  final VoidCallback? onHomePressed;
  final VoidCallback? onSettingsPressed;
  final Function(ChatSession)? onSessionSelected;
  final Function(String)? onSessionDeleted;
  final Function(ChatSession)? onSessionRename;
  final Function(ChatSession, String)? onSessionMoveToProject;
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
    this.onSessionMoveToProject,
    this.sessions = const [],
    this.currentSession,
  });

  @override
  ConsumerState<SessionDrawer> createState() => _SessionDrawerState();
}

class _SessionDrawerState extends ConsumerState<SessionDrawer> {
  final Set<String> _expandedProjects = {};
  bool _starredExpanded = true;
  bool _projectsExpanded = true;
  bool _recentsExpanded = true;

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

    final sessions = widget.sessions;
    final starredSessions = sessions.where((s) => s.isStarred).toList();
    final recentsSessions = sessions.where((s) => !s.isStarred).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final projectsState = ref.watch(projectsProvider);

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
                        AppColors.primaryPurple,
                        AppColors.primaryPurple.withValues(alpha: 0.8),
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
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                'E',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Echo AI',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onNewChat?.call();
                      },
                      icon: const Icon(Icons.add, size: 20),
                      label: Text(
                        l10n.newChat,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      if (starredSessions.isNotEmpty)
                        _buildSection(
                          title: 'Starred',
                          icon: Icons.star,
                          isExpanded: _starredExpanded,
                          onToggle: () => setState(() => _starredExpanded = !_starredExpanded),
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          l10n: l10n,
                          children: starredSessions.map((session) => _buildSessionTile(
                            session: session,
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                            l10n: l10n,
                          )).toList(),
                        ),
                      _buildSection(
                        title: 'Projects',
                        icon: Icons.folder,
                        isExpanded: _projectsExpanded,
                        onToggle: () => setState(() => _projectsExpanded = !_projectsExpanded),
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        l10n: l10n,
                        trailing: IconButton(
                          icon: Icon(Icons.add, size: 18, color: secondaryTextColor),
                          onPressed: () => _showCreateProjectDialog(context),
                        ),
                        children: projectsState.projects.map((project) => _buildProjectTile(
                          project: project,
                          sessions: sessions,
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          l10n: l10n,
                        )).toList(),
                      ),
                      _buildSection(
                        title: 'Recents',
                        icon: Icons.history,
                        isExpanded: _recentsExpanded,
                        onToggle: () => setState(() => _recentsExpanded = !_recentsExpanded),
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        l10n: l10n,
                        children: recentsSessions.isEmpty
                            ? [Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  l10n.noChatsYet,
                                  style: GoogleFonts.inter(
                                    color: secondaryTextColor,
                                    fontSize: 14,
                                  ),
                                ),
                              )]
                            : recentsSessions.map((session) => _buildSessionTile(
                                session: session,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                l10n: l10n,
                              )).toList(),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: secondaryTextColor.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: ListTile(
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
                ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Color textColor,
    required Color secondaryTextColor,
    required AppLocalizations l10n,
    Widget? trailing,
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
                Icon(icon, color: AppColors.primaryPurple, size: 20),
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
                if (trailing != null) trailing,
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
    required Color textColor,
    required Color secondaryTextColor,
    required AppLocalizations l10n,
  }) {
    final dateFormat = DateFormat('d MMM y');
    final isSelected = session.id == widget.currentSession?.id;
    final displayName = session.name.length > 35 
        ? '${session.name.substring(0, 35)}...' 
        : session.name;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryPurple.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.chipRadius),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Icon(
          Icons.chat_bubble_outline,
          color: isSelected ? AppColors.primaryPurple : secondaryTextColor,
          size: 20,
        ),
        title: Text(
          displayName,
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
        onTap: () {
          ref.read(chatProvider.notifier).selectSession(session);
          Navigator.pop(context);
        },
        onLongPress: () => _showSessionContextMenu(context, session, l10n),
      ),
    );
  }

  Widget _buildProjectTile({
    required ProjectModel project,
    required List<ChatSession> sessions,
    required Color textColor,
    required Color secondaryTextColor,
    required AppLocalizations l10n,
  }) {
    final isExpanded = _expandedProjects.contains(project.id);
    final projectSessions = sessions.where((s) => project.sessionIds.contains(s.id)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() {
            if (_expandedProjects.contains(project.id)) {
              _expandedProjects.remove(project.id);
            } else {
              _expandedProjects.add(project.id);
            }
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isExpanded ? Icons.folder_open : Icons.folder,
                  color: AppColors.primaryPurple,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    project.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
        if (isExpanded && projectSessions.isNotEmpty)
          ...projectSessions.map((session) => _buildSessionTile(
            session: session,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            l10n: l10n,
          )),
      ],
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    final controller = TextEditingController();
    final appL10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Project'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Project name',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appL10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(projectsProvider.notifier).createProject(name);
              }
              Navigator.pop(context);
            },
            child: Text(appL10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showSessionContextMenu(BuildContext context, ChatSession session, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(session.isStarred ? Icons.star_border : Icons.star),
              title: Text(session.isStarred ? 'Unstar' : 'Star'),
              onTap: () {
                Navigator.pop(context);
                ref.read(chatProvider.notifier).toggleStar(session.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.renameChat),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, session);
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_move),
              title: Text('Move to Project'),
              onTap: () {
                Navigator.pop(context);
                _showMoveToProjectDialog(context, session);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(l10n.deleteChat, style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                ref.read(chatProvider.notifier).deleteSession(session.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, ChatSession session) {
    final controller = TextEditingController(text: session.name);
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.renameChat),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                ref.read(chatProvider.notifier).renameSession(session.id, newName);
              }
              Navigator.pop(context);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showMoveToProjectDialog(BuildContext context, ChatSession session) {
    final projects = ref.read(projectsProvider).projects;
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move to Project'),
        content: projects.isEmpty
            ? Text('No projects available. Create one first.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: projects.map((project) => ListTile(
                  title: Text(project.name),
                  onTap: () {
                    ref.read(projectsProvider.notifier).addSessionToProject(project.id, session.id);
                    Navigator.pop(context);
                  },
                )).toList(),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}