import 'package:freezed_annotation/freezed_annotation.dart';

part 'set_password_request_dto.freezed.dart';
part 'set_password_request_dto.g.dart';

@freezed
abstract class SetPasswordRequestDto with _$SetPasswordRequestDto {
  const factory SetPasswordRequestDto({
    required String provider,
    @JsonKey(name: 'id_token') String? idToken,
    @JsonKey(name: 'access_token') String? accessToken,
    String? code,
    @JsonKey(name: 'redirect_uri') String? redirectUri,
    @JsonKey(name: 'code_verifier') String? codeVerifier,
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
