import 'package:hive_flutter/hive_flutter.dart';
import '../models/translation_model.dart';

class HiveService {
  static const String _boxName = 'translations_box';
  static const int _maxTranslations = 20; // Aumentei o limite padrão

  static Future<void> init() async {
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TranslationAdapter());
    }
    
    await Hive.openBox<Translation>(_boxName);
  }

  static Box<Translation> get _box => Hive.box<Translation>(_boxName);

  static Future<void> saveTranslation(Translation translation) async {
    final translations = _box.values.toList();
    
    // Remove as traduções mais antigas se atingir o limite
    while (translations.length >= _maxTranslations) {
      await _box.deleteAt(0);
      translations.removeAt(0);
    }
    
    await _box.add(translation);
  }

  static List<Translation> getTranslations() {
    return _box.values.toList().reversed.toList();
  }

  static Future<void> updateTranslation(int index, Translation updated) async {
    final realIndex = (_box.length - 1) - index;
    await _box.putAt(realIndex, updated);
  }

  static Future<void> deleteTranslation(int index) async {
    final realIndex = (_box.length - 1) - index;
    await _box.deleteAt(realIndex);
  }

  static Future<void> clearHistory() async {
    await _box.clear();
  }

  static int get translationsCount => _box.length;

  // Novo método para obter uma tradução por índice
  static Translation? getTranslation(int index) {
    final realIndex = (_box.length - 1) - index;
    if (realIndex >= 0 && realIndex < _box.length) {
      return _box.getAt(realIndex);
    }
    return null;
  }

  // Novo método para verificar se a box está vazia
  static bool get isEmpty => _box.isEmpty;
}