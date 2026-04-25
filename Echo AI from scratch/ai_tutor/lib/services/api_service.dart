import 'dart:convert';
import 'package:http/http.dart' as http;

const String kGroqApiKey = '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';
const String kGroqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
const String kModel = 'llama-3.1-8b-instant';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  Future<String> sendMessage(String message, List<Map<String, dynamic>> history) async {
    final systemPrompt = '''You are a patient, encouraging, and human-like AI teacher. 
Your goal is to help students learn and understand concepts in a friendly and supportive way.
Always respond with empathy, clarity, and encouragement. Break down complex topics into simple,
easy-to-understand explanations. Use analogies and examples when helpful.''';

    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': systemPrompt},
      ...history,
      {'role': 'user', 'content': message},
    ];

    try {
      final response = await _client.post(
        Uri.parse(kGroqApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $kGroqApiKey',
        },
        body: jsonEncode({
          'model': kModel,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        final error = jsonDecode(response.body);
        throw ApiException(error['error']?['message'] ?? 'API request failed');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<String> translateText(String text, String targetLanguage) async {
    String langName;
    switch (targetLanguage) {
      case 'hi':
        langName = 'Hindi';
        break;
      case 'bn':
        langName = 'Bengali';
        break;
      default:
        langName = 'English';
    }

    final prompt = 'Translate the following text to $langName. Keep it simple and conversational, as if a teacher is speaking. Only output the translated text, no explanations: "$text"';

    try {
      final response = await _client.post(
        Uri.parse(kGroqApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $kGroqApiKey',
        },
        body: jsonEncode({
          'model': kModel,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.3,
          'max_tokens': 512,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        return text;
      }
    } catch (e) {
      return text;
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}