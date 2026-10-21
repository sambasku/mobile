import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_providers_dto.freezed.dart';
part 'auth_providers_dto.g.dart';

@freezed
abstract class AuthProvidersDto with _$AuthProvidersDto {
  const factory AuthProvidersDto({
    @Default([]) List<AuthProviderItemDto> providers,
    @Default(false) @JsonKey(name: 'has_password') bool hasPassword,
  }) = _AuthProvidersDto;

  factory AuthProvidersDto.fromJson(Map<String, dynamic> json) =>
      _$AuthProvidersDtoFromJson(json);
}

@freezed
abstract class AuthProviderItemDto with _$AuthProviderItemDto {
  const factory AuthProviderItemDto({
    required String provider,
    @JsonKey(name: 'linked_at') required String linkedAt,
  }) = _AuthProviderItemDto;

  factory AuthProviderItemDto.fromJson(Map<String, dynamic> json) =>
      _$AuthProviderItemDtoFromJson(json);
}

@freezed
abstract class GoogleLinkRequestDto with _$GoogleLinkRequestDto {
  const factory GoogleLinkRequestDto({
    @JsonKey(name: 'id_token') required String idToken,
  }) = _GoogleLinkRequestDto;

  factory GoogleLinkRequestDto.fromJson(Map<String, dynamic> json) =>
      _$GoogleLinkRequestDtoFromJson(json);
}

@freezed
abstract class GoogleLinkResponseDto with _$GoogleLinkResponseDto {
  const factory GoogleLinkResponseDto({
    required String provider,
    @JsonKey(name: 'linked_at') required String linkedAt,
  }) = _GoogleLinkResponseDto;

  factory GoogleLinkResponseDto.fromJson(Map<String, dynamic> json) =>
      _$GoogleLinkResponseDtoFromJson(json);
}

@freezed
abstract class UnlinkMessageDto with _$UnlinkMessageDto {
  const factory UnlinkMessageDto({
    required String message,
  }) = _UnlinkMessageDto;

  factory UnlinkMessageDto.fromJson(Map<String, dynamic> json) =>
      _$UnlinkMessageDtoFromJson(json);
}
