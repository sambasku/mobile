import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_profile_dto.freezed.dart';
part 'my_profile_dto.g.dart';

@freezed
abstract class MyProfileDto with _$MyProfileDto {
  const factory MyProfileDto({
    required String username,
    @JsonKey(name: 'display_name') required String displayName,
    String? bio,
    /// `native` | `learner` | null.
    @JsonKey(name: 'speaker_status') String? speakerStatus,
    @JsonKey(name: 'region_id') String? regionId,
    @JsonKey(name: 'village_id') String? villageId,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'has_read_contribution_guide') @Default(false) bool hasReadContributionGuide,
    /// True bila user belum menyetujui terms/privacy versi aktif.
    @JsonKey(name: 'requires_consent') @Default(false) bool requiresConsent,
    @JsonKey(name: 'notify_streak_reminder')
    @Default(true)
    bool notifyStreakReminder,
    @JsonKey(name: 'notify_level_up') @Default(true) bool notifyLevelUp,
    @JsonKey(name: 'username_changed_at') String? usernameChangedAt,
    @JsonKey(name: 'username_change_allowed_at') String? usernameChangeAllowedAt,
    @JsonKey(name: 'username_change_cooldown_days')
    @Default(7)
    int usernameChangeCooldownDays,
  String? phone,
  }) = _MyProfileDto;

  factory MyProfileDto.fromJson(Map<String, dynamic> json) =>
      _$MyProfileDtoFromJson(json);
}

@freezed
abstract class UpdateMyProfileRequestDto with _$UpdateMyProfileRequestDto {
  const factory UpdateMyProfileRequestDto({
    // includeIfNull: false — hanya kirim kalau diisi
    @JsonKey(includeIfNull: false) String? username,
    @JsonKey(name: 'display_name') String? displayName,
    String? bio,
    /// `native` | `learner`. Null = tidak diubah (jangan kirim key).
    @JsonKey(name: 'speaker_status', includeIfNull: false) String? speakerStatus,
    // null ikut terkirim supaya user bisa mengosongkan kecamatan/desa.
    @JsonKey(name: 'region_id') String? regionId,
    @JsonKey(name: 'village_id') String? villageId,
    // #98: kirim key ini hanya saat true - null ikut ter-serialize
    // (includeIfNull default) dan ditolak validasi backend.
    @JsonKey(name: 'has_read_contribution_guide', includeIfNull: false)
    bool? hasReadContributionGuide,
    @JsonKey(name: 'notify_streak_reminder', includeIfNull: false)
    bool? notifyStreakReminder,
    @JsonKey(name: 'notify_level_up', includeIfNull: false)
    bool? notifyLevelUp,
  }) = _UpdateMyProfileRequestDto;

  factory UpdateMyProfileRequestDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateMyProfileRequestDtoFromJson(json);
}
