// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookmarkItemDto _$BookmarkItemDtoFromJson(Map<String, dynamic> json) =>
    _BookmarkItemDto(
      wordId: json['word_id'] as String,
      bookmarkedAt: json['bookmarked_at'] as String?,
      word: BookmarkWordDto.fromJson(json['word'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BookmarkItemDtoToJson(_BookmarkItemDto instance) =>
    <String, dynamic>{
      'word_id': instance.wordId,
      'bookmarked_at': instance.bookmarkedAt,
      'word': instance.word,
    };

_BookmarkWordDto _$BookmarkWordDtoFromJson(Map<String, dynamic> json) =>
    _BookmarkWordDto(
      id: json['id'] as String,
      lemma: json['lemma'] as String,
      wordType: json['word_type'] as String? ?? 'word',
      isVerified: json['is_verified'] as bool? ?? false,
      available: json['available'] as bool? ?? true,
    );

Map<String, dynamic> _$BookmarkWordDtoToJson(_BookmarkWordDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lemma': instance.lemma,
      'word_type': instance.wordType,
      'is_verified': instance.isVerified,
      'available': instance.available,
    };
