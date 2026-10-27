// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AchievementDto _$AchievementDtoFromJson(Map<String, dynamic> json) =>
    _AchievementDto(
      id: json['id'] as String,
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      rewardType: json['reward_type'] as String,
      badgeUrl: json['badge_url'] as String?,
      family: json['family'] as String?,
      level: (json['level'] as num?)?.toInt(),
      isActive: json['is_active'] as bool? ?? true,
      userAchievementId: json['user_achievement_id'] as String?,
      awardedAt: (json['awarded_at'] as num?)?.toInt(),
      isActiveBorder: json['is_active_border'] as bool? ?? false,
      progress: json['progress'] == null
          ? null
          : AchievementProgressDto.fromJson(
              json['progress'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$AchievementDtoToJson(_AchievementDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'reward_type': instance.rewardType,
      'badge_url': instance.badgeUrl,
      'family': instance.family,
      'level': instance.level,
      'is_active': instance.isActive,
      'user_achievement_id': instance.userAchievementId,
      'awarded_at': instance.awardedAt,
      'is_active_border': instance.isActiveBorder,
      'progress': instance.progress,
    };

_AchievementProgressDto _$AchievementProgressDtoFromJson(
  Map<String, dynamic> json,
) => _AchievementProgressDto(
  current: (json['current'] as num).toInt(),
  target: (json['target'] as num).toInt(),
);

Map<String, dynamic> _$AchievementProgressDtoToJson(
  _AchievementProgressDto instance,
) => <String, dynamic>{'current': instance.current, 'target': instance.target};

_AchievementListDto _$AchievementListDtoFromJson(Map<String, dynamic> json) =>
    _AchievementListDto(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => AchievementDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AchievementDto>[],
      nextCursor: json['next_cursor'] as String?,
    );

Map<String, dynamic> _$AchievementListDtoToJson(_AchievementListDto instance) =>
    <String, dynamic>{
      'items': instance.items,
      'next_cursor': instance.nextCursor,
    };

_SetBorderRequestDto _$SetBorderRequestDtoFromJson(Map<String, dynamic> json) =>
    _SetBorderRequestDto(borderId: json['border_id'] as String?);

Map<String, dynamic> _$SetBorderRequestDtoToJson(
  _SetBorderRequestDto instance,
) => <String, dynamic>{'border_id': instance.borderId};

_SetBorderResponseDto _$SetBorderResponseDtoFromJson(
  Map<String, dynamic> json,
) => _SetBorderResponseDto(activeBorderId: json['active_border_id'] as String?);

Map<String, dynamic> _$SetBorderResponseDtoToJson(
  _SetBorderResponseDto instance,
) => <String, dynamic>{'active_border_id': instance.activeBorderId};
