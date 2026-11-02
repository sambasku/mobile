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
      regionId: json['region_id'] as String?,
      villageId: json['village_id'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      hasReadContributionGuide:
          json['has_read_contribution_guide'] as bool? ?? false,
      requiresConsent: json['requires_consent'] as bool? ?? false,
      notifyStreakReminder: json['notify_streak_reminder'] as bool? ?? true,
      notifyLevelUp: json['notify_level_up'] as bool? ?? true,
    );

Map<String, dynamic> _$MyProfileDtoToJson(_MyProfileDto instance) =>
    <String, dynamic>{
      'username': instance.username,
      'display_name': instance.displayName,
      'bio': instance.bio,
      'region_id': instance.regionId,
      'village_id': instance.villageId,
      'avatar_url': instance.avatarUrl,
      'has_read_contribution_guide': instance.hasReadContributionGuide,
      'requires_consent': instance.requiresConsent,
      'notify_streak_reminder': instance.notifyStreakReminder,
      'notify_level_up': instance.notifyLevelUp,
    };

_UpdateMyProfileRequestDto _$UpdateMyProfileRequestDtoFromJson(
  Map<String, dynamic> json,
) => _UpdateMyProfileRequestDto(
  username: json['username'] as String?,
  displayName: json['display_name'] as String?,
  bio: json['bio'] as String?,
  regionId: json['region_id'] as String?,
  villageId: json['village_id'] as String?,
  hasReadContributionGuide: json['has_read_contribution_guide'] as bool?,
  notifyStreakReminder: json['notify_streak_reminder'] as bool?,
  notifyLevelUp: json['notify_level_up'] as bool?,
);

Map<String, dynamic> _$UpdateMyProfileRequestDtoToJson(
  _UpdateMyProfileRequestDto instance,
) => <String, dynamic>{
  'username': ?instance.username,
  'display_name': instance.displayName,
  'bio': instance.bio,
  'region_id': instance.regionId,
  'village_id': instance.villageId,
  'has_read_contribution_guide': ?instance.hasReadContributionGuide,
  'notify_streak_reminder': ?instance.notifyStreakReminder,
  'notify_level_up': ?instance.notifyLevelUp,
};
