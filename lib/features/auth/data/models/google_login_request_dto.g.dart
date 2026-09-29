// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_login_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GoogleLoginRequestDto _$GoogleLoginRequestDtoFromJson(
  Map<String, dynamic> json,
) => _GoogleLoginRequestDto(
  idToken: json['id_token'] as String,
  clientType: json['client_type'] as String? ?? 'mobile',
);

Map<String, dynamic> _$GoogleLoginRequestDtoToJson(
  _GoogleLoginRequestDto instance,
) => <String, dynamic>{
  'id_token': instance.idToken,
  'client_type': instance.clientType,
};
