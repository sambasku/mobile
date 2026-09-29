import 'package:freezed_annotation/freezed_annotation.dart';

part 'duplicate_confirm_response_dto.freezed.dart';
part 'duplicate_confirm_response_dto.g.dart';

@freezed
abstract class DuplicateConfirmResponseDto with _$DuplicateConfirmResponseDto {
  const factory DuplicateConfirmResponseDto({
    @JsonKey(name: 'word_id') required String wordId,
    @JsonKey(name: 'meaning_id') required String meaningId,
    required String lemma,
    @JsonKey(name: 'my_vote') int? myVote,
    @Default(0) int upvotes,
    @Default(0) int downvotes,
    required String message,
  }) = _DuplicateConfirmResponseDto;

  factory DuplicateConfirmResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DuplicateConfirmResponseDtoFromJson(json);
}
