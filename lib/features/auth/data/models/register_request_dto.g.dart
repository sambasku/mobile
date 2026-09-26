// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LegalConsentDto _$LegalConsentDtoFromJson(Map<String, dynamic> json) =>
    _LegalConsentDto(
      documentType: json['document_type'] as String,
      documentVersion: json['document_version'] as String,
    );

Map<String, dynamic> _$LegalConsentDtoToJson(_LegalConsentDto instance) =>
    <String, dynamic>{
      'document_type': instance.documentType,
      'document_version': instance.documentVersion,
    };

_RegisterRequestDto _$RegisterRequestDtoFromJson(Map<String, dynamic> json) =>
    _RegisterRequestDto(
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      password: json['password'] as String,
      confirmPassword: json['confirm_password'] as String,
      clientId: json['client_id'] as String? ?? 'sambasku-mobile',
      consents: (json['consents'] as List<dynamic>)
          .map((e) => LegalConsentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RegisterRequestDtoToJson(_RegisterRequestDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'phone': ?instance.phone,
      'password': instance.password,
      'confirm_password': instance.confirmPassword,
      'client_id': instance.clientId,
      'consents': instance.consents,
    };

_RegisterResponseDto _$RegisterResponseDtoFromJson(Map<String, dynamic> json) =>
    _RegisterResponseDto(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      verificationRequired: json['verification_required'] as bool? ?? true,
    );

Map<String, dynamic> _$RegisterResponseDtoToJson(
  _RegisterResponseDto instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'username': instance.username,
  'email': instance.email,
  'phone': instance.phone,
  'verification_required': instance.verificationRequired,
};
