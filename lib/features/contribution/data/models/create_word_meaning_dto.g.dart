// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_word_meaning_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateWordMeaningDto _$CreateWordMeaningDtoFromJson(
  Map<String, dynamic> json,
) => _CreateWordMeaningDto(
  wordClassId: json['word_class_id'] as String,
  definition: json['definition'] as String,
  isHaveDefinition: json['is_have_definition'] as bool? ?? true,
  isHaveTranslation: json['is_have_translation'] as bool? ?? true,
  meaningSource: json['meaning_source'] as String? ?? 'manual',
  orderIndex: (json['order_index'] as num?)?.toInt() ?? 1,
  translations: (json['translations'] as List<dynamic>)
      .map((e) => CreateWordTranslationDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  examples: (json['examples'] as List<dynamic>?)
      ?.map((e) => CreateWordExampleDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CreateWordMeaningDtoToJson(
  _CreateWordMeaningDto instance,
) => <String, dynamic>{
  'word_class_id': instance.wordClassId,
  'definition': instance.definition,
  'is_have_definition': instance.isHaveDefinition,
  'is_have_translation': instance.isHaveTranslation,
  'meaning_source': instance.meaningSource,
  'order_index': instance.orderIndex,
  'translations': instance.translations,
  'examples': ?instance.examples,
};
