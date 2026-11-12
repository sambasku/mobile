import 'package:freezed_annotation/freezed_annotation.dart';

import 'create_word_image_dto.dart';
import 'create_word_meaning_dto.dart';
import 'create_word_pronunciation_dto.dart';
import 'create_word_related_word_dto.dart';
import 'create_word_variant_dto.dart';

part 'create_word_request_dto.freezed.dart';
part 'create_word_request_dto.g.dart';

/// Body request POST /api/v1/contributions/words.
///
/// Bentuknya persis `anonWordSchema` backend = `createWordBodySchema`
/// minus `status` (backend memaksa `published` → approval gate
/// pending_review). Anonim boleh mengirim `category_ids` kosong.
///
/// `dialect_id`, `notes`, `variants`, `related_words`, `images`,
/// `pronunciation` TIDAK ikut dikirim saat null (`includeIfNull: false`) -
/// backend menolak nilai null pada field `z.*.optional()` (Zod optional ≠
/// nullable).
///
/// Antarmuka datar form (word_class_id/definition/translation_texts)
/// di-transform menjadi `meanings[...]` di ContributionRepositoryImpl.
@freezed
abstract class CreateWordRequestDto with _$CreateWordRequestDto {
  const factory CreateWordRequestDto({
    required String lemma,
    @JsonKey(name: 'language_id') required String languageId,
    @JsonKey(name: 'dialect_id', includeIfNull: false) String? dialectId,
    @JsonKey(name: 'word_type') @Default('word') String wordType,
    @JsonKey(name: 'meanings') required List<CreateWordMeaningDto> meanings,
    @JsonKey(name: 'category_ids') @Default([]) List<String> categoryIds,
    @JsonKey(name: 'usage_labels') @Default([]) List<String> usageLabels,
    @JsonKey(name: 'notes', includeIfNull: false) String? notes,
    @JsonKey(name: 'variants', includeIfNull: false)
    List<CreateWordVariantDto>? variants,
    @JsonKey(name: 'related_words', includeIfNull: false)
    List<CreateWordRelatedWordDto>? relatedWords,
    @JsonKey(name: 'images', includeIfNull: false)
    List<CreateWordImageDto>? images,
    @JsonKey(name: 'pronunciation', includeIfNull: false)
    CreateWordPronunciationDto? pronunciation,
    @JsonKey(name: 'search_miss_id', includeIfNull: false) String? searchMissId,
  }) = _CreateWordRequestDto;

  factory CreateWordRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateWordRequestDtoFromJson(json);
}
