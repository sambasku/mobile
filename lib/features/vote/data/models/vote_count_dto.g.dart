// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_count_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoteCountDto _$VoteCountDtoFromJson(Map<String, dynamic> json) =>
    _VoteCountDto(
      targetType: json['target_type'] as String,
      targetId: json['target_id'] as String,
      upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
      downvotes: (json['downvotes'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$VoteCountDtoToJson(_VoteCountDto instance) =>
    <String, dynamic>{
      'target_type': instance.targetType,
      'target_id': instance.targetId,
      'upvotes': instance.upvotes,
      'downvotes': instance.downvotes,
    };
