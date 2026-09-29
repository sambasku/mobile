// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthProvidersDto _$AuthProvidersDtoFromJson(Map<String, dynamic> json) =>
    _AuthProvidersDto(
      providers:
          (json['providers'] as List<dynamic>?)
              ?.map(
                (e) => AuthProviderItemDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AuthProvidersDtoToJson(_AuthProvidersDto instance) =>
    <String, dynamic>{'providers': instance.providers};

_AuthProviderItemDto _$AuthProviderItemDtoFromJson(Map<String, dynamic> json) =>
    _AuthProviderItemDto(
      provider: json['provider'] as String,
      linkedAt: json['linked_at'] as String,
    );

Map<String, dynamic> _$AuthProviderItemDtoToJson(
  _AuthProviderItemDto instance,
) => <String, dynamic>{
  'provider': instance.provider,
  'linked_at': instance.linkedAt,
};

_GoogleLinkRequestDto _$GoogleLinkRequestDtoFromJson(
  Map<String, dynamic> json,
) => _GoogleLinkRequestDto(idToken: json['id_token'] as String);

Map<String, dynamic> _$GoogleLinkRequestDtoToJson(
  _GoogleLinkRequestDto instance,
) => <String, dynamic>{'id_token': instance.idToken};

_GoogleLinkResponseDto _$GoogleLinkResponseDtoFromJson(
  Map<String, dynamic> json,
) => _GoogleLinkResponseDto(
  provider: json['provider'] as String,
  linkedAt: json['linked_at'] as String,
);

Map<String, dynamic> _$GoogleLinkResponseDtoToJson(
  _GoogleLinkResponseDto instance,
) => <String, dynamic>{
  'provider': instance.provider,
  'linked_at': instance.linkedAt,
};

_UnlinkMessageDto _$UnlinkMessageDtoFromJson(Map<String, dynamic> json) =>
    _UnlinkMessageDto(message: json['message'] as String);

Map<String, dynamic> _$UnlinkMessageDtoToJson(_UnlinkMessageDto instance) =>
    <String, dynamic>{'message': instance.message};
