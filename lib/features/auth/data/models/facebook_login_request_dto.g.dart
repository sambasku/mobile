// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facebook_login_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FacebookLoginRequestDto _$FacebookLoginRequestDtoFromJson(
  Map<String, dynamic> json,
) => _FacebookLoginRequestDto(
  accessToken: json['access_token'] as String,
  clientType: json['client_type'] as String? ?? 'mobile',
);

Map<String, dynamic> _$FacebookLoginRequestDtoToJson(
  _FacebookLoginRequestDto instance,
) => <String, dynamic>{
  'access_token': instance.accessToken,
  'client_type': instance.clientType,
};
