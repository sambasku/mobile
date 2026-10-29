// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_image_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommentImageDto _$CommentImageDtoFromJson(Map<String, dynamic> json) =>
    _CommentImageDto(
      status: json['status'] as String,
      publicUrl: json['public_url'] as String?,
      contentWarnings:
          (json['content_warnings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$CommentImageDtoToJson(_CommentImageDto instance) =>
    <String, dynamic>{
      'status': instance.status,
      'public_url': instance.publicUrl,
      'content_warnings': instance.contentWarnings,
    };

_CreateCommentImageInputDto _$CreateCommentImageInputDtoFromJson(
  Map<String, dynamic> json,
) => _CreateCommentImageInputDto(
  url: json['url'] as String,
  providerFileId: json['provider_file_id'] as String,
);

Map<String, dynamic> _$CreateCommentImageInputDtoToJson(
  _CreateCommentImageInputDto instance,
) => <String, dynamic>{
  'url': instance.url,
  'provider_file_id': instance.providerFileId,
};
