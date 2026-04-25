import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';
import 'ad_provider.dart';

enum ResponseStatus { idle, loading, done, error }

class ChatState {
  final List<ChatSession> sessions;
  final ChatSession? currentSession;
  final List<ChatMessage> messages;
  final ResponseStatus responseStatus;
  final bool isTyping;
  final String? errorMessage;
  final bool isLoading;

  const ChatState({
    this.sessions = const [],
    this.currentSession,
    this.messages = const [],
    this.responseStatus = ResponseStatus.idle,
    this.isTyping = false,
    this.errorMessage,
    this.isLoading = true,
  });

  ChatState copyWith({
    List<ChatSession>? sessions,
    ChatSession? currentSession,
    List<ChatMessage>? messages,
    ResponseStatus? responseStatus,
    bool? isTyping,
    String? errorMessage,
    bool? isLoading,
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
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final StorageService _storage;
  final ApiService _api;
  final TtsService _tts;

  ChatNotifier(this._storage, this._api, this._tts) : super(const ChatState()) {
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessions = _storage.getSessions();
    state = state.copyWith(sessions: sessions, isLoading: false);
  }

  Future<void> createSession(String name) async {
    final now = DateTime.now();
    final session = ChatSession(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: now,
      updatedAt: now,
    );

    await _storage.saveSession(session);
    final sessions = _storage.getSessions();
    state = state.copyWith(sessions: sessions, currentSession: session, messages: []);
  }

  Future<void> selectSession(ChatSession session) async {
    final messages = _storage.getMessages(session.id);
    state = state.copyWith(currentSession: session, messages: messages, clearError: true);
  }

  Future<void> deleteSession(String sessionId) async {
    await _storage.deleteSession(sessionId);
    final sessions = _storage.getSessions();
    
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

  Future<void> sendMessage(String content, Ref ref) async {
    if (state.currentSession == null) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
      sessionId: state.currentSession!.id,
    );

    await _storage.saveMessage(userMessage);
    
    final updatedSession = state.currentSession!.copyWith(updatedAt: DateTime.now());
    await _storage.saveSession(updatedSession);
    
    final messages = _storage.getMessages(state.currentSession!.id);
    final sessions = _storage.getSessions();
    
    state = state.copyWith(
      messages: messages,
      sessions: sessions,
      currentSession: updatedSession,
      responseStatus: ResponseStatus.loading,
      isTyping: true,
      clearError: true,
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
        content: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
        sessionId: state.currentSession!.id,
      );

      await _storage.saveMessage(aiMessage);

      final finalMessages = _storage.getMessages(state.currentSession!.id);
      final finalSession = state.currentSession!.copyWith(updatedAt: DateTime.now());
      await _storage.saveSession(finalSession);
      final finalSessions = _storage.getSessions();

      state = state.copyWith(
        messages: finalMessages,
        sessions: finalSessions,
        currentSession: finalSession,
        responseStatus: ResponseStatus.done,
        isTyping: false,
      );

      ref.read(adProvider.notifier).triggerRefresh();
    } catch (e) {
      final errorMessage = e is ApiException ? e.message : 'Failed to get response';
      
      state = state.copyWith(
        responseStatus: ResponseStatus.error,
        isTyping: false,
        errorMessage: errorMessage,
      );
    }
  }

  Future<void> speakMessage(String content, String voiceLanguage) async {
    await _tts.speak(content, voiceLanguage);
  }

  void clearTyping() {
    state = state.copyWith(isTyping: false);
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(StorageService(), ApiService(), TtsService());
});