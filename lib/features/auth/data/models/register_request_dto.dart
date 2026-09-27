import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_request_dto.freezed.dart';
part 'register_request_dto.g.dart';

@freezed
abstract class LegalConsentDto with _$LegalConsentDto {
  const factory LegalConsentDto({
    @JsonKey(name: 'document_type') required String documentType,
    @JsonKey(name: 'document_version') required String documentVersion,
  }) = _LegalConsentDto;

  factory LegalConsentDto.fromJson(Map<String, dynamic> json) =>
      _$LegalConsentDtoFromJson(json);
}

/// Body POST /api/v1/auth/register (00-api-auth.md + legal consent).
/// `phone` = digit internasional tanpa '+' (opsional), mis. 62812… / 6012….
/// Nasional ID lama (8… / 08…) masih diterima server (fallback 62).
@freezed
abstract class RegisterRequestDto with _$RegisterRequestDto {
  const factory RegisterRequestDto({
    required String name,
    required String email,
    @JsonKey(includeIfNull: false) String? phone,
    required String password,
    @JsonKey(name: 'confirm_password') required String confirmPassword,
    @JsonKey(name: 'client_id') @Default('sambasku-mobile') String clientId,
    required List<LegalConsentDto> consents,
  }) = _RegisterRequestDto;

  factory RegisterRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestDtoFromJson(json);
}

@freezed
abstract class RegisterResponseDto with _$RegisterResponseDto {
  const factory RegisterResponseDto({
    @JsonKey(name: 'user_id') required String userId,
    required String username,
    required String email,
    String? phone,
    @JsonKey(name: 'verification_required')
    @Default(true)
    bool verificationRequired,
  }) = _RegisterResponseDto;

  factory RegisterResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseDtoFromJson(json);
}
