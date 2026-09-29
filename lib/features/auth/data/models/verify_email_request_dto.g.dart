// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_email_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VerifyEmailRequestDto _$VerifyEmailRequestDtoFromJson(
  Map<String, dynamic> json,
) => _VerifyEmailRequestDto(
  email: json['email'] as String,
  code: json['code'] as String,
  clientType: json['client_type'] as String? ?? 'mobile',
);

Map<String, dynamic> _$VerifyEmailRequestDtoToJson(
  _VerifyEmailRequestDto instance,
) => <String, dynamic>{
  'email': instance.email,
  'code': instance.code,
  'client_type': instance.clientType,
};
