import 'dart:async';
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _speaking = false;
  String _languageCode = 'en-US';
  String _groqApiKey = ApiConfig.groqApiKey;
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
    _languageCode = code;
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
    _languageCode = languageCode;
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

  Future<String> _translateToLanguage(String text) async {
    if (_languageCode.startsWith('en')) {
      return text;
    }

    String targetLang;
    String systemMsg;
    
    if (_languageCode.startsWith('hi')) {
      targetLang = 'Hindi';
      systemMsg = 'You are a translator. Translate the following text to Hindi. Return ONLY the Hindi translation using Devanagari script. Do not include any English words or explanation.';
    } else if (_languageCode.startsWith('bn')) {
      targetLang = 'Bengali';
      systemMsg = 'You are a translator. Translate the following text to Bengali. Return ONLY the Bengali translation using Bengali script. Do not include any English words or explanation.';
    } else {
      return text;
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'max_tokens': 2048,
          'messages': [
            {'role': 'system', 'content': systemMsg},
            {'role': 'user', 'content': text},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      }
    } catch (e) {
      // Return original text on error
    }
    return text;
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

  List<String> _splitIntoSentences(String text) {
    final sentences = text.split(RegExp(r'(?<=[.?!])\s+'));
    final filtered = sentences.where((s) => s.trim().isNotEmpty).map((s) => s.trim()).toList();
    
    final deduped = <String>[];
    String? prev;
    for (final s in filtered) {
      if (s != prev) {
        deduped.add(s);
        prev = s;
      }
    }
    
    return deduped;
  }

  Future<void> speak(String rawText, String messageId) async {
    await initialize();
    
    if (_speaking) {
      await stop();
      await Future.delayed(Duration(milliseconds: 200));
    }

    String translated = await _translateToLanguage(rawText);
    
    await _tts.setLanguage(_languageCode);
    await Future.delayed(Duration(milliseconds: 100));
    
    final cleaned = _clean(translated);
    final sentences = _splitIntoSentences(cleaned);

    _speaking = true;
    _currentMessageId = messageId;
    _speakingIdController.add(messageId);

    for (final sentence in sentences) {
      await _tts.speak(sentence);
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