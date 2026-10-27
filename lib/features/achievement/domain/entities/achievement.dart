/// Progress locked untuk source agregat (`GET /me/achievements`).
class AchievementProgress {
  const AchievementProgress({required this.current, required this.target});

  final int current;
  final int target;
}

/// Reward katalog + status kepemilikan (43-api-achievements.md).
class Achievement {
  const Achievement({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.category,
    required this.rewardType,
    required this.isActive,
    this.badgeUrl,
    this.family,
    this.level,
    this.userAchievementId,
    this.awardedAt,
    this.isActiveBorder = false,
    this.progress,
  });

  final String id;
  final String code;
  final String title;
  final String description;

  /// kohort | kontribusi | komunitas | kualitas | momen
  final String category;

  /// profile_border | badge | sticker
  final String rewardType;
  final String? badgeUrl;
  final String? family;
  final int? level;
  final bool isActive;

  /// Award id (`user_achievements.id`); null = belum dimiliki.
  final String? userAchievementId;
  final DateTime? awardedAt;

  /// Border ini sedang dipakai sebagai bingkai profil.
  final bool isActiveBorder;

  /// Locked agregat: current/target. Owned/kohort/manual = null.
  final AchievementProgress? progress;

  bool get isOwned => userAchievementId != null;
  bool get isBorder => rewardType == 'profile_border';
  bool get isBadge => rewardType == 'badge';
  bool get isSticker => rewardType == 'sticker';
}

/// Border siap pakai untuk overlay avatar.
class ActiveBorder {
  const ActiveBorder({required this.awardId, required this.imageUrl});

  final String awardId;
  final String imageUrl;
}
