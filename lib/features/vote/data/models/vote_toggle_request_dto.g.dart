// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_toggle_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoteToggleRequestDto _$VoteToggleRequestDtoFromJson(
  Map<String, dynamic> json,
) => _VoteToggleRequestDto(
  targetType: json['target_type'] as String,
  targetId: json['target_id'] as String,
  value: (json['value'] as num).toInt(),
);

Map<String, dynamic> _$VoteToggleRequestDtoToJson(
  _VoteToggleRequestDto instance,
) => <String, dynamic>{
  'target_type': instance.targetType,
  'target_id': instance.targetId,
  'value': instance.value,
};
