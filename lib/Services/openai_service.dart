import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static final String _apiKey = 'e4f569aaaa0e44fda73c8efbf1213b77';
  static const String _baseUrl = 'https://testecopilot-fdc.openai.azure.com/openai/deployments/gpt-4o/chat/completions?api-version=2023-05-15';

  static Future<Map<String, String>> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8', // Adicione charset
          'api-key': _apiKey,
        },
        body: utf8.encode(jsonEncode({ // Use utf8.encode para garantir a codificação
          'messages': [
            {
              'role': 'system',
              'content': '''
              Você é um tradutor profissional. Siga estas instruções:
              1. Traduza o texto de $sourceLanguage para $targetLanguage.
              2. Crie uma frase de exemplo prática usando o texto traduzido em $targetLanguage.
              3. Retorne um objeto JSON com duas chaves:
                 - "translation": contendo APENAS o texto traduzido
                 - "example": contendo a frase de exemplo
              '''
            },
            {
              'role': 'user',
              'content': text
            }
          ],
          'temperature': 0.3,
          'max_tokens': 1000,
          'response_format': {'type': 'json_object'}
        })),
      );

      if (response.statusCode == 200) {
        // Decodifique a resposta usando utf8
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        final content = data['choices'][0]['message']['content'].trim();
        
        try {
          final jsonResponse = jsonDecode(content);
          return {
            'translation': _fixSpecialCharacters(jsonResponse['translation']?.toString() ?? ''),
            'example': _fixSpecialCharacters(jsonResponse['example']?.toString() ?? ''),
          };
        } catch (e) {
          return {
            'translation': _fixSpecialCharacters(content),
            'example': '',
          };
        }
      } else {
        throw Exception('Falha na tradução: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: ${e.toString()}');
    }
  }

  // Função auxiliar para corrigir caracteres especiais
  static String _fixSpecialCharacters(String text) {
    return text
        .replaceAll('Ã¡', 'á')
        .replaceAll('Ã©', 'é')
        .replaceAll('Ã', 'í')
        .replaceAll('Ã³', 'ó')
        .replaceAll('Ãº', 'ú')
        .replaceAll('Ã£', 'ã')
        .replaceAll('Ãµ', 'õ')
        .replaceAll('Ã¢', 'â')
        .replaceAll('Ãª', 'ê')
        .replaceAll('Ã®', 'î')
        .replaceAll('Ã´', 'ô')
        .replaceAll('Ã»', 'û')
        .replaceAll('Ã§', 'ç')
        .replaceAll('Ã‰', 'É')
        .replaceAll('Ã€', 'À')
        .replaceAll('Ã‡', 'Ç')
        .replaceAll('Â', ''); // Remove caracteres Â extras
  }
}