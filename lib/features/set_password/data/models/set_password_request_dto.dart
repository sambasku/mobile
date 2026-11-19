import 'package:freezed_annotation/freezed_annotation.dart';

part 'set_password_request_dto.freezed.dart';
part 'set_password_request_dto.g.dart';

@freezed
abstract class SetPasswordRequestDto with _$SetPasswordRequestDto {
  const factory SetPasswordRequestDto({
    required String provider,
    // null jangan ikut body: Zod .optional() menolak null (#98 pola sama).
    @JsonKey(name: 'id_token', includeIfNull: false) String? idToken,
    @JsonKey(name: 'access_token', includeIfNull: false) String? accessToken,
    @JsonKey(includeIfNull: false) String? code,
    @JsonKey(name: 'redirect_uri', includeIfNull: false) String? redirectUri,
    @JsonKey(name: 'code_verifier', includeIfNull: false) String? codeVerifier,
    @JsonKey(name: 'new_password') required String newPassword,
    @JsonKey(name: 'confirm_password') required String confirmPassword,
  }) = _SetPasswordRequestDto;

  factory SetPasswordRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SetPasswordRequestDtoFromJson(json);
}

@freezed
abstract class SetPasswordResponseDto with _$SetPasswordResponseDto {
  const factory SetPasswordResponseDto({
    required String message,
    @JsonKey(name: 'login_with') required String loginWith,
  }) = _SetPasswordResponseDto;

  factory SetPasswordResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SetPasswordResponseDtoFromJson(json);
}
