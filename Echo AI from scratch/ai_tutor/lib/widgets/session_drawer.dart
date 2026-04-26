import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../config/app_config.dart';
import '../models/chat_session.dart';
import '../providers/chat_provider.dart';
import '../services/storage_service.dart';

class SessionDrawer extends ConsumerStatefulWidget {
  final VoidCallback? onNewChat;
  final VoidCallback? onSettingsPressed;

  const SessionDrawer({
    super.key,
    this.onNewChat,
    this.onSettingsPressed,
  });

  @override
  ConsumerState<SessionDrawer> createState() => _SessionDrawerState();
}

class _SessionDrawerState extends ConsumerState<SessionDrawer> {
  List<ChatSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final storage = StorageService();
    final sessionsData = await storage.loadAllSessions();
    setState(() {
      _sessions = sessionsData.map((s) => ChatSession(
        id: s.id,
        name: s.name,
        createdAt: s.createdAt,
        updatedAt: s.lastModified,
        isStarred: s.isStarred,
      )).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final drawerBg = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF0F0F5);
    final textColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final subColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final dividerColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;

    return SizedBox(
      width: 280,
      child: Drawer(
        backgroundColor: drawerBg,
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryPurple,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              'E',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Echo AI',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Text(
                              'Your AI Learning Partner',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: subColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.add_circle_outline, color: AppColors.primaryPurple),
                title: Text(
                  'New Chat',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onNewChat?.call();
                },
              ),
              Divider(color: dividerColor),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'RECENT CHATS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: subColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _sessions.isEmpty
                        ? Center(
                            child: Text(
                              'No recent chats',
                              style: GoogleFonts.inter(color: subColor),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _sessions.length,
                            itemBuilder: (context, index) {
                              final session = _sessions[index];
                              return _buildSessionTile(session, textColor, subColor);
                            },
                          ),
              ),
              Divider(color: dividerColor),
              ListTile(
                leading: Icon(Icons.settings, color: textColor),
                title: Text(
                  'Settings',
                  style: GoogleFonts.inter(color: textColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onSettingsPressed?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionTile(ChatSession session, Color textColor, Color subColor) {
    final displayName = session.name.length > 30 ? '${session.name.substring(0, 30)}...' : session.name;
    final dateFormat = DateFormat('d MMM');
    final formattedDate = dateFormat.format(session.updatedAt);

    return ListTile(
      leading: Icon(Icons.chat_bubble_outline, color: AppColors.primaryPurple, size: 20),
      title: Text(
        displayName,
        style: GoogleFonts.inter(color: textColor, fontSize: 14),
      ),
      subtitle: Text(
        formattedDate,
        style: GoogleFonts.inter(color: subColor, fontSize: 12),
      ),
      onTap: () {
        ref.read(chatProvider.notifier).selectSession(session);
        Navigator.pop(context);
      },
      onLongPress: () => _showSessionMenu(session),
    );
  }

  void _showSessionMenu(ChatSession session) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(session);
              },
            ),
            ListTile(
              leading: Icon(session.isStarred ? Icons.star_border : Icons.star),
              title: Text(session.isStarred ? 'Star' : 'Unstar'),
              onTap: () {
                Navigator.pop(context);
                ref.read(chatProvider.notifier).toggleStar(session.id);
                _loadSessions();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                ref.read(chatProvider.notifier).deleteSession(session.id);
                _loadSessions();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(ChatSession session) {
    final controller = TextEditingController(text: session.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Chat'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Chat name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                ref.read(chatProvider.notifier).renameSession(session.id, newName);
                _loadSessions();
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}