import 'package:freezed_annotation/freezed_annotation.dart';

import 'create_word_example_dto.dart';
import 'create_word_translation_dto.dart';

part 'create_word_meaning_dto.freezed.dart';
part 'create_word_meaning_dto.g.dart';

/// Satu item array `meanings` (wajib min 1) sesuai backend
/// `createWordBodySchema`. Form mobile boleh mengirim beberapa makna;
/// transform list → DTO di `ContributionRepositoryImpl`.
@freezed
abstract class CreateWordMeaningDto with _$CreateWordMeaningDto {
  const factory CreateWordMeaningDto({
    @JsonKey(name: 'word_class_id') required String wordClassId,
    required String definition,
    // false = placeholder "-" (kontributor belum tahu definisi Indonesia).
    @JsonKey(name: 'is_have_definition') @Default(true) bool isHaveDefinition,
    // false = sengaja tanpa padanan kata Indonesia.
    @JsonKey(name: 'is_have_translation') @Default(true) bool isHaveTranslation,
    // Provenance: manual | kbbi | kbbi_edited
    @JsonKey(name: 'meaning_source') @Default('manual') String meaningSource,
    @JsonKey(name: 'order_index') @Default(1) int orderIndex,
    required List<CreateWordTranslationDto> translations,
    @JsonKey(includeIfNull: false) List<CreateWordExampleDto>? examples,
  }) = _CreateWordMeaningDto;

  factory CreateWordMeaningDto.fromJson(Map<String, dynamic> json) =>
      _$CreateWordMeaningDtoFromJson(json);
}
