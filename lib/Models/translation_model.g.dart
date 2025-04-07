// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TranslationAdapter extends TypeAdapter<Translation> {
  @override
  final int typeId = 0;

  @override
  Translation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Translation(
      originalText: fields[0] as String,
      translatedText: fields[1] as String,
      sourceLanguage: fields[2] as String,
      targetLanguage: fields[3] as String,
      examplePhrase: fields[5] as String,
      timestamp: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Translation obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.originalText)
      ..writeByte(1)
      ..write(obj.translatedText)
      ..writeByte(2)
      ..write(obj.sourceLanguage)
      ..writeByte(3)
      ..write(obj.targetLanguage)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.examplePhrase);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
