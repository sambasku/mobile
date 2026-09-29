// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_audio_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WordAudioDto _$WordAudioDtoFromJson(Map<String, dynamic> json) =>
    _WordAudioDto(
      id: json['id'] as String,
      url: json['url'] as String,
      dialectId: json['dialect_id'] as String?,
      speakerName: json['speaker_name'] as String?,
      durationMs: (json['duration_ms'] as num?)?.toInt(),
      isPrimary: json['is_primary'] as bool? ?? false,
      mimeType: json['mime_type'] as String?,
      isVerified: json['is_verified'] as bool? ?? true,
    );

Map<String, dynamic> _$WordAudioDtoToJson(_WordAudioDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'dialect_id': instance.dialectId,
      'speaker_name': instance.speakerName,
      'duration_ms': instance.durationMs,
      'is_primary': instance.isPrimary,
      'mime_type': instance.mimeType,
      'is_verified': instance.isVerified,
    };
