// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reset_password_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ForgotPasswordRequestDto _$ForgotPasswordRequestDtoFromJson(
  Map<String, dynamic> json,
) => _ForgotPasswordRequestDto(email: json['email'] as String);

Map<String, dynamic> _$ForgotPasswordRequestDtoToJson(
  _ForgotPasswordRequestDto instance,
) => <String, dynamic>{'email': instance.email};

_ResetPasswordRequestDto _$ResetPasswordRequestDtoFromJson(
  Map<String, dynamic> json,
) => _ResetPasswordRequestDto(
  token: json['token'] as String?,
  email: json['email'] as String?,
  code: json['code'] as String?,
  newPassword: json['new_password'] as String,
);

Map<String, dynamic> _$ResetPasswordRequestDtoToJson(
  _ResetPasswordRequestDto instance,
) => <String, dynamic>{
  'token': ?instance.token,
  'email': ?instance.email,
  'code': ?instance.code,
  'new_password': instance.newPassword,
};

_AuthMessageResponseDto _$AuthMessageResponseDtoFromJson(
  Map<String, dynamic> json,
) => _AuthMessageResponseDto(message: json['message'] as String);

Map<String, dynamic> _$AuthMessageResponseDtoToJson(
  _AuthMessageResponseDto instance,
) => <String, dynamic>{'message': instance.message};
