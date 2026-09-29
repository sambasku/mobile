// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_word_example_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateWordExampleDto _$CreateWordExampleDtoFromJson(
  Map<String, dynamic> json,
) => _CreateWordExampleDto(
  sourceLanguageId: json['source_language_id'] as String,
  sourceSentence: json['source_sentence'] as String,
);

Map<String, dynamic> _$CreateWordExampleDtoToJson(
  _CreateWordExampleDto instance,
) => <String, dynamic>{
  'source_language_id': instance.sourceLanguageId,
  'source_sentence': instance.sourceSentence,
};
