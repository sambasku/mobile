import 'package:freezed_annotation/freezed_annotation.dart';

import 'word_audio_dto.dart';

part 'word_detail_dto.freezed.dart';
part 'word_detail_dto.g.dart';

/// Response data GET /api/v1/words/:id (docs/json/word/get-word-detail.200.json).
@freezed
abstract class WordDetailDto with _$WordDetailDto {
  const factory WordDetailDto({
    required String id,
    required String lemma,
    @JsonKey(name: 'language_id') required String languageId,
    String? notes,
    @JsonKey(name: 'word_type') required String wordType,
    required String status,
    @JsonKey(name: 'is_verified') required bool isVerified,
    @JsonKey(name: 'is_corrected') @Default(false) bool isCorrected,
    @JsonKey(name: 'self_verified') @Default(false) bool selfVerified,
    @JsonKey(name: 'verified_at') String? verifiedAt,
    @JsonKey(name: 'verified_by') WordVerifierDto? verifiedBy,
    @JsonKey(name: 'created_by') WordVerifierDto? createdBy,
    @Default([]) List<MeaningDto> meanings,
    @Default([]) List<CategoryDto> categories,
    @JsonKey(name: 'usage_labels') @Default([]) List<String> usageLabels,
    @Default([]) List<PronunciationDto> pronunciations,
    @Default([]) List<WordAudioDto> audios,
    @Default([]) List<WordImageDto> images,
    @JsonKey(name: 'related_words')
    @Default([])
    List<RelatedWordDto> relatedWords,
    @JsonKey(name: 'appears_in') @Default([]) List<RelatedWordDto> appearsIn,
    @Default([]) List<WordVariantDto> variants,

    /// Hanya diisi GET /words/today; detail biasa mengabaikan (null/false).
    String? date,
    @JsonKey(name: 'is_new_this_week') @Default(false) bool isNewThisWeek,
  }) = _WordDetailDto;

  factory WordDetailDto.fromJson(Map<String, dynamic> json) =>
      _$WordDetailDtoFromJson(json);
}

@freezed
abstract class WordVerifierDto with _$WordVerifierDto {
  const factory WordVerifierDto({
    required String username,
    @JsonKey(name: 'display_name') String? displayName,
    required String role,
  }) = _WordVerifierDto;

  factory WordVerifierDto.fromJson(Map<String, dynamic> json) =>
      _$WordVerifierDtoFromJson(json);
}

@freezed
abstract class MeaningDto with _$MeaningDto {
  const factory MeaningDto({
    required String id,
    @JsonKey(name: 'word_class') WordClassDto? wordClass,
    @JsonKey(name: 'inherited_from_meaning_id') String? inheritedFromMeaningId,
    String? definition,
    @JsonKey(name: 'order_index') @Default(0) int orderIndex,
    @Default([]) List<TranslationDto> translations,
    @Default([]) List<ExampleDto> examples,
  }) = _MeaningDto;

  factory MeaningDto.fromJson(Map<String, dynamic> json) =>
      _$MeaningDtoFromJson(json);
}

@freezed
abstract class WordClassDto with _$WordClassDto {
  const factory WordClassDto({
    required String id,
    required String code,
    required String name,
    String? alias,
    @JsonKey(name: 'parent_id') String? parentId,
  }) = _WordClassDto;

  factory WordClassDto.fromJson(Map<String, dynamic> json) =>
      _$WordClassDtoFromJson(json);
}

@freezed
abstract class TranslationDto with _$TranslationDto {
  const factory TranslationDto({
    @JsonKey(name: 'language_id') required String languageId,
    @JsonKey(name: 'translation_text') required String translationText,
    @JsonKey(name: 'translation_type') required String translationType,
  }) = _TranslationDto;

  factory TranslationDto.fromJson(Map<String, dynamic> json) =>
      _$TranslationDtoFromJson(json);
}

/// Kolom contoh yang boleh null di API (`examples.target_sentence`,
/// `target_language_id`, `source_type`). `as String` pada null melempar
/// `Null is not a subtype of type String` dan menggagalkan seluruh detail.
String? nullableStringFromJson(Object? value) => value is String ? value : null;

@freezed
abstract class ExampleDto with _$ExampleDto {
  const factory ExampleDto({
    required String id,
    @JsonKey(name: 'source_language_id') required String sourceLanguageId,
    @JsonKey(name: 'source_sentence') required String sourceSentence,
    @JsonKey(name: 'target_language_id', fromJson: nullableStringFromJson)
    String? targetLanguageId,
    @JsonKey(name: 'target_sentence', fromJson: nullableStringFromJson)
    String? targetSentence,
    @JsonKey(name: 'source_type', fromJson: nullableStringFromJson)
    String? sourceType,
    @Default([]) List<WordAudioDto> audios,
  }) = _ExampleDto;

  factory ExampleDto.fromJson(Map<String, dynamic> json) =>
      _$ExampleDtoFromJson(json);
}

@freezed
abstract class CategoryDto with _$CategoryDto {
  const factory CategoryDto({required String id, required String name}) =
      _CategoryDto;

  factory CategoryDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryDtoFromJson(json);
}

@freezed
abstract class PronunciationDto with _$PronunciationDto {
  const factory PronunciationDto({
    required String id,
    required String notation,
    required String value,
    @JsonKey(name: 'dialect_id') String? dialectId,
  }) = _PronunciationDto;

  factory PronunciationDto.fromJson(Map<String, dynamic> json) =>
      _$PronunciationDtoFromJson(json);
}

@freezed
abstract class WordImageDto with _$WordImageDto {
  const factory WordImageDto({
    required String id,
    required String url,
    @JsonKey(name: 'alt_text') String? altText,
    @JsonKey(name: 'is_primary') @Default(false) bool isPrimary,
    /// false = gambar staging belum diverifikasi. Default true agar
    /// response lama (tanpa field ini) tetap bekerja normal.
    @JsonKey(name: 'is_verified') @Default(true) bool isVerified,
    /// Peringatan konten visual per gambar. V1: ['kekerasan'].
    @JsonKey(name: 'content_warnings') @Default([]) List<String> contentWarnings,
    /// Kredit foto stock (+ `provider`); null = upload / data lama.
    Map<String, dynamic>? attribution,
  }) = _WordImageDto;

  factory WordImageDto.fromJson(Map<String, dynamic> json) =>
      _$WordImageDtoFromJson(json);
}

@freezed
abstract class RelatedWordDto with _$RelatedWordDto {
  const factory RelatedWordDto({
    @JsonKey(name: 'word_id') required String wordId,
    required String lemma,
    @JsonKey(name: 'relation_type') required String relationType,
  }) = _RelatedWordDto;

  factory RelatedWordDto.fromJson(Map<String, dynamic> json) =>
      _$RelatedWordDtoFromJson(json);
}

@freezed
abstract class WordVariantDto with _$WordVariantDto {
  const factory WordVariantDto({
    required String id,
    required String form,
    @JsonKey(name: 'variant_type') required String variantType,
    @JsonKey(name: 'affix_type') String? affixType,
    @JsonKey(name: 'affix_value') String? affixValue,
    @JsonKey(name: 'dialect_id') String? dialectId,
    String? notes,
  }) = _WordVariantDto;

  factory WordVariantDto.fromJson(Map<String, dynamic> json) =>
      _$WordVariantDtoFromJson(json);
}
