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
    @JsonKey(name: 'contributions_approved')
    @Default(0)
    int contributionsApproved,
    @JsonKey(name: 'verifications_done') @Default(0) int verificationsDone,
    @JsonKey(name: 'comments_published') @Default(0) int commentsPublished,
  }) = _PublicProfileStatsDto;

  factory PublicProfileStatsDto.fromJson(Map<String, dynamic> json) =>
      _$PublicProfileStatsDtoFromJson(json);
}

@freezed
abstract class PublicActivityItemDto with _$PublicActivityItemDto {
  const factory PublicActivityItemDto({
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
abstract class PublicActivityDto with _$PublicActivityDto {
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory PublicActivityDto({
    @Default([]) List<PublicActivityItemDto> items,
  }) = _PublicActivityDto;

  factory PublicActivityDto.fromJson(Map<String, dynamic> json) =>
      _$PublicActivityDtoFromJson(json);
}
