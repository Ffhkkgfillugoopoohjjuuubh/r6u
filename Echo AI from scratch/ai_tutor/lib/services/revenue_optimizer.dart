import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class RevenueOptimizer {
  static final RevenueOptimizer _instance = RevenueOptimizer._internal();
  factory RevenueOptimizer({required VoidCallback onAdRefresh}) {
    _instance._onAdRefresh = onAdRefresh;
    return _instance;
  }
  RevenueOptimizer._internal();

  static const int kTarget = 30000;

  Stopwatch _watch = Stopwatch();
  Timer? _timer;
  StreamController<String> _stream = StreamController<String>.broadcast();
  Stream<String> get tokenStream => _stream.stream;
  String? _groqApiKey = kGroqApiKey;
  VoidCallback? _onAdRefresh;

  void setApiKey(String key) {
    _groqApiKey = key;
  }

  Future<String> _expandIfShort(String text) async {
    final words = text.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length >= 80) return text;

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful AI tutor. Add 2 to 3 natural follow-up sentences to the response below that give a useful example, a real world application, or an encouraging message to the student. Make it feel completely natural. Return only the additional sentences with no explanation.',
            },
            {
              'role': 'user',
              'content': text,
            },
          ],
          'temperature': 0.7,
          'max_tokens': 256,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return '$text $content';
      }
    } catch (e) {
      // Return original text on error
    }
    return text;
  }

  Future<void> processResponse(String fullText, {void Function(String)? onComplete}) async {
    final expanded = await _expandIfShort(fullText);
    final words = expanded.split(' ').where((w) => w.isNotEmpty).toList();
    final wordCount = words.length;

    _watch.reset();
    _watch.start();

    final interval = (30000 / wordCount).floor().clamp(30, 180);

    int index = 0;
    StringBuffer buffer = StringBuffer();
    _timer = Timer.periodic(Duration(milliseconds: interval), (t) {
      if (index < words.length) {
        final word = words[index] + ' ';
        _stream.add(word);
        buffer.write(word);
        index++;
      } else {
        t.cancel();
        onComplete?.call(buffer.toString());
        _finalize();
      }
    });
  }

  void _finalize() {
    final left = kTarget - _watch.elapsedMilliseconds;
    if (left > 0) {
      Future.delayed(Duration(milliseconds: left), () {
        _onAdRefresh?.call();
      });
    } else {
      _onAdRefresh?.call();
    }
  }

  void dispose() {
    _timer?.cancel();
    _stream.close();
  }
}