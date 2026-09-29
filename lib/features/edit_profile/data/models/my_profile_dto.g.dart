// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MyProfileDto _$MyProfileDtoFromJson(Map<String, dynamic> json) =>
    _MyProfileDto(
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );

Map<String, dynamic> _$MyProfileDtoToJson(_MyProfileDto instance) =>
    <String, dynamic>{
      'username': instance.username,
      'display_name': instance.displayName,
      'bio': instance.bio,
      'avatar_url': instance.avatarUrl,
    };

_UpdateMyProfileRequestDto _$UpdateMyProfileRequestDtoFromJson(
  Map<String, dynamic> json,
) => _UpdateMyProfileRequestDto(
  displayName: json['display_name'] as String?,
  bio: json['bio'] as String?,
);

Map<String, dynamic> _$UpdateMyProfileRequestDtoToJson(
  _UpdateMyProfileRequestDto instance,
) => <String, dynamic>{
  'display_name': instance.displayName,
  'bio': instance.bio,
};
