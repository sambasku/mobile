// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duplicate_confirm_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DuplicateConfirmResponseDto _$DuplicateConfirmResponseDtoFromJson(
  Map<String, dynamic> json,
) => _DuplicateConfirmResponseDto(
  wordId: json['word_id'] as String,
  meaningId: json['meaning_id'] as String,
  lemma: json['lemma'] as String,
  myVote: (json['my_vote'] as num?)?.toInt(),
  upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
  downvotes: (json['downvotes'] as num?)?.toInt() ?? 0,
  message: json['message'] as String,
);

Map<String, dynamic> _$DuplicateConfirmResponseDtoToJson(
  _DuplicateConfirmResponseDto instance,
) => <String, dynamic>{
  'word_id': instance.wordId,
  'meaning_id': instance.meaningId,
  'lemma': instance.lemma,
  'my_vote': instance.myVote,
  'upvotes': instance.upvotes,
  'downvotes': instance.downvotes,
  'message': instance.message,
};
