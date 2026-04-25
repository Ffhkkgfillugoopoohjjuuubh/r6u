import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage {
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isUser => role == 'user';
}

class ChatSessionData {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime lastModified;
  final List<ChatMessage> messages;

  ChatSessionData({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.lastModified,
    this.messages = const [],
  });

  factory ChatSessionData.fromJson(Map<String, dynamic> json) {
    return ChatSessionData(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModified: DateTime.parse(json['lastModified'] as String),
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  ChatSessionData copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? lastModified,
    List<ChatMessage>? messages,
  }) {
    return ChatSessionData(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      messages: messages ?? this.messages,
    );
  }
}

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;
  late Directory _documentsDir;
  bool _isInitialized = false;

  static const String _appLanguageKey = 'app_language';
  static const String _voiceLanguageKey = 'voice_language';
  static const String _fontSizeKey = 'font_size';
  static const String _themeModeKey = 'theme_mode';
  static const String _voiceGenderKey = 'voice_gender';
  static const String _voiceVolumeKey = 'voice_volume';
  static const String _voicePitchKey = 'voice_pitch';
  static const String _voiceRateKey = 'voice_rate';

  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    _documentsDir = await getApplicationDocumentsDirectory();

    final chatsDir = Directory('${_documentsDir.path}/echo_chats');
    if (!await chatsDir.exists()) {
      await chatsDir.create(recursive: true);
    }

    _isInitialized = true;
  }

  String get chatsDirectory => '${_documentsDir.path}/echo_chats';

  Future<Directory> _getDir() async {
    final dir = Directory(chatsDirectory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> saveSession(ChatSessionData session) async {
    final dir = await _getDir();
    final file = File('${dir.path}/${session.id}.json');
    await file.writeAsString(jsonEncode(session.toJson()), flush: true);
  }

  Future<List<ChatSessionData>> loadAllSessions() async {
    final dir = await _getDir();
    final sessions = <ChatSessionData>[];

    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.json')) {
        try {
          final content = await entity.readAsString();
          final session = ChatSessionData.fromJson(jsonDecode(content));
          sessions.add(session);
        } catch (e) {
          // Skip invalid files
        }
      }
    }

    sessions.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    return sessions;
  }

  Future<ChatSessionData?> loadSession(String sessionId) async {
    try {
      final dir = await _getDir();
      final file = File('${dir.path}/$sessionId.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        return ChatSessionData.fromJson(jsonDecode(content));
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<void> deleteSession(String sessionId) async {
    final dir = await _getDir();
    final file = File('${dir.path}/$sessionId.json');
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> renameSession(String sessionId, String newName) async {
    final session = await loadSession(sessionId);
    if (session != null) {
      final updated = session.copyWith(
        name: newName,
        lastModified: DateTime.now(),
      );
      await saveSession(updated);
    }
  }

  Future<void> saveMessage(String sessionId, ChatMessage message) async {
    final session = await loadSession(sessionId);
    if (session != null) {
      final updatedMessages = [...session.messages, message];
      final updated = session.copyWith(
        messages: updatedMessages,
        lastModified: DateTime.now(),
      );
      await saveSession(updated);
    }
  }

  Future<ChatSessionData> createSession(String name) async {
    final now = DateTime.now();
    final session = ChatSessionData(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: now,
      lastModified: now,
      messages: [],
    );

    await saveSession(session);
    return session;
  }

  Future<void> clearAllSessions() async {
    final dir = await _getDir();
    final files = dir.listSync().where((e) => e is File && e.path.endsWith('.json')).toList();
    for (final entity in files) {
      entity.deleteSync();
    }
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

  String getThemeMode() {
    return _prefs.getString(_themeModeKey) ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_themeModeKey, mode);
  }

  String getVoiceGender() {
    return _prefs.getString(_voiceGenderKey) ?? 'female';
  }

  Future<void> setVoiceGender(String gender) async {
    await _prefs.setString(_voiceGenderKey, gender);
  }

  double getVoiceVolume() {
    return _prefs.getDouble(_voiceVolumeKey) ?? 1.0;
  }

  Future<void> setVoiceVolume(double volume) async {
    await _prefs.setDouble(_voiceVolumeKey, volume);
  }

  double getVoicePitch() {
    return _prefs.getDouble(_voicePitchKey) ?? 1.2;
  }

  Future<void> setVoicePitch(double pitch) async {
    await _prefs.setDouble(_voicePitchKey, pitch);
  }

  double getVoiceRate() {
    return _prefs.getDouble(_voiceRateKey) ?? 0.82;
  }

  Future<void> setVoiceRate(double rate) async {
    await _prefs.setDouble(_voiceRateKey, rate);
  }

  void dispose() {}
}