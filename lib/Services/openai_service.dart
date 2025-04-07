import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static final String _apiKey = '****'; 
  static const String _baseUrl = '****'; 

  static Future<String> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'api-key': _apiKey, 
      },
      body: jsonEncode({
        'messages': [ 
          {
            'role': 'system',
            'content': 'Translate from $sourceLanguage to $targetLanguage. Return ONLY the translated text.'
          },
          {
            'role': 'user',
            'content': text
          }
        ],
        'temperature': 0.3,
        'max_tokens': 1000,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('Failed to translate: ${response.statusCode} - ${response.body}');
    }
  }
}
