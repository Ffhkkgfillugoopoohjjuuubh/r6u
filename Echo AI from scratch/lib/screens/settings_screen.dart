import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/chat_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: settings.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _SectionHeader(title: 'Display'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'App Language',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _LanguageSelector(
                          selectedLanguage: settings.appLanguage,
                          onChanged: (lang) {
                            ref.read(settingsProvider.notifier).setAppLanguage(lang);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Font Size',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _FontSizeSlider(
                          value: settings.fontSize,
                          onChanged: (value) {
                            ref.read(settingsProvider.notifier).setFontSize(value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionHeader(title: 'Voice'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Voice Language',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _LanguageSelector(
                          selectedLanguage: settings.voiceLanguage,
                          onChanged: (lang) {
                            ref.read(settingsProvider.notifier).setVoiceLanguage(lang);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionHeader(title: 'Data'),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('Clear All Chat History'),
                    subtitle: const Text('This action cannot be undone'),
                    onTap: () => _showClearDataDialog(context, ref),
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionHeader(title: 'About'),
                const SizedBox(height: 8),
                Card(
                  child: const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('AI Tutor'),
                    subtitle: Text('Version 1.0.0'),
                  ),
                ),
              ],
            ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to delete all chat history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(settingsProvider.notifier).clearAllData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All chat history cleared'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
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
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2196F3),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) onChanged;
  const _LanguageSelector({
    required this.selectedLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LanguageOption(
          label: 'English',
          value: 'en',
          isSelected: selectedLanguage == 'en',
          onTap: () => onChanged('en'),
        ),
        _LanguageOption(
          label: 'हिन्दी (Hindi)',
          value: 'hi',
          isSelected: selectedLanguage == 'hi',
          onTap: () => onChanged('hi'),
        ),
        _LanguageOption(
          label: 'বাংলা (Bengali)',
          value: 'bn',
          isSelected: selectedLanguage == 'bn',
          onTap: () => onChanged('bn'),
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

  const _LanguageOption({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF2196F3) : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _FontSizeSlider extends StatelessWidget {
  final double value;
  final Function(double) onChanged;

  const _FontSizeSlider({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Small', style: TextStyle(fontSize: 12)),
            Text(
              value == 0.8 ? 'Small' : (value == 1.0 ? 'Medium' : 'Large'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('Large', style: TextStyle(fontSize: 16)),
          ],
        ),
        Slider(
          value: value,
          min: 0.8,
          max: 1.2,
          divisions: 2,
          activeColor: const Color(0xFF2196F3),
          onChanged: onChanged,
        ),
      ],
    );
  }
}