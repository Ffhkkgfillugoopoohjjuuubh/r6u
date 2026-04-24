import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;
  late Box<ChatSession> _sessionsBox;
  late Box<ChatMessage> _messagesBox;
  bool _isInitialized = false;

  static const String _appLanguageKey = 'app_language';
  static const String _voiceLanguageKey = 'voice_language';
  static const String _fontSizeKey = 'font_size';

  Future<void> initialize() async {
    if (_isInitialized) return;

    await Hive.initFlutter();
    
    Hive.registerAdapter(ChatMessageAdapter());
    Hive.registerAdapter(ChatSessionAdapter());
    
    _sessionsBox = await Hive.openBox<ChatSession>('chat_sessions');
    _messagesBox = await Hive.openBox<ChatMessage>('chat_messages');
    
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  List<ChatSession> getSessions() {
    return _sessionsBox.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> saveSession(ChatSession session) async {
    await _sessionsBox.put(session.id, session);
  }

  Future<void> deleteSession(String sessionId) async {
    await _sessionsBox.delete(sessionId);
    
    final messagesToDelete = _messagesBox.values
        .where((m) => m.sessionId == sessionId)
        .map((m) => m.id)
        .toList();
    
    for (final msgId in messagesToDelete) {
      await _messagesBox.delete(msgId);
    }
  }

  List<ChatMessage> getMessages(String sessionId) {
    return _messagesBox.values
        .where((m) => m.sessionId == sessionId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> saveMessage(ChatMessage message) async {
    await _messagesBox.put(message.id, message);
  }

  Future<void> deleteAllMessages() async {
    await _messagesBox.clear();
    await _sessionsBox.clear();
  }

  String getAppLanguage() {
    return _prefs.getString(_appLanguageKey) ?? 'en';
  }

  Future<void> setAppLanguage(String language) async {
    await _prefs.setString(_appLanguageKey, language);
  }

  String getVoiceLanguage() {
    return _prefs.getString(_voiceLanguageKey) ?? 'en';
  }

  Future<void> setVoiceLanguage(String language) async {
    await _prefs.setString(_voiceLanguageKey, language);
  }

  double getFontSize() {
    return _prefs.getDouble(_fontSizeKey) ?? 1.0;
  }

  Future<void> setFontSize(double size) async {
    await _prefs.setDouble(_fontSizeKey, size);
  }

  void dispose() {
    _sessionsBox.close();
    _messagesBox.close();
  }
}