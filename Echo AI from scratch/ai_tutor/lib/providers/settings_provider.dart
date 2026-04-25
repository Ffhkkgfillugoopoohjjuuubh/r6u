import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class SettingsState {
  final String appLanguage;
  final String voiceLanguage;
  final String voiceGender;
  final double fontSize;
  final double voiceVolume;
  final double voicePitch;
  final double voiceRate;
  final bool isLoading;

  const SettingsState({
    this.appLanguage = 'en',
    this.voiceLanguage = 'en',
    this.voiceGender = 'female',
    this.fontSize = 1.0,
    this.voiceVolume = 1.0,
    this.voicePitch = 1.2,
    this.voiceRate = 0.82,
    this.isLoading = true,
  });

  SettingsState copyWith({
    String? appLanguage,
    String? voiceLanguage,
    String? voiceGender,
    double? fontSize,
    double? voiceVolume,
    double? voicePitch,
    double? voiceRate,
    bool? isLoading,
  }) {
    return SettingsState(
      appLanguage: appLanguage ?? this.appLanguage,
      voiceLanguage: voiceLanguage ?? this.voiceLanguage,
      voiceGender: voiceGender ?? this.voiceGender,
      fontSize: fontSize ?? this.fontSize,
      voiceVolume: voiceVolume ?? this.voiceVolume,
      voicePitch: voicePitch ?? this.voicePitch,
      voiceRate: voiceRate ?? this.voiceRate,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final StorageService _storage;

  SettingsNotifier(this._storage) : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final appLang = _storage.getAppLanguage();
    final voiceLang = _storage.getVoiceLanguage();
    final voiceGender = _storage.getVoiceGender();
    final fontSize = _storage.getFontSize();
    final voiceVolume = _storage.getVoiceVolume();
    final voicePitch = _storage.getVoicePitch();
    final voiceRate = _storage.getVoiceRate();

    state = state.copyWith(
      appLanguage: appLang,
      voiceLanguage: voiceLang,
      voiceGender: voiceGender,
      fontSize: fontSize,
      voiceVolume: voiceVolume,
      voicePitch: voicePitch,
      voiceRate: voiceRate,
      isLoading: false,
    );
  }

  Future<void> setAppLanguage(String language) async {
    await _storage.setAppLanguage(language);
    state = state.copyWith(appLanguage: language);
  }

  Future<void> setVoiceLanguage(String language) async {
    await _storage.setVoiceLanguage(language);
    state = state.copyWith(voiceLanguage: language);
  }

  Future<void> setVoiceGender(String gender) async {
    await _storage.setVoiceGender(gender);
    state = state.copyWith(voiceGender: gender);
  }

  Future<void> setFontSize(double size) async {
    await _storage.setFontSize(size);
    state = state.copyWith(fontSize: size);
  }

  Future<void> setVoiceVolume(double volume) async {
    await _storage.setVoiceVolume(volume);
    state = state.copyWith(voiceVolume: volume);
  }

  Future<void> setVoicePitch(double pitch) async {
    await _storage.setVoicePitch(pitch);
    state = state.copyWith(voicePitch: pitch);
  }

  Future<void> setVoiceRate(double rate) async {
    await _storage.setVoiceRate(rate);
    state = state.copyWith(voiceRate: rate);
  }

  Future<void> clearAllData() async {
    await _storage.clearAllSessions();
  }

  String getStoragePath() {
    return _storage.chatsDirectory;
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(StorageService());
});
