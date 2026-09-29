// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logout_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LogoutRequestDto _$LogoutRequestDtoFromJson(Map<String, dynamic> json) =>
    _LogoutRequestDto(
      refreshToken: json['refresh_token'] as String,
      clientType: json['client_type'] as String? ?? 'mobile',
    );

Map<String, dynamic> _$LogoutRequestDtoToJson(_LogoutRequestDto instance) =>
    <String, dynamic>{
      'refresh_token': instance.refreshToken,
      'client_type': instance.clientType,
    };
