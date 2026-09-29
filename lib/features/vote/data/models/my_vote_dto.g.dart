// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_vote_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MyVoteDto _$MyVoteDtoFromJson(Map<String, dynamic> json) => _MyVoteDto(
  targetType: json['target_type'] as String,
  targetId: json['target_id'] as String,
  value: (json['value'] as num).toInt(),
);

Map<String, dynamic> _$MyVoteDtoToJson(_MyVoteDto instance) =>
    <String, dynamic>{
      'target_type': instance.targetType,
      'target_id': instance.targetId,
      'value': instance.value,
    };
