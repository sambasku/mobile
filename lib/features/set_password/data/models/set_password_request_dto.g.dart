// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_password_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SetPasswordRequestDto _$SetPasswordRequestDtoFromJson(
  Map<String, dynamic> json,
) => _SetPasswordRequestDto(
  provider: json['provider'] as String,
  idToken: json['id_token'] as String?,
  accessToken: json['access_token'] as String?,
  code: json['code'] as String?,
  redirectUri: json['redirect_uri'] as String?,
  codeVerifier: json['code_verifier'] as String?,
  newPassword: json['new_password'] as String,
  confirmPassword: json['confirm_password'] as String,
);

Map<String, dynamic> _$SetPasswordRequestDtoToJson(
  _SetPasswordRequestDto instance,
) => <String, dynamic>{
  'provider': instance.provider,
  'id_token': instance.idToken,
  'access_token': instance.accessToken,
  'code': instance.code,
  'redirect_uri': instance.redirectUri,
  'code_verifier': instance.codeVerifier,
  'new_password': instance.newPassword,
  'confirm_password': instance.confirmPassword,
};

_SetPasswordResponseDto _$SetPasswordResponseDtoFromJson(
  Map<String, dynamic> json,
) => _SetPasswordResponseDto(
  message: json['message'] as String,
  loginWith: json['login_with'] as String,
);

Map<String, dynamic> _$SetPasswordResponseDtoToJson(
  _SetPasswordResponseDto instance,
) => <String, dynamic>{
  'message': instance.message,
  'login_with': instance.loginWith,
};
