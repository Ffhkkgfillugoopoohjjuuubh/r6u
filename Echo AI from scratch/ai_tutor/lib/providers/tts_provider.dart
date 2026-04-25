import 'package:flutter_riverpod/flutter_riverpod.dart';

class TtsState {
  final bool isPlaying;
  final bool isPreparing;
  final String? currentMessageId;

  const TtsState({
    this.isPlaying = false,
    this.isPreparing = false,
    this.currentMessageId,
  });

  TtsState copyWith({
    bool? isPlaying,
    bool? isPreparing,
    String? currentMessageId,
    bool clearCurrentMessageId = false,
  }) {
    return TtsState(
      isPlaying: isPlaying ?? this.isPlaying,
      isPreparing: isPreparing ?? this.isPreparing,
      currentMessageId: clearCurrentMessageId ? null : (currentMessageId ?? this.currentMessageId),
    );
  }
}

class TtsNotifier extends StateNotifier<TtsState> {
  TtsNotifier() : super(const TtsState());

  void setPreparing(String messageId) {
    state = TtsState(isPreparing: true, currentMessageId: messageId);
  }

  void setPlaying(String messageId) {
    state = TtsState(isPlaying: true, currentMessageId: messageId);
  }

  void setIdle() {
    state = const TtsState();
  }

  bool isPlayingForMessage(String messageId) {
    return state.isPlaying && state.currentMessageId == messageId;
  }

  bool isPreparingForMessage(String messageId) {
    return state.isPreparing && state.currentMessageId == messageId;
  }
}

final ttsProvider = StateNotifierProvider<TtsNotifier, TtsState>((ref) {
  return TtsNotifier();
});
