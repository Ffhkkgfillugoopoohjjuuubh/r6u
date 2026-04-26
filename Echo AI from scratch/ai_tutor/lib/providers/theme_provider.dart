import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState {
  final ThemeMode themeMode;
  final String themeString;

  const ThemeState({
    this.themeMode = ThemeMode.system,
    this.themeString = 'system',
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    String? themeString,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      themeString: themeString ?? this.themeString,
    );
  }

  static ThemeMode themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  final SharedPreferences _prefs;
  static const String _themeKey = 'app_theme';

  ThemeNotifier(this._prefs) : super(const ThemeState()) {
    _loadTheme();
  }

  void _loadTheme() {
    final themeString = _prefs.getString(_themeKey) ?? 'system';
    state = ThemeState(
      themeMode: ThemeState.themeModeFromString(themeString),
      themeString: themeString,
    );
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_themeKey, mode);
    state = ThemeState(
      themeMode: ThemeState.themeModeFromString(mode),
      themeString: mode,
    );
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier(SharedPreferences.getInstance() as SharedPreferences);
});
