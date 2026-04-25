import 'package:flutter_riverpod/flutter_riverpod.dart';

final progressiveTextProvider = StateProvider<String>((ref) => '');

class ProgressiveTextNotifier extends StateNotifier<String> {
  ProgressiveTextNotifier() : super('');

  void appendWord(String word) {
    state = state + word;
  }

  void reset() {
    state = '';
  }

  void setFullText(String text) {
    state = text;
  }
}

final progressiveTextNotifierProvider = StateNotifierProvider<ProgressiveTextNotifier, String>((ref) {
  return ProgressiveTextNotifier();
});
