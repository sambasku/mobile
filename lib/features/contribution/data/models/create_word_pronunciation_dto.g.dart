// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_word_pronunciation_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateWordPronunciationDto _$CreateWordPronunciationDtoFromJson(
  Map<String, dynamic> json,
) => _CreateWordPronunciationDto(
  notation: json['notation'] as String? ?? 'ipa',
  value: json['value'] as String,
);

Map<String, dynamic> _$CreateWordPronunciationDtoToJson(
  _CreateWordPronunciationDto instance,
) => <String, dynamic>{'notation': instance.notation, 'value': instance.value};
