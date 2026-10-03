import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_profile_dto.freezed.dart';
part 'my_profile_dto.g.dart';

@freezed
abstract class MyProfileDto with _$MyProfileDto {
  const factory MyProfileDto({
    required String username,
    @JsonKey(name: 'display_name') required String displayName,
    String? bio,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'has_read_contribution_guide') @Default(false) bool hasReadContributionGuide,
  }) = _MyProfileDto;

  factory MyProfileDto.fromJson(Map<String, dynamic> json) =>
      _$MyProfileDtoFromJson(json);
}

@freezed
abstract class UpdateMyProfileRequestDto with _$UpdateMyProfileRequestDto {
  const factory UpdateMyProfileRequestDto({
    @JsonKey(name: 'display_name') String? displayName,
    String? bio,
    @JsonKey(name: 'has_read_contribution_guide') bool? hasReadContributionGuide,
  }) = _UpdateMyProfileRequestDto;

  factory UpdateMyProfileRequestDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateMyProfileRequestDtoFromJson(json);
}
