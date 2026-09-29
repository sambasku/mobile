// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WordSummaryDto _$WordSummaryDtoFromJson(Map<String, dynamic> json) =>
    _WordSummaryDto(
      id: json['id'] as String,
      lemma: json['lemma'] as String,
      languageId: json['language_id'] as String,
      languageCode: json['language_code'] as String,
      wordType: json['word_type'] as String,
      status: json['status'] as String,
      isVerified: json['is_verified'] as bool,
      matchedTranslation: json['matched_translation'] as String?,
      sense: json['sense'] as String?,
      approvedAt: json['approved_at'] as String?,
      usageLabels:
          (json['usage_labels'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$WordSummaryDtoToJson(_WordSummaryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lemma': instance.lemma,
      'language_id': instance.languageId,
      'language_code': instance.languageCode,
      'word_type': instance.wordType,
      'status': instance.status,
      'is_verified': instance.isVerified,
      'matched_translation': instance.matchedTranslation,
      'sense': instance.sense,
      'approved_at': instance.approvedAt,
      'usage_labels': instance.usageLabels,
    };
