// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_toggle_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoteToggleResponseDto _$VoteToggleResponseDtoFromJson(
  Map<String, dynamic> json,
) => _VoteToggleResponseDto(
  targetType: json['target_type'] as String,
  targetId: json['target_id'] as String,
  myVote: (json['my_vote'] as num?)?.toInt(),
  upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
  downvotes: (json['downvotes'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$VoteToggleResponseDtoToJson(
  _VoteToggleResponseDto instance,
) => <String, dynamic>{
  'target_type': instance.targetType,
  'target_id': instance.targetId,
  'my_vote': instance.myVote,
  'upvotes': instance.upvotes,
  'downvotes': instance.downvotes,
};
