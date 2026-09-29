// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_login_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GithubLoginRequestDto _$GithubLoginRequestDtoFromJson(
  Map<String, dynamic> json,
) => _GithubLoginRequestDto(
  code: json['code'] as String,
  redirectUri: json['redirect_uri'] as String,
  codeVerifier: json['code_verifier'] as String?,
  clientType: json['client_type'] as String? ?? 'mobile',
);

Map<String, dynamic> _$GithubLoginRequestDtoToJson(
  _GithubLoginRequestDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'redirect_uri': instance.redirectUri,
  'code_verifier': instance.codeVerifier,
  'client_type': instance.clientType,
};
