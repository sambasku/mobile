// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_word_image_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateWordImageDto _$CreateWordImageDtoFromJson(Map<String, dynamic> json) =>
    _CreateWordImageDto(
      url: json['url'] as String,
      providerFileId: json['provider_file_id'] as String,
      provider: json['provider'] as String?,
      sha: json['sha'] as String?,
      altText: json['alt_text'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
      contentWarnings:
          (json['content_warnings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CreateWordImageDtoToJson(_CreateWordImageDto instance) =>
    <String, dynamic>{
      'url': instance.url,
      'provider_file_id': instance.providerFileId,
      'provider': ?instance.provider,
      'sha': ?instance.sha,
      'alt_text': ?instance.altText,
      'is_primary': instance.isPrimary,
      'content_warnings': instance.contentWarnings,
    };
