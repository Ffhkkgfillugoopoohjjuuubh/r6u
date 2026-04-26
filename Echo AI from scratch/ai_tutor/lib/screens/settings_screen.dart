import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../config/app_config.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/chat_provider.dart';
import '../main.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.settings,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: settings.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionHeader(title: l10n.settings),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _ThemeSelector(
                      currentMode: themeState.themeString,
                      onChanged: (mode) {
                        ref.read(themeProvider.notifier).setThemeMode(mode);
                      },
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      l10n: l10n,
                    ),
                    const Divider(height: 32),
                    _FontSizeSlider(
                      value: settings.fontSize,
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).setFontSize(value);
                      },
                      textColor: textColor,
                      l10n: l10n,
                    ),
                    const Divider(height: 32),
                    _LanguageSelector(
                      title: l10n.appLanguage,
                      selectedLanguage: settings.appLanguage,
                      onChanged: (lang) async {
                        ref.read(settingsProvider.notifier).setAppLanguage(lang);
                        ref.read(localeProvider.notifier).state = Locale(lang);
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('app_locale', lang);
                      },
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      l10n: l10n,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionHeader(title: l10n.voiceLanguage),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _LanguageSelector(
                      title: l10n.voiceLanguage,
                      selectedLanguage: settings.voiceLanguage,
                      onChanged: (lang) async {
                        ref.read(settingsProvider.notifier).setVoiceLanguage(lang);
                        final code = lang == 'hi' ? 'hi-IN' : (lang == 'bn' ? 'bn-IN' : 'en-US');
                        await TtsService().setLanguage(code);
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('voice_language', lang);
                      },
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      l10n: l10n,
                    ),
                    const Divider(height: 32),
                    _GenderSelector(
                      selectedGender: settings.voiceGender,
                      onChanged: (gender) {
                        ref.read(settingsProvider.notifier).setVoiceGender(gender);
                      },
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      l10n: l10n,
                    ),
                    const Divider(height: 32),
                    _SliderSetting(
                      title: l10n.volume,
                      value: settings.voiceVolume,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).setVoiceVolume(value);
                        TtsService().updateVoiceSettings(volume: value);
                      },
                      textColor: textColor,
                    ),
                    const Divider(height: 32),
                    _SliderSetting(
                      title: l10n.pitch,
                      value: settings.voicePitch,
                      min: 0.8,
                      max: 1.4,
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).setVoicePitch(value);
                        TtsService().updateVoiceSettings(pitch: value);
                      },
                      textColor: textColor,
                    ),
                    const Divider(height: 32),
                    _SliderSetting(
                      title: l10n.speechRate,
                      value: settings.voiceRate,
                      min: 0.7,
                      max: 1.0,
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).setVoiceRate(value);
                        TtsService().updateVoiceSettings(rate: value);
                      },
                      textColor: textColor,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionHeader(title: l10n.settings),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n.storageLocation,
                        style: GoogleFonts.inter(color: textColor),
                      ),
                      subtitle: Text(
                        StorageService().chatsDirectory,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                    const Divider(height: 24),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.delete_forever, color: Colors.red),
                      title: Text(
                        l10n.clearAllChats,
                        style: GoogleFonts.inter(color: Colors.red),
                      ),
                      subtitle: Text(
                        l10n.thisActionCannotBeUndone,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                      onTap: () => _showClearDataDialog(context, ref, l10n),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionHeader(title: l10n.settings),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.info_outline, color: AppColors.primaryBlue),
                      title: Text(
                        l10n.adStatus,
                        style: GoogleFonts.inter(color: textColor),
                      ),
                      subtitle: Text(
                        l10n.activeRevenue,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionHeader(title: l10n.about),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.auto_awesome, color: AppColors.primaryBlue),
                      title: Text(
                        'Echo AI',
                        style: GoogleFonts.inter(color: textColor),
                      ),
                      subtitle: Text(
                        '${l10n.version} 1.0.0',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                    const Divider(height: 16),
                    Text(
                      l10n.yourPersonalAi,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllData),
        content: Text(l10n.confirmClear),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(settingsProvider.notifier).clearAllData();
              ref.read(chatProvider.notifier).clearAllChats();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.allChatHistoryCleared),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryBlue,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final String currentMode;
  final Function(String) onChanged;
  final Color textColor;
  final Color secondaryTextColor;
  final AppLocalizations l10n;

  const _ThemeSelector({
    required this.currentMode,
    required this.onChanged,
    required this.textColor,
    required this.secondaryTextColor,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.theme,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _ThemeOption(
              label: l10n.lightMode,
              icon: Icons.light_mode,
              isSelected: currentMode == 'light',
              onTap: () => onChanged('light'),
              textColor: textColor,
            ),
            const SizedBox(width: 12),
            _ThemeOption(
              label: l10n.darkMode,
              icon: Icons.dark_mode,
              isSelected: currentMode == 'dark',
              onTap: () => onChanged('dark'),
              textColor: textColor,
            ),
            const SizedBox(width: 12),
            _ThemeOption(
              label: l10n.systemDefault,
              icon: Icons.settings_brightness,
              isSelected: currentMode == 'system',
              onTap: () => onChanged('system'),
              textColor: textColor,
            ),
          ],
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color textColor;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.chipRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.chipRadius),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primaryBlue : textColor.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isSelected ? AppColors.primaryBlue : textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FontSizeSlider extends StatelessWidget {
  final double value;
  final Function(double) onChanged;
  final Color textColor;
  final AppLocalizations l10n;

  const _FontSizeSlider({
    required this.value,
    required this.onChanged,
    required this.textColor,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.fontSize,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            Text(
              value == 0.8 ? l10n.small : (value == 1.0 ? l10n.medium : l10n.large),
              style: GoogleFonts.inter(
                color: textColor,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0.8,
          max: 1.2,
          divisions: 2,
          activeColor: AppColors.primaryBlue,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final String title;
  final String selectedLanguage;
  final Function(String) onChanged;
  final Color textColor;
  final Color secondaryTextColor;
  final AppLocalizations l10n;

  const _LanguageSelector({
    required this.title,
    required this.selectedLanguage,
    required this.onChanged,
    required this.textColor,
    required this.secondaryTextColor,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _LanguageOption(
              label: l10n.english,
              value: 'en',
              isSelected: selectedLanguage == 'en',
              onTap: () => onChanged('en'),
              textColor: textColor,
            ),
            const SizedBox(width: 8),
            _LanguageOption(
              label: l10n.hindi,
              value: 'hi',
              isSelected: selectedLanguage == 'hi',
              onTap: () => onChanged('hi'),
              textColor: textColor,
            ),
            const SizedBox(width: 8),
            _LanguageOption(
              label: l10n.bengali,
              value: 'bn',
              isSelected: selectedLanguage == 'bn',
              onTap: () => onChanged('bn'),
              textColor: textColor,
            ),
          ],
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;
  final Color textColor;

  const _LanguageOption({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.chipRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.chipRadius),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : textColor.withValues(alpha: 0.2),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isSelected ? AppColors.primaryBlue : textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final String selectedGender;
  final Function(String) onChanged;
  final Color textColor;
  final Color secondaryTextColor;
  final AppLocalizations l10n;

  const _GenderSelector({
    required this.selectedGender,
    required this.onChanged,
    required this.textColor,
    required this.secondaryTextColor,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.voiceGender,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _LanguageOption(
              label: l10n.female,
              value: 'female',
              isSelected: selectedGender == 'female',
              onTap: () => onChanged('female'),
              textColor: textColor,
            ),
            const SizedBox(width: 8),
            _LanguageOption(
              label: l10n.male,
              value: 'male',
              isSelected: selectedGender == 'male',
              onTap: () => onChanged('male'),
              textColor: textColor,
            ),
          ],
        ),
      ],
    );
  }
}

class _SliderSetting extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final Function(double) onChanged;
  final Color textColor;

  const _SliderSetting({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            Text(
              value.toStringAsFixed(2),
              style: GoogleFonts.inter(color: textColor),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: AppColors.primaryBlue,
          onChanged: onChanged,
        ),
      ],
    );
  }
}