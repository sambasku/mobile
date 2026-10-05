import 'package:freezed_annotation/freezed_annotation.dart';
part 'public_profile_dto.freezed.dart';
part 'public_profile_dto.g.dart';

@freezed
abstract class PublicProfileDto with _$PublicProfileDto {
  const factory PublicProfileDto({
    required String username,
    @JsonKey(name: 'display_name') String? displayName,
    String? bio,
    required String role,
    @JsonKey(name: 'is_verifier') @Default(false) bool isVerifier,
    @JsonKey(name: 'joined_at') required String joinedAt,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    required PublicProfileStatsDto stats,
  }) = _PublicProfileDto;

  factory PublicProfileDto.fromJson(Map<String, dynamic> json) =>
      _$PublicProfileDtoFromJson(json);
}

@freezed
abstract class PublicProfileStatsDto with _$PublicProfileStatsDto {
  const factory PublicProfileStatsDto({
    @JsonKey(name: 'contributions_approved') @Default(0) int contributionsApproved,
    @JsonKey(name: 'verifications_done') @Default(0) int verificationsDone,
    @JsonKey(name: 'comments_published') @Default(0) int commentsPublished,
  }) = _PublicProfileStatsDto;

  factory PublicProfileStatsDto.fromJson(Map<String, dynamic> json) =>
      _$PublicProfileStatsDtoFromJson(json);
}

@freezed
abstract class PublicActivityItemDto with _$PublicActivityItemDto {
  const factory PublicActivityItemDto({
    required String id,
    required String kind,
    @JsonKey(name: 'occurred_at') required String occurredAt,
    @JsonKey(name: 'word_id') String? wordId,
    String? lemma,
    required String summary,
  }) = _PublicActivityItemDto;

  factory PublicActivityItemDto.fromJson(Map<String, dynamic> json) =>
      _$PublicActivityItemDtoFromJson(json);
}

@freezed
abstract class PublicActivityMetaDto with _$PublicActivityMetaDto {
  const factory PublicActivityMetaDto({
    required int limit,
    @JsonKey(name: 'next_cursor') String? nextCursor,
    @JsonKey(name: 'has_more') required bool hasMore,
  }) = _PublicActivityMetaDto;

  factory PublicActivityMetaDto.fromJson(Map<String, dynamic> json) =>
      _$PublicActivityMetaDtoFromJson(json);
}

@freezed
abstract class PublicActivityDto with _$PublicActivityDto {
  const factory PublicActivityDto({
    @Default(<PublicActivityItemDto>[]) List<PublicActivityItemDto> items,
    PublicActivityMetaDto? meta,
  }) = _PublicActivityDto;

  factory PublicActivityDto.fromJson(Map<String, dynamic> json) =>
      _$PublicActivityDtoFromJson(json);
}

@freezed
abstract class MentionSuggestItemDto with _$MentionSuggestItemDto {
  const factory MentionSuggestItemDto({
    required String id,
    required String username,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _MentionSuggestItemDto;

  factory MentionSuggestItemDto.fromJson(Map<String, dynamic> json) =>
      _$MentionSuggestItemDtoFromJson(json);
}

@freezed
abstract class MentionSuggestDto with _$MentionSuggestDto {
  const factory MentionSuggestDto({
    @Default(<MentionSuggestItemDto>[]) List<MentionSuggestItemDto> items,
  }) = _MentionSuggestDto;

  factory MentionSuggestDto.fromJson(Map<String, dynamic> json) =>
      _$MentionSuggestDtoFromJson(json);
}