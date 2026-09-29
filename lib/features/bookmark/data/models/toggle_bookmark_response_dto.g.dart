// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toggle_bookmark_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ToggleBookmarkResponseDto _$ToggleBookmarkResponseDtoFromJson(
  Map<String, dynamic> json,
) => _ToggleBookmarkResponseDto(
  wordId: json['word_id'] as String,
  isBookmarked: json['is_bookmarked'] as bool? ?? false,
  bookmarkedAt: json['bookmarked_at'] as String?,
);

Map<String, dynamic> _$ToggleBookmarkResponseDtoToJson(
  _ToggleBookmarkResponseDto instance,
) => <String, dynamic>{
  'word_id': instance.wordId,
  'is_bookmarked': instance.isBookmarked,
  'bookmarked_at': instance.bookmarkedAt,
};
