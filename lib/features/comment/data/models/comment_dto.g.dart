// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommentDto _$CommentDtoFromJson(Map<String, dynamic> json) => _CommentDto(
  id: json['id'] as String,
  wordId: json['word_id'] as String,
  userId: json['user_id'] as String,
  username: json['username'] as String?,
  displayName: json['display_name'] as String?,
  body: json['body'] as String?,
  createdAt: json['created_at'] as String?,
  upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
  downvotes: (json['downvotes'] as num?)?.toInt() ?? 0,
  status: json['status'] as String?,
);

Map<String, dynamic> _$CommentDtoToJson(_CommentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'word_id': instance.wordId,
      'user_id': instance.userId,
      'username': instance.username,
      'display_name': instance.displayName,
      'body': instance.body,
      'created_at': instance.createdAt,
      'upvotes': instance.upvotes,
      'downvotes': instance.downvotes,
      'status': instance.status,
    };
