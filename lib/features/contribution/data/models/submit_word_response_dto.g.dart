// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_word_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubmitWordResponseDto _$SubmitWordResponseDtoFromJson(
  Map<String, dynamic> json,
) => _SubmitWordResponseDto(
  wordId: json['word_id'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$SubmitWordResponseDtoToJson(
  _SubmitWordResponseDto instance,
) => <String, dynamic>{'word_id': instance.wordId, 'status': instance.status};
