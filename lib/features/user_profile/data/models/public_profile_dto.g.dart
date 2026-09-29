// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PublicProfileDto _$PublicProfileDtoFromJson(Map<String, dynamic> json) =>
    _PublicProfileDto(
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      bio: json['bio'] as String?,
      role: json['role'] as String,
      isVerifier: json['is_verifier'] as bool? ?? false,
      joinedAt: json['joined_at'] as String,
      avatarUrl: json['avatar_url'] as String?,
      stats: PublicProfileStatsDto.fromJson(
        json['stats'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$PublicProfileDtoToJson(_PublicProfileDto instance) =>
    <String, dynamic>{
      'username': instance.username,
      'display_name': instance.displayName,
      'bio': instance.bio,
      'role': instance.role,
      'is_verifier': instance.isVerifier,
      'joined_at': instance.joinedAt,
      'avatar_url': instance.avatarUrl,
      'stats': instance.stats,
    };

_PublicProfileStatsDto _$PublicProfileStatsDtoFromJson(
  Map<String, dynamic> json,
) => _PublicProfileStatsDto(
  contributionsApproved: (json['contributions_approved'] as num?)?.toInt() ?? 0,
  verificationsDone: (json['verifications_done'] as num?)?.toInt() ?? 0,
  commentsPublished: (json['comments_published'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PublicProfileStatsDtoToJson(
  _PublicProfileStatsDto instance,
) => <String, dynamic>{
  'contributions_approved': instance.contributionsApproved,
  'verifications_done': instance.verificationsDone,
  'comments_published': instance.commentsPublished,
};

_PublicActivityItemDto _$PublicActivityItemDtoFromJson(
  Map<String, dynamic> json,
) => _PublicActivityItemDto(
  kind: json['kind'] as String,
  occurredAt: json['occurred_at'] as String,
  wordId: json['word_id'] as String?,
  lemma: json['lemma'] as String?,
  summary: json['summary'] as String,
);

Map<String, dynamic> _$PublicActivityItemDtoToJson(
  _PublicActivityItemDto instance,
) => <String, dynamic>{
  'kind': instance.kind,
  'occurred_at': instance.occurredAt,
  'word_id': instance.wordId,
  'lemma': instance.lemma,
  'summary': instance.summary,
};

_PublicActivityDto _$PublicActivityDtoFromJson(Map<String, dynamic> json) =>
    _PublicActivityDto(
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) =>
                    PublicActivityItemDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PublicActivityDtoToJson(_PublicActivityDto instance) =>
    <String, dynamic>{'items': instance.items.map((e) => e.toJson()).toList()};
