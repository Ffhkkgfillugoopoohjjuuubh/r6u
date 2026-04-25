import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart' as storage;
import '../services/tts_service.dart';
import '../services/revenue_optimizer.dart';
import 'ad_provider.dart';
import 'tts_provider.dart';

enum ResponseStatus { idle, loading, done, error }

class ChatState {
  final List<ChatSession> sessions;
  final ChatSession? currentSession;
  final List<ChatMessage> messages;
  final ResponseStatus responseStatus;
  final bool isTyping;
  final String? errorMessage;
  final bool isLoading;
  final String displayedText;

  const ChatState({
    this.sessions = const [],
    this.currentSession,
    this.messages = const [],
    this.responseStatus = ResponseStatus.idle,
    this.isTyping = false,
    this.errorMessage,
    this.isLoading = true,
    this.displayedText = '',
  });

  ChatState copyWith({
    List<ChatSession>? sessions,
    ChatSession? currentSession,
    List<ChatMessage>? messages,
    ResponseStatus? responseStatus,
    bool? isTyping,
    String? errorMessage,
    bool? isLoading,
    String? displayedText,
    bool clearCurrentSession = false,
    bool clearError = false,
  }) {
    return ChatState(
      sessions: sessions ?? this.sessions,
      currentSession: clearCurrentSession ? null : (currentSession ?? this.currentSession),
      messages: messages ?? this.messages,
      responseStatus: responseStatus ?? this.responseStatus,
      isTyping: isTyping ?? this.isTyping,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
      displayedText: displayedText ?? this.displayedText,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final storage.StorageService _storage;
  final ApiService _api;
  final TtsService _tts;
  late final RevenueOptimizer _revenueOptimizer;
  Ref? _ref;

  ChatNotifier(this._storage, this._api, this._tts, [this._ref]) : super(const ChatState()) {
    _revenueOptimizer = RevenueOptimizer(onAdRefresh: () {
      _ref?.read(adProvider.notifier).refreshAds();
    });
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessionsData = await _storage.loadAllSessions();
    final sessions = sessionsData.map((s) => ChatSession(
      id: s.id,
      name: s.name,
      createdAt: s.createdAt,
      updatedAt: s.lastModified,
    )).toList();
    state = state.copyWith(sessions: sessions, isLoading: false);
  }

  Future<void> createSession(String name) async {
    final sessionData = await _storage.createSession(name);
    final session = ChatSession(
      id: sessionData.id,
      name: sessionData.name,
      createdAt: sessionData.createdAt,
      updatedAt: sessionData.lastModified,
    );
    final sessions = [...state.sessions, session];
    state = state.copyWith(sessions: sessions, currentSession: session, messages: []);
  }

  Future<void> selectSession(ChatSession session) async {
    final sessionData = await _storage.loadSession(session.id);
    if (sessionData != null) {
      final messages = sessionData.messages.map((m) => ChatMessage(
        id: m.id,
        content: m.content,
        isUser: m.isUser,
        timestamp: m.timestamp,
        sessionId: session.id,
      )).toList();
      state = state.copyWith(currentSession: session, messages: messages, clearError: true);
    }
  }

  Future<void> deleteSession(String sessionId) async {
    await _storage.deleteSession(sessionId);
    final sessionsData = await _storage.loadAllSessions();
    final sessions = sessionsData.map((s) => ChatSession(
      id: s.id,
      name: s.name,
      createdAt: s.createdAt,
      updatedAt: s.lastModified,
    )).toList();
    
    if (state.currentSession?.id == sessionId) {
      state = state.copyWith(
        sessions: sessions,
        clearCurrentSession: true,
        messages: [],
      );
    } else {
      state = state.copyWith(sessions: sessions);
    }
  }

  Future<void> renameSession(String sessionId, String newName) async {
    await _storage.renameSession(sessionId, newName);
    final sessionsData = await _storage.loadAllSessions();
    final sessions = sessionsData.map((s) => ChatSession(
      id: s.id,
      name: s.name,
      createdAt: s.createdAt,
      updatedAt: s.lastModified,
    )).toList();
    
    if (state.currentSession?.id == sessionId) {
      final sessionData = sessions.firstWhere((s) => s.id == sessionId);
      state = state.copyWith(sessions: sessions, currentSession: sessionData);
    } else {
      state = state.copyWith(sessions: sessions);
    }
  }

  Future<void> sendMessage(String content) async {
    if (state.currentSession == null) {
      final sessionName = content.length > 30 ? content.substring(0, 30) : content;
      await createSession(sessionName);
    }

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
      sessionId: state.currentSession!.id,
    );

    await _storage.saveMessage(
      state.currentSession!.id,
      _toStorageMessage(userMessage),
    );
    
    final messages = [...state.messages, userMessage];
    
    state = state.copyWith(
      messages: messages,
      responseStatus: ResponseStatus.loading,
      isTyping: true,
      clearError: true,
      displayedText: '',
    );

    try {
      final history = messages
          .take(messages.length - 1)
          .map((m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.content,
              })
          .toList();

      final aiResponse = await _api.sendMessage(content, history);

      final aiMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: '',
        isUser: false,
        timestamp: DateTime.now(),
        sessionId: state.currentSession!.id,
      );

      final finalMessages = [...messages, aiMessage];

      state = state.copyWith(
        messages: finalMessages,
        responseStatus: ResponseStatus.done,
        isTyping: false,
      );

      _revenueOptimizer.processResponse(aiResponse, onComplete: (fullText) {
        _updateMessageContent(aiMessage.id, fullText);
      });
    } catch (e) {
      final errorMessage = e is ApiException ? e.message : 'Failed to get response';
      
      state = state.copyWith(
        responseStatus: ResponseStatus.error,
        isTyping: false,
        errorMessage: errorMessage,
      );
    }
  }

  Stream<String> get wordStream => _revenueOptimizer.tokenStream;

  void _updateMessageContent(String messageId, String content) {
    final updatedMessages = state.messages.map((m) {
      if (m.id == messageId) {
        return m.copyWith(content: content);
      }
      return m;
    }).toList();
    state = state.copyWith(messages: updatedMessages);
    
    _storage.saveMessage(
      state.currentSession!.id,
      _toStorageMessage(updatedMessages.firstWhere((m) => m.id == messageId)),
    );
  }

  storage.ChatMessage _toStorageMessage(ChatMessage msg) {
    return storage.ChatMessage(
      id: msg.id,
      role: msg.isUser ? 'user' : 'assistant',
      content: msg.content,
      timestamp: msg.timestamp,
    );
  }

Future<void> speakMessage(String content, String voiceLanguage, String messageId, WidgetRef ref) async {
    final ttsNotifier = ref.read(ttsProvider.notifier);
    final currentState = ref.read(ttsProvider);

    if (currentState.isPlaying && currentState.currentMessageId == messageId) {
      await _tts.stop();
      ttsNotifier.setIdle();
      return;
    }
    
    ttsNotifier.setPreparing(messageId);
    await _tts.setLanguage(voiceLanguage);
    await _tts.speak(content, messageId);
    ttsNotifier.setPlaying(messageId);
}
     
  Future<void> clearAllChats() async {
    await _storage.clearAllSessions();
    state = state.copyWith(sessions: [], clearCurrentSession: true, messages: []);
  }

  void clearTyping() {
    state = state.copyWith(isTyping: false);
  }

  void clearCurrentSession() {
    state = state.copyWith(clearCurrentSession: true, messages: []);
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(storage.StorageService(), ApiService(), TtsService(), ref);
});
