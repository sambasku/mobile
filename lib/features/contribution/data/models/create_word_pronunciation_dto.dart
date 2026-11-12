import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_word_pronunciation_dto.freezed.dart';
part 'create_word_pronunciation_dto.g.dart';

/// Nested `pronunciation` pada POST /contributions/words (opsional).
@freezed
abstract class CreateWordPronunciationDto with _$CreateWordPronunciationDto {
  const factory CreateWordPronunciationDto({
    @Default('ipa') String notation,
    required String value,
  }) = _CreateWordPronunciationDto;

  factory CreateWordPronunciationDto.fromJson(Map<String, dynamic> json) =>
      _$CreateWordPronunciationDtoFromJson(json);
}
