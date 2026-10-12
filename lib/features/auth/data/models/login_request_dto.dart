import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request_dto.freezed.dart';
part 'login_request_dto.g.dart';

/// Varian mobile (base-stack Section 6): `client_type: mobile` supaya
/// refresh_token dikirim di BODY (bukan cookie httpOnly yang tak terbaca
/// oleh mobile).
@freezed
abstract class LoginRequestDto with _$LoginRequestDto {
  const factory LoginRequestDto({
    required String identifier,
    required String password,
    @JsonKey(name: 'client_type') @Default('mobile') String clientType,
  }) = _LoginRequestDto;

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestDtoFromJson(json);
}

@freezed
abstract class RefreshRequestDto with _$RefreshRequestDto {
  const factory RefreshRequestDto({
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'client_type') @Default('mobile') String clientType,
  }) = _RefreshRequestDto;

  factory RefreshRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RefreshRequestDtoFromJson(json);
}
