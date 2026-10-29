// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_comment_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateCommentRequestDto _$CreateCommentRequestDtoFromJson(
  Map<String, dynamic> json,
) => _CreateCommentRequestDto(
  body: json['body'] as String? ?? '',
  image: json['image'] == null
      ? null
      : CreateCommentImageInputDto.fromJson(
          json['image'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$CreateCommentRequestDtoToJson(
  _CreateCommentRequestDto instance,
) => <String, dynamic>{'body': instance.body, 'image': instance.image};
