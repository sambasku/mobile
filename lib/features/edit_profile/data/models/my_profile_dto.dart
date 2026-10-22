import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_profile_dto.freezed.dart';
part 'my_profile_dto.g.dart';

@freezed
abstract class MyProfileDto with _$MyProfileDto {
  const factory MyProfileDto({
    required String username,
    @JsonKey(name: 'display_name') required String displayName,
    String? bio,
    @JsonKey(name: 'region_id') String? regionId,
    @JsonKey(name: 'village_id') String? villageId,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'has_read_contribution_guide') @Default(false) bool hasReadContributionGuide,
    /// True bila user belum menyetujui terms/privacy versi aktif.
    @JsonKey(name: 'requires_consent') @Default(false) bool requiresConsent,
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
    // null ikut terkirim supaya user bisa mengosongkan kecamatan/desa.
    @JsonKey(name: 'region_id') String? regionId,
    @JsonKey(name: 'village_id') String? villageId,
    // #98: kirim key ini hanya saat true - null ikut ter-serialize
    // (includeIfNull default) dan ditolak validasi backend.
    @JsonKey(name: 'has_read_contribution_guide', includeIfNull: false)
    bool? hasReadContributionGuide,
  }) = _UpdateMyProfileRequestDto;

  factory UpdateMyProfileRequestDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateMyProfileRequestDtoFromJson(json);
}
