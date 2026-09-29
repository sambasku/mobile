// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_word_translation_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateWordTranslationDto _$CreateWordTranslationDtoFromJson(
  Map<String, dynamic> json,
) => _CreateWordTranslationDto(
  languageId: json['language_id'] as String,
  translationText: json['translation_text'] as String,
  translationType: json['translation_type'] as String? ?? 'direct',
);

Map<String, dynamic> _$CreateWordTranslationDtoToJson(
  _CreateWordTranslationDto instance,
) => <String, dynamic>{
  'language_id': instance.languageId,
  'translation_text': instance.translationText,
  'translation_type': instance.translationType,
};
