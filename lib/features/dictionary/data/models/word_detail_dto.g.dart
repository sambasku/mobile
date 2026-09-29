// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WordDetailDto _$WordDetailDtoFromJson(
  Map<String, dynamic> json,
) => _WordDetailDto(
  id: json['id'] as String,
  lemma: json['lemma'] as String,
  languageId: json['language_id'] as String,
  notes: json['notes'] as String?,
  wordType: json['word_type'] as String,
  status: json['status'] as String,
  isVerified: json['is_verified'] as bool,
  isCorrected: json['is_corrected'] as bool? ?? false,
  selfVerified: json['self_verified'] as bool? ?? false,
  verifiedAt: json['verified_at'] as String?,
  verifiedBy: json['verified_by'] == null
      ? null
      : WordVerifierDto.fromJson(json['verified_by'] as Map<String, dynamic>),
  createdBy: json['created_by'] == null
      ? null
      : WordVerifierDto.fromJson(json['created_by'] as Map<String, dynamic>),
  meanings:
      (json['meanings'] as List<dynamic>?)
          ?.map((e) => MeaningDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  usageLabels:
      (json['usage_labels'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  pronunciations:
      (json['pronunciations'] as List<dynamic>?)
          ?.map((e) => PronunciationDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  audios:
      (json['audios'] as List<dynamic>?)
          ?.map((e) => WordAudioDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => WordImageDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  relatedWords:
      (json['related_words'] as List<dynamic>?)
          ?.map((e) => RelatedWordDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  appearsIn:
      (json['appears_in'] as List<dynamic>?)
          ?.map((e) => RelatedWordDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  variants:
      (json['variants'] as List<dynamic>?)
          ?.map((e) => WordVariantDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  date: json['date'] as String?,
  isNewThisWeek: json['is_new_this_week'] as bool? ?? false,
);

Map<String, dynamic> _$WordDetailDtoToJson(_WordDetailDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lemma': instance.lemma,
      'language_id': instance.languageId,
      'notes': instance.notes,
      'word_type': instance.wordType,
      'status': instance.status,
      'is_verified': instance.isVerified,
      'is_corrected': instance.isCorrected,
      'self_verified': instance.selfVerified,
      'verified_at': instance.verifiedAt,
      'verified_by': instance.verifiedBy,
      'created_by': instance.createdBy,
      'meanings': instance.meanings,
      'categories': instance.categories,
      'usage_labels': instance.usageLabels,
      'pronunciations': instance.pronunciations,
      'audios': instance.audios,
      'images': instance.images,
      'related_words': instance.relatedWords,
      'appears_in': instance.appearsIn,
      'variants': instance.variants,
      'date': instance.date,
      'is_new_this_week': instance.isNewThisWeek,
    };

_WordVerifierDto _$WordVerifierDtoFromJson(Map<String, dynamic> json) =>
    _WordVerifierDto(
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      role: json['role'] as String,
    );

Map<String, dynamic> _$WordVerifierDtoToJson(_WordVerifierDto instance) =>
    <String, dynamic>{
      'username': instance.username,
      'display_name': instance.displayName,
      'role': instance.role,
    };

_MeaningDto _$MeaningDtoFromJson(Map<String, dynamic> json) => _MeaningDto(
  id: json['id'] as String,
  wordClass: json['word_class'] == null
      ? null
      : WordClassDto.fromJson(json['word_class'] as Map<String, dynamic>),
  inheritedFromMeaningId: json['inherited_from_meaning_id'] as String?,
  definition: json['definition'] as String?,
  orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
  translations:
      (json['translations'] as List<dynamic>?)
          ?.map((e) => TranslationDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  examples:
      (json['examples'] as List<dynamic>?)
          ?.map((e) => ExampleDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$MeaningDtoToJson(_MeaningDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'word_class': instance.wordClass,
      'inherited_from_meaning_id': instance.inheritedFromMeaningId,
      'definition': instance.definition,
      'order_index': instance.orderIndex,
      'translations': instance.translations,
      'examples': instance.examples,
    };

_WordClassDto _$WordClassDtoFromJson(Map<String, dynamic> json) =>
    _WordClassDto(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      alias: json['alias'] as String?,
      parentId: json['parent_id'] as String?,
    );

Map<String, dynamic> _$WordClassDtoToJson(_WordClassDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'alias': instance.alias,
      'parent_id': instance.parentId,
    };

_TranslationDto _$TranslationDtoFromJson(Map<String, dynamic> json) =>
    _TranslationDto(
      languageId: json['language_id'] as String,
      translationText: json['translation_text'] as String,
      translationType: json['translation_type'] as String,
    );

Map<String, dynamic> _$TranslationDtoToJson(_TranslationDto instance) =>
    <String, dynamic>{
      'language_id': instance.languageId,
      'translation_text': instance.translationText,
      'translation_type': instance.translationType,
    };

_ExampleDto _$ExampleDtoFromJson(Map<String, dynamic> json) => _ExampleDto(
  id: json['id'] as String,
  sourceLanguageId: json['source_language_id'] as String,
  sourceSentence: json['source_sentence'] as String,
  targetLanguageId: nullableStringFromJson(json['target_language_id']),
  targetSentence: nullableStringFromJson(json['target_sentence']),
  sourceType: nullableStringFromJson(json['source_type']),
  audios:
      (json['audios'] as List<dynamic>?)
          ?.map((e) => WordAudioDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ExampleDtoToJson(_ExampleDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'source_language_id': instance.sourceLanguageId,
      'source_sentence': instance.sourceSentence,
      'target_language_id': instance.targetLanguageId,
      'target_sentence': instance.targetSentence,
      'source_type': instance.sourceType,
      'audios': instance.audios,
    };

_CategoryDto _$CategoryDtoFromJson(Map<String, dynamic> json) =>
    _CategoryDto(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$CategoryDtoToJson(_CategoryDto instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_PronunciationDto _$PronunciationDtoFromJson(Map<String, dynamic> json) =>
    _PronunciationDto(
      id: json['id'] as String,
      notation: json['notation'] as String,
      value: json['value'] as String,
      dialectId: json['dialect_id'] as String?,
    );

Map<String, dynamic> _$PronunciationDtoToJson(_PronunciationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'notation': instance.notation,
      'value': instance.value,
      'dialect_id': instance.dialectId,
    };

_WordImageDto _$WordImageDtoFromJson(Map<String, dynamic> json) =>
    _WordImageDto(
      id: json['id'] as String,
      url: json['url'] as String,
      altText: json['alt_text'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? true,
      contentWarnings:
          (json['content_warnings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$WordImageDtoToJson(_WordImageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'alt_text': instance.altText,
      'is_primary': instance.isPrimary,
      'is_verified': instance.isVerified,
      'content_warnings': instance.contentWarnings,
    };

_RelatedWordDto _$RelatedWordDtoFromJson(Map<String, dynamic> json) =>
    _RelatedWordDto(
      wordId: json['word_id'] as String,
      lemma: json['lemma'] as String,
      relationType: json['relation_type'] as String,
    );

Map<String, dynamic> _$RelatedWordDtoToJson(_RelatedWordDto instance) =>
    <String, dynamic>{
      'word_id': instance.wordId,
      'lemma': instance.lemma,
      'relation_type': instance.relationType,
    };

_WordVariantDto _$WordVariantDtoFromJson(Map<String, dynamic> json) =>
    _WordVariantDto(
      id: json['id'] as String,
      form: json['form'] as String,
      variantType: json['variant_type'] as String,
      affixType: json['affix_type'] as String?,
      affixValue: json['affix_value'] as String?,
      dialectId: json['dialect_id'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$WordVariantDtoToJson(_WordVariantDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'form': instance.form,
      'variant_type': instance.variantType,
      'affix_type': instance.affixType,
      'affix_value': instance.affixValue,
      'dialect_id': instance.dialectId,
      'notes': instance.notes,
    };
