import 'package:freezed_annotation/freezed_annotation.dart';

part 'verifier_application_dto.freezed.dart';
part 'verifier_application_dto.g.dart';

@freezed
abstract class SocialScreenshotDto with _$SocialScreenshotDto {
  const factory SocialScreenshotDto({
    required String url,
    @JsonKey(name: 'provider_file_id') required String providerFileId,
  }) = _SocialScreenshotDto;

  factory SocialScreenshotDto.fromJson(Map<String, dynamic> json) =>
      _$SocialScreenshotDtoFromJson(json);
}

@freezed
abstract class SocialLinkDto with _$SocialLinkDto {
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory SocialLinkDto({
    required String platform,
    required String username,
    required SocialScreenshotDto screenshot,
  }) = _SocialLinkDto;

  factory SocialLinkDto.fromJson(Map<String, dynamic> json) =>
      _$SocialLinkDtoFromJson(json);
}

@freezed
abstract class VerifierApplicationDto with _$VerifierApplicationDto {
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory VerifierApplicationDto({
    required String id,
    required String status,
    required String phone,
    required String address,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'social_links') required List<SocialLinkDto> socialLinks,
    String? dialect,
    @JsonKey(name: 'dialect_note') String? dialectNote,
    String? reason,
    SocialScreenshotDto? photo,
    @JsonKey(name: 'admin_comment') String? adminComment,
    @JsonKey(name: 'reviewed_at') String? reviewedAt,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _VerifierApplicationDto;

  factory VerifierApplicationDto.fromJson(Map<String, dynamic> json) =>
      _$VerifierApplicationDtoFromJson(json);
}

@freezed
abstract class SubmitVerifierApplicationRequestDto
    with _$SubmitVerifierApplicationRequestDto {
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory SubmitVerifierApplicationRequestDto({
    required String phone,
    required String address,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'social_links') required List<SocialLinkDto> socialLinks,
    required String dialect,
    @JsonKey(name: 'dialect_note') String? dialectNote,
    required String reason,
    SocialScreenshotDto? photo,
  }) = _SubmitVerifierApplicationRequestDto;

  factory SubmitVerifierApplicationRequestDto.fromJson(
    Map<String, dynamic> json,
  ) => _$SubmitVerifierApplicationRequestDtoFromJson(json);
}
