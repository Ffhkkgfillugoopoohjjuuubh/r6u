import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/ad_provider.dart';
import '../services/ocr_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input_widget.dart';
import '../widgets/ad_banner_widget.dart';
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
  bool _isOcrProcessing = false;
  bool _shouldRefreshAds = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
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

  void _handleOcr(bool fromCamera) async {
    setState(() => _isOcrProcessing = true);

    final text = await OcrService().extractTextFromImage(fromCamera: fromCamera);

    setState(() => _isOcrProcessing = false);

    if (text != null && text.isNotEmpty) {
      _inputController.text = text;
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No text found in the image'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    _inputController.clear();
    await ref.read(chatProvider.notifier).sendMessage(content, ref);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final settingsState = ref.watch(settingsProvider);
    final adState = ref.watch(adProvider);

    ref.listen<AdState>(adProvider, (previous, next) {
      if (previous?.shouldRefresh == false && next.shouldRefresh == true) {
        ref.read(adProvider.notifier).refreshAds();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(chatState.currentSession?.name ?? 'Chat'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
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
          if (chatState.sessions.length <= 1) {
            Navigator.pushReplacementNamed(context, '/');
          }
        },
        onSessionCreated: (name) {
          ref.read(chatProvider.notifier).createSession(name);
          Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          const AdBannerWidget(isTop: true),
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
                        const Icon(
                          Icons.school,
                          size: 60,
                          color: Color(0xFF2196F3),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Ask me anything!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'I\'m here to help you learn',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: chatState.messages.length + (chatState.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == chatState.messages.length && chatState.isTyping) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('AI is typing...'),
                            ],
                          ),
                        );
                      }

                      final message = chatState.messages[index];
                      return MessageBubble(
                        message: message,
                        fontSize: settingsState.fontSize,
                        voiceLanguage: settingsState.voiceLanguage,
                        onSpeak: () {
                          ref.read(chatProvider.notifier).speakMessage(
                                message.content,
                                settingsState.voiceLanguage,
                              );
                        },
                      );
                    },
                  ),
          ),
          if (_isOcrProcessing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Processing image...'),
                ],
              ),
            ),
          const AdBannerWidget(isTop: false),
          ChatInputWidget(
            controller: _inputController,
            onSend: _sendMessage,
            onOcrSelected: _handleOcr,
            isLoading: chatState.responseStatus == ResponseStatus.loading,
          ),
        ],
      ),
    );
  }
}