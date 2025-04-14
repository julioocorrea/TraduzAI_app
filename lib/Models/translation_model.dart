import 'package:hive/hive.dart';

part 'translation_model.g.dart';

@HiveType(typeId: 0)
class Translation {
  @HiveField(0)
  final String originalText;
  
  @HiveField(1)
  final String translatedText;
  
  @HiveField(2)
  final String sourceLanguage;
  
  @HiveField(3)
  final String targetLanguage;
  
  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  String examplePhrase;

  Translation({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.examplePhrase = '',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now() {
    // Normaliza os caracteres ao criar o objeto
    examplePhrase = _normalizeCharacters(examplePhrase);
  }

  String _normalizeCharacters(String text) {
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
        .replaceAll('Â', '');
  }
  
  // Método para cópia com novos valores (mais completo)
  Translation copyWith({
    String? originalText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    String? examplePhrase,
    DateTime? timestamp,
  }) {
    return Translation(
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      examplePhrase: examplePhrase ?? this.examplePhrase,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Método para converter para mapa (mais consistente)
  Map<String, dynamic> toMap() {
    return {
      'originalText': originalText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'timestamp': timestamp.toString(),
      'examplePhrase': examplePhrase,
      'formattedDate': '${timestamp.day}/${timestamp.month}/${timestamp.year} '
          '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
    };
  }

  // Método para facilitar a cópia para edição
  Translation clone() {
    return copyWith();
  }
}