import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../l10n/app_localizations.dart';
import '../config/app_config.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/ad_provider.dart';
import '../providers/tts_provider.dart';
import '../providers/progressive_text_provider.dart';
import '../services/ocr_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input_widget.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/session_drawer.dart';
import 'settings_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isOcrProcessing = false;
  StreamSubscription<String>? _wordSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
      _setupWordStreamListener();
    });
  }

  void _setupWordStreamListener() {
    final chatNotifier = ref.read(chatProvider.notifier);
    _wordSubscription = chatNotifier.wordStream.listen((word) {
      ref.read(progressiveTextNotifierProvider.notifier).appendWord(word);
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _wordSubscription?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showOcrOptions() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.camera),
              onTap: () async {
                Navigator.pop(context);
                await _handleOcrCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.gallery),
              onTap: () async {
                Navigator.pop(context);
                await _handleOcrGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: Text(l10n.selectImage),
              onTap: () async {
                Navigator.pop(context);
                await _handleOcrFilePicker();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleOcrCamera() async {
    setState(() => _isOcrProcessing = true);
    final ocrService = OcrService();
    final text = await ocrService.extractFromCamera();
    setState(() => _isOcrProcessing = false);
    _processOcrResult(text);
  }

  Future<void> _handleOcrGallery() async {
    setState(() => _isOcrProcessing = true);
    final ocrService = OcrService();
    final text = await ocrService.extractFromGallery();
    setState(() => _isOcrProcessing = false);
    _processOcrResult(text);
  }

  Future<void> _handleOcrFilePicker() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isOcrProcessing = true);
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null || result.files.isEmpty) {
        setState(() => _isOcrProcessing = false);
        return;
      }
      final path = result.files.first.path;
      if (path == null) {
        setState(() => _isOcrProcessing = false);
        return;
      }
      final ocrService = OcrService();
      final text = await ocrService.extractFromPath(path);
      setState(() => _isOcrProcessing = false);
      _processOcrResult(text);
    } catch (e) {
      setState(() => _isOcrProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _processOcrResult(String? text) {
    final l10n = AppLocalizations.of(context)!;
    if (text == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noTextDetected)),
        );
      }
      return;
    }
    if (text == 'NO_TEXT_FOUND') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noTextDetected)),
        );
      }
      return;
    }
    _inputController.text = text;
    _inputController.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
  }

  void _sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    HapticFeedback.lightImpact();
    ref.read(progressiveTextNotifierProvider.notifier).reset();
    _inputController.clear();
    await ref.read(chatProvider.notifier).sendMessage(content);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _showRenameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.renameChat),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.startConversation,
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
                ref.read(chatProvider.notifier).renameSession(
                  ref.read(chatProvider).currentSession!.id,
                  newName,
                );
              }
              Navigator.pop(context);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final settingsState = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: GestureDetector(
          onTap: () {
            if (chatState.currentSession != null) {
              _showRenameDialog(context, chatState.currentSession!.name);
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  chatState.currentSession?.name ?? l10n.echo,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.edit, size: 16, color: textColor.withValues(alpha: 0.5)),
            ],
          ),
        ),
        actions: [
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
      drawer: SessionDrawer(
        sessions: chatState.sessions,
        currentSession: chatState.currentSession,
        onSessionSelected: (session) {
          ref.read(chatProvider.notifier).selectSession(session);
          Navigator.pop(context);
        },
        onSessionDeleted: (id) {
          ref.read(chatProvider.notifier).deleteSession(id);
          Navigator.pop(context);
        },
        onSessionRename: (session) {
          Navigator.pop(context);
          _showRenameDialog(context, session.name);
        },
        onNewChat: () {
          ref.read(chatProvider.notifier).createSession('New Chat');
          Navigator.pop(context);
        },
        onHomePressed: () {
          Navigator.pop(context);
        },
        onSettingsPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
      body: Column(
        children: [
          const BannerAdWidget(adUnitId: 'ca-app-pub-4160048627212561/6528052382'),
          if (chatState.errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chatState.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: chatState.messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'E',
                          style: GoogleFonts.inter(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.askMeAnything,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.hereToHelp,
                          style: GoogleFonts.inter(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chatState.messages.length + (chatState.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == chatState.messages.length && chatState.isTyping) {
                        return _buildThinkingIndicator();
                      }

                      final message = chatState.messages[index];
                      final ttsState = ref.watch(ttsProvider);
                      final progressiveText = ref.watch(progressiveTextNotifierProvider);
                      final isPlaying = ttsState.isPlaying && ttsState.currentMessageId == message.id;
                      final isPreparing = ttsState.isPreparing && ttsState.currentMessageId == message.id;
                      final isLastMessage = index == chatState.messages.length - 1;
                      final isAiMessage = !message.isUser;
                      return MessageBubble(
                        message: message,
                        fontSize: settingsState.fontSize,
                        voiceLanguage: settingsState.voiceLanguage,
                        isTtsPlaying: isPlaying,
                        isTtsPreparing: isPreparing,
                        progressiveText: (isLastMessage && isAiMessage && progressiveText.isNotEmpty) ? progressiveText : null,
                        onSpeak: () {
                          ref.read(chatProvider.notifier).speakMessage(
                                message.content,
                                settingsState.voiceLanguage,
                                message.id,
                                ref,
                              );
                        },
                      )
                          .animate()
                          .fadeIn(duration: 250.ms)
                          .slideY(begin: 0.1);
                    },
                  ),
          ),
          if (_isOcrProcessing)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.extracting,
                    style: GoogleFonts.inter(color: textColor),
                  ),
                ],
              ),
            ),
          const BannerAdWidget(adUnitId: 'ca-app-pub-4160048627212561/5539450520'),
          ChatInputWidget(
            controller: _inputController,
            onSend: _sendMessage,
            onOcrPressed: _showOcrOptions,
            isLoading: chatState.responseStatus == ResponseStatus.loading,
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'E',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryPurple,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.only(right: 6),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryPurple,
                ),
              )
                  .animate(
                    onPlay: (controller) => controller.repeat(),
                  )
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                    duration: 600.ms,
                    delay: (index * 200).ms,
                    curve: Curves.easeInOut,
                  );
            }),
          ),
        ],
      ),
    );
  }
}