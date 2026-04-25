import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _speaking = false;
  String? _currentMessageId;
  StreamController<String?> _speakingIdController = StreamController<String?>.broadcast();
  Stream<String?> get speakingIdStream => _speakingIdController.stream;
  
  String? get currentlySpeakingMessageId => _currentMessageId;

  Future<void> initialize() async {
    await _tts.setEngine('com.google.android.tts');
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.15);
    await _tts.setSpeechRate(0.42);
    await _tts.awaitSpeakCompletion(true);

    _tts.setCompletionHandler(() {
      _speaking = false;
      _currentMessageId = null;
      _speakingIdController.add(null);
    });

    _tts.setErrorHandler((msg) {
      _speaking = false;
      _currentMessageId = null;
      _speakingIdController.add(null);
    });
  }

  Future<void> setLanguage(String code) async {
    await _tts.setLanguage(code);
    if (code.startsWith('hi')) {
      await _tts.setPitch(1.2);
    } else if (code.startsWith('bn')) {
      await _tts.setPitch(1.2);
    } else if (code.startsWith('en')) {
      await _tts.setPitch(1.15);
    }
  }

  Future<void> setVoiceLanguage(String languageCode) async {
    await _tts.setLanguage(languageCode);
    if (languageCode.startsWith('hi')) {
      await _tts.setPitch(1.2);
    } else if (languageCode.startsWith('bn')) {
      await _tts.setPitch(1.2);
    } else if (languageCode.startsWith('en')) {
      await _tts.setPitch(1.15);
    }
  }

  double _volume = 1.0;
  double _pitch = 1.15;
  double _rate = 0.42;

  Future<void> updateVoiceSettings({
    double? volume,
    double? pitch,
    double? rate,
  }) async {
    if (volume != null) {
      _volume = volume;
      await _tts.setVolume(volume);
    }
    if (pitch != null) {
      _pitch = pitch;
      await _tts.setPitch(pitch);
    }
    if (rate != null) {
      _rate = rate;
      await _tts.setSpeechRate(rate);
    }
  }

  String _clean(String raw) {
    String cleaned = raw;
    cleaned = cleaned.replaceAll('*', '');
    cleaned = cleaned.replaceAll('#', '');
    cleaned = cleaned.replaceAll('`', '');
    cleaned = cleaned.replaceAll('<', '');
    cleaned = cleaned.replaceAll('>', '');
    cleaned = cleaned.replaceAll('\n\n', ' ');
    cleaned = cleaned.replaceAll('\n', ' ');
    cleaned = cleaned.replaceAll(RegExp(r' +'), ' ');
    return cleaned.trim();
  }

  Future<void> speak(String rawText, String messageId) async {
    await initialize();
    
    if (_speaking) {
      await stop();
      await Future.delayed(Duration(milliseconds: 200));
    }

    String clean = _clean(rawText);
    final sentences = clean.split(RegExp(r'(?<=[.?!])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    _speaking = true;
    _currentMessageId = messageId;
    _speakingIdController.add(messageId);

    for (final sentence in sentences) {
      await _tts.speak(sentence.trim());
    }

    _speaking = false;
    _currentMessageId = null;
    _speakingIdController.add(null);
  }

  Future<void> stop() async {
    await _tts.stop();
    _speaking = false;
    _currentMessageId = null;
    _speakingIdController.add(null);
  }

  void dispose() {
    _tts.stop();
    _speakingIdController.close();
  }
}