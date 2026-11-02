import 'package:freezed_annotation/freezed_annotation.dart';

import 'register_request_dto.dart' show LegalConsentDto;

part 'google_login_request_dto.freezed.dart';
part 'google_login_request_dto.g.dart';

@freezed
abstract class GoogleLoginRequestDto with _$GoogleLoginRequestDto {
  const factory GoogleLoginRequestDto({
    @JsonKey(name: 'id_token') required String idToken,
    @JsonKey(name: 'client_type') @Default('mobile') String clientType,

    /// Persetujuan legal - wajib untuk akun baru (mode enforce).
    @JsonKey(includeIfNull: false) List<LegalConsentDto>? consents,
  }) = _GoogleLoginRequestDto;

  factory GoogleLoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$GoogleLoginRequestDtoFromJson(json);
}
