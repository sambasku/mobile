import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement_dto.freezed.dart';
part 'achievement_dto.g.dart';

/// Satu baris katalog + status kepemilikan (43-api-achievements.md).
///
/// `user_achievement_id` = award id; null = belum dimiliki (locked).
/// `is_active_border` hanya dikirim untuk reward_type `profile_border`.
@freezed
abstract class AchievementDto with _$AchievementDto {
  const factory AchievementDto({
    required String id,
    required String code,
    required String title,
    required String description,
    required String category,
    @JsonKey(name: 'reward_type') required String rewardType,
    @JsonKey(name: 'badge_url') String? badgeUrl,
    String? family,
    int? level,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'user_achievement_id') String? userAchievementId,

    /// Unix epoch detik (format waktu wire backend).
    @JsonKey(name: 'awarded_at') int? awardedAt,
    @JsonKey(name: 'is_active_border') @Default(false) bool isActiveBorder,
    AchievementProgressDto? progress,
  }) = _AchievementDto;

  factory AchievementDto.fromJson(Map<String, dynamic> json) =>
      _$AchievementDtoFromJson(json);
}

@freezed
abstract class AchievementProgressDto with _$AchievementProgressDto {
  const factory AchievementProgressDto({
    required int current,
    required int target,
  }) = _AchievementProgressDto;

  factory AchievementProgressDto.fromJson(Map<String, dynamic> json) =>
      _$AchievementProgressDtoFromJson(json);
}

@freezed
abstract class AchievementListDto with _$AchievementListDto {
  const factory AchievementListDto({
    @Default(<AchievementDto>[]) List<AchievementDto> items,
    @JsonKey(name: 'next_cursor') String? nextCursor,
  }) = _AchievementListDto;

  factory AchievementListDto.fromJson(Map<String, dynamic> json) =>
      _$AchievementListDtoFromJson(json);
}

@freezed
abstract class SetBorderRequestDto with _$SetBorderRequestDto {
  const factory SetBorderRequestDto({
    @JsonKey(name: 'border_id') required String? borderId,
  }) = _SetBorderRequestDto;

  factory SetBorderRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SetBorderRequestDtoFromJson(json);
}

@freezed
abstract class SetBorderResponseDto with _$SetBorderResponseDto {
  const factory SetBorderResponseDto({
    @JsonKey(name: 'active_border_id') String? activeBorderId,
  }) = _SetBorderResponseDto;

  factory SetBorderResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SetBorderResponseDtoFromJson(json);
}
