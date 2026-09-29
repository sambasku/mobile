// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verifier_application_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SocialScreenshotDto _$SocialScreenshotDtoFromJson(Map<String, dynamic> json) =>
    _SocialScreenshotDto(
      url: json['url'] as String,
      providerFileId: json['provider_file_id'] as String,
    );

Map<String, dynamic> _$SocialScreenshotDtoToJson(
  _SocialScreenshotDto instance,
) => <String, dynamic>{
  'url': instance.url,
  'provider_file_id': instance.providerFileId,
};

_SocialLinkDto _$SocialLinkDtoFromJson(Map<String, dynamic> json) =>
    _SocialLinkDto(
      platform: json['platform'] as String,
      username: json['username'] as String,
      screenshot: SocialScreenshotDto.fromJson(
        json['screenshot'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$SocialLinkDtoToJson(_SocialLinkDto instance) =>
    <String, dynamic>{
      'platform': instance.platform,
      'username': instance.username,
      'screenshot': instance.screenshot.toJson(),
    };

_VerifierApplicationDto _$VerifierApplicationDtoFromJson(
  Map<String, dynamic> json,
) => _VerifierApplicationDto(
  id: json['id'] as String,
  status: json['status'] as String,
  phone: json['phone'] as String,
  address: json['address'] as String,
  socialLinks: (json['social_links'] as List<dynamic>)
      .map((e) => SocialLinkDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  adminComment: json['admin_comment'] as String?,
  reviewedAt: json['reviewed_at'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$VerifierApplicationDtoToJson(
  _VerifierApplicationDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'phone': instance.phone,
  'address': instance.address,
  'social_links': instance.socialLinks.map((e) => e.toJson()).toList(),
  'admin_comment': instance.adminComment,
  'reviewed_at': instance.reviewedAt,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

_SubmitVerifierApplicationRequestDto
_$SubmitVerifierApplicationRequestDtoFromJson(Map<String, dynamic> json) =>
    _SubmitVerifierApplicationRequestDto(
      phone: json['phone'] as String,
      address: json['address'] as String,
      socialLinks: (json['social_links'] as List<dynamic>)
          .map((e) => SocialLinkDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubmitVerifierApplicationRequestDtoToJson(
  _SubmitVerifierApplicationRequestDto instance,
) => <String, dynamic>{
  'phone': instance.phone,
  'address': instance.address,
  'social_links': instance.socialLinks.map((e) => e.toJson()).toList(),
};
