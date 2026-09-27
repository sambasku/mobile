// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_link_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GithubLinkRequestDto _$GithubLinkRequestDtoFromJson(
  Map<String, dynamic> json,
) => _GithubLinkRequestDto(
  code: json['code'] as String,
  redirectUri: json['redirect_uri'] as String,
  codeVerifier: json['code_verifier'] as String?,
);

Map<String, dynamic> _$GithubLinkRequestDtoToJson(
  _GithubLinkRequestDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'redirect_uri': instance.redirectUri,
  'code_verifier': instance.codeVerifier,
};

_GithubLinkResponseDto _$GithubLinkResponseDtoFromJson(
  Map<String, dynamic> json,
) => _GithubLinkResponseDto(
  provider: json['provider'] as String,
  linkedAt: json['linked_at'] as String,
);

Map<String, dynamic> _$GithubLinkResponseDtoToJson(
  _GithubLinkResponseDto instance,
) => <String, dynamic>{
  'provider': instance.provider,
  'linked_at': instance.linkedAt,
};
