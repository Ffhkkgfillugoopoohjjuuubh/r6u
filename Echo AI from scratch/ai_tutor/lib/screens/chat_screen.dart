import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../config/app_config.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/tts_provider.dart';
import '../providers/progressive_text_provider.dart';
import '../services/ocr_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/banner_ad_widget.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isOcrProcessing = false;
  late AnimationController _bounceController;
  int _thinkingIndex = 0;
  Timer? _thinkingTimer;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this)..repeat();
    _thinkingTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (mounted) setState(() => _thinkingIndex = (_thinkingIndex + 1) % 3);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _bounceController.dispose();
    _thinkingTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _showOcrOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Camera'), onTap: () { Navigator.pop(context); _handleOcrCamera(); }),
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Gallery'), onTap: () { Navigator.pop(context); _handleOcrGallery(); }),
            ListTile(leading: const Icon(Icons.folder_open), title: const Text('Select Image'), onTap: () { Navigator.pop(context); _handleOcrFilePicker(); }),
          ],
        ),
      ),
    );
  }

  Future<void> _handleOcrCamera() async {
    setState(() => _isOcrProcessing = true);
    final text = await OcrService().extractFromCamera();
    setState(() => _isOcrProcessing = false);
    _processOcrResult(text);
  }

  Future<void> _handleOcrGallery() async {
    setState(() => _isOcrProcessing = true);
    final text = await OcrService().extractFromGallery();
    setState(() => _isOcrProcessing = false);
    _processOcrResult(text);
  }

  Future<void> _handleOcrFilePicker() async {
    setState(() => _isOcrProcessing = true);
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null || result.files.isEmpty) { setState(() => _isOcrProcessing = false); return; }
      final path = result.files.first.path;
      if (path == null) { setState(() => _isOcrProcessing = false); return; }
      final text = await OcrService().extractFromPath(path);
      setState(() => _isOcrProcessing = false);
      _processOcrResult(text);
    } catch (e) { setState(() => _isOcrProcessing = false); }
  }

  void _processOcrResult(String? text) {
    if (text == null || text == 'NO_TEXT_FOUND') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No text detected')));
      return;
    }
    _inputController.text = text;
    _inputController.selection = TextSelection.fromPosition(TextPosition(offset: text.length));
  }

  void _sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    ref.read(progressiveTextNotifierProvider.notifier).reset();
    _inputController.clear();
    await ref.read(chatProvider.notifier).sendMessage(content);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _showRenameDialog(String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Chat'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(chatProvider.notifier).renameSession(ref.read(chatProvider).currentSession!.id, controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
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
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: GestureDetector(
          onTap: () { if (chatState.currentSession != null) _showRenameDialog(chatState.currentSession!.name); },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(chatState.currentSession?.name ?? 'Echo AI', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: textColor)),
              const SizedBox(width: 4),
              Icon(Icons.edit, size: 16, color: textColor.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const BannerAdWidget(adUnitId: 'ca-app-pub-4160048627212561/6528052382'),
          Expanded(
            child: chatState.messages.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('E', style: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primaryPurple)),
                    const SizedBox(height: 16),
                    Text("Ask me anything!", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 8),
                    Text("I'm here to help you learn", style: GoogleFonts.inter(color: isDark ? Colors.grey : Colors.grey[600])),
                  ]))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chatState.messages.length + (chatState.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == chatState.messages.length && chatState.isTyping) return _buildThinkingBubble();
                      final message = chatState.messages[index];
                      final ttsState = ref.watch(ttsProvider);
                      final progressiveText = ref.watch(progressiveTextNotifierProvider);
                      final isPlaying = ttsState.isPlaying && ttsState.currentMessageId == message.id;
                      final isPreparing = ttsState.isPreparing && ttsState.currentMessageId == message.id;
                      final isLastMessage = index == chatState.messages.length - 1;
                      final isAi = !message.isUser;
                      return MessageBubble(
                        message: message,
                        fontSize: settingsState.fontSize,
                        voiceLanguage: settingsState.voiceLanguage,
                        isTtsPlaying: isPlaying,
                        isTtsPreparing: isPreparing,
                        progressiveText: (isLastMessage && isAi && progressiveText.isNotEmpty) ? progressiveText : null,
                        onSpeak: () => ref.read(chatProvider.notifier).speakMessage(message.content, settingsState.voiceLanguage, message.id, ref),
                      );
                    },
                  ),
          ),
          if (_isOcrProcessing) Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)), const SizedBox(width: 8), Text('Extracting...', style: GoogleFonts.inter(color: textColor)),
          ])),
          const BannerAdWidget(adUnitId: 'ca-app-pub-4160048627212561/5539450520'),
          _buildInputBar(isDark),
        ],
      ),
    );
  }

  Widget _buildThinkingBubble() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(color: AppColors.primaryPurple.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Center(child: Text('E', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primaryPurple)))),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: List.generate(3, (i) => AnimatedBuilder(animation: _bounceController, builder: (context, child) => Transform.translate(
              offset: Offset(0, _getBounceOffset(i)),
              child: Container(margin: const EdgeInsets.only(right: 4), width: 8, height: 8, decoration: BoxDecoration(color: AppColors.primaryPurple, borderRadius: BorderRadius.circular(4))),
            )))),
            const SizedBox(height: 8),
            Text(_getThinkingText(), style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
          ]),
        ],
      ),
    );
  }

  double _getBounceOffset(int dotIndex) {
    final progress = _bounceController.value;
    final delay = dotIndex * 0.2;
    final adjustedProgress = (progress + delay) % 1.0;
    return (adjustedProgress < 0.5 ? -8 : 8) * (1 - adjustedProgress * 2);
  }

  String _getThinkingText() {
    switch (_thinkingIndex) {
      case 0: return 'Thinking';
      case 1: return 'Analyzing';
      case 2: return 'Preparing answer';
      default: return 'Thinking';
    }
  }

  Widget _buildInputBar(bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.withValues(alpha: 0.3))),
      child: Row(children: [
        IconButton(icon: Icon(Icons.attach_file, color: AppColors.primaryPurple), onPressed: _showOcrOptions),
        Expanded(child: TextField(controller: _inputController, style: GoogleFonts.inter(color: textColor), decoration: InputDecoration(hintText: 'Message Echo', hintStyle: GoogleFonts.inter(color: Colors.grey), border: InputBorder.none))),
        ValueListenableBuilder(valueListenable: _inputController, builder: (context, value, child) {
          return AnimatedOpacity(
            opacity: value.text.isNotEmpty ? 1.0 : 0.5, duration: const Duration(milliseconds: 200),
            child: Container(width: 48, height: 48, decoration: BoxDecoration(color: value.text.isNotEmpty ? AppColors.primaryPurple : Colors.grey, shape: BoxShape.circle),
              child: IconButton(icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 20), onPressed: value.text.isNotEmpty ? () => _sendMessage(value.text) : null)),
          );
        }),
      ]),
    );
  }
}