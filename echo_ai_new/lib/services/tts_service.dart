import 'package:flutter_tts/flutter_tts.dart';
import 'api_service.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  String _currentLanguage = 'en-US';

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.85);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);
    
    _isInitialized = true;
  }

  Future<void> setLanguage(String languageCode) async {
    String ttsLang;
    switch (languageCode) {
      case 'hi':
        ttsLang = 'hi-IN';
        break;
      case 'bn':
        ttsLang = 'bn-IN';
        break;
      default:
        ttsLang = 'en-US';
    }
    
    _currentLanguage = languageCode;
    await _flutterTts.setLanguage(ttsLang);
  }

  Future<void> speak(String text, String targetVoiceLang) async {
    await initialize();
    
    final translatedText = await ApiService().translateText(text, targetVoiceLang);
    
    final cleanedText = _cleanMarkdown(translatedText);
    final ssmlText = _applySsml(cleanedText);
    
    await _flutterTts.speak(ssmlText);
  }

  String _cleanMarkdown(String text) {
    String cleaned = text;
    
    cleaned = cleaned.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'\1');
    cleaned = cleaned.replaceAll(RegExp(r'\*([^*]+)\*'), r'\1');
    cleaned = cleaned.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    cleaned = cleaned.replaceAll(RegExp(r'`([^`]+)`'), r'\1');
    cleaned = cleaned.replaceAll(RegExp(r'#+\s'), '');
    cleaned = cleaned.replaceAll(RegExp(r'-\s+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\d+\.\s+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'\1');
    cleaned = cleaned.replaceAll(RegExp(r'_{2,}'), r'_');
    cleaned = cleaned.replaceAll(RegExp(r'={2,}'), '');
    cleaned = cleaned.replaceAll(RegExp(r'---+'), '');
    
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return cleaned;
  }

  String _applySsml(String text) {
    final buffer = StringBuffer();
    buffer.write('<speak>');
    buffer.write('<prosody rate="0.85" pitch="0.0">');
    
    final sentences = text.split(RegExp(r'([.!?]+)'));
    
    for (int i = 0; i < sentences.length; i++) {
      final sentence = sentences[i].trim();
      if (sentence.isEmpty) continue;
      
      buffer.write(_addPauses(sentence));
      
      if (i < sentences.length - 1) {
        final punctuation = sentences.length > i + 1 ? sentences[i + 1] : '.';
        if (punctuation.isNotEmpty) {
          buffer.write(punctuation);
        }
      }
      
      if (i < sentences.length - 2) {
        buffer.write('<pause time="500ms"/>');
      }
    }
    
    buffer.write('</prosody>');
    buffer.write('</speak>');
    
    return buffer.toString();
  }

  String _addPauses(String text) {
    String result = text;
    result = result.replaceAllMapped(
      RegExp(r'([,;])'),
      (match) => '${match.group(1)}<pause time="300ms"/>',
    );
    result = result.replaceAllMapped(
      RegExp(r'(\.){2,}'),
      (match) => '<pause time="600ms"/>${match.group(0)}',
    );
    return result;
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  void dispose() {
    _flutterTts.stop();
  }
}