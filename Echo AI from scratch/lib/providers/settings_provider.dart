import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class SettingsState {
  final String appLanguage;
  final String voiceLanguage;
  final double fontSize;
  final bool isLoading;

  const SettingsState({
    this.appLanguage = 'en',
    this.voiceLanguage = 'en',
    this.fontSize = 1.0,
    this.isLoading = true,
  });

  SettingsState copyWith({
    String? appLanguage,
    String? voiceLanguage,
    double? fontSize,
    bool? isLoading,
  }) {
    return SettingsState(
      appLanguage: appLanguage ?? this.appLanguage,
      voiceLanguage: voiceLanguage ?? this.voiceLanguage,
      fontSize: fontSize ?? this.fontSize,
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
    final fontSize = _storage.getFontSize();

    state = state.copyWith(
      appLanguage: appLang,
      voiceLanguage: voiceLang,
      fontSize: fontSize,
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

  Future<void> setFontSize(double size) async {
    await _storage.setFontSize(size);
    state = state.copyWith(fontSize: size);
  }

  Future<void> clearAllData() async {
    await _storage.deleteAllMessages();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(StorageService());
});