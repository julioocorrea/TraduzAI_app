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

  @HiveField(5) // Novo campo
  String examplePhrase;

  Translation({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.examplePhrase = '', // Inicializado como vazio
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Método para atualizar o exemplo
  Translation copyWith({String? examplePhrase}) {
    return Translation(
      originalText: originalText,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      examplePhrase: examplePhrase ?? this.examplePhrase,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'data': '${timestamp.day}/${timestamp.month}/${timestamp.year} '
               '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
      'textoOriginal': originalText,
      'textoTraduzido': translatedText,
      'idiomaOrigem': sourceLanguage,
      'idiomaDestino': targetLanguage,
      'exemplo': examplePhrase, // Novo campo no mapa
    };
  }
}