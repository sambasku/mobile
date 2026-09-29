// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginUserDto _$LoginUserDtoFromJson(Map<String, dynamic> json) =>
    _LoginUserDto(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      role: json['role'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );

Map<String, dynamic> _$LoginUserDtoToJson(_LoginUserDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'display_name': instance.displayName,
      'role': instance.role,
      'avatar_url': instance.avatarUrl,
    };

_LoginResponseDto _$LoginResponseDtoFromJson(Map<String, dynamic> json) =>
    _LoginResponseDto(
      accessToken: json['access_token'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
      refreshToken: json['refresh_token'] as String?,
      user: LoginUserDto.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseDtoToJson(_LoginResponseDto instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'expires_in': instance.expiresIn,
      'refresh_token': instance.refreshToken,
      'user': instance.user,
    };
