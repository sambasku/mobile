import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/achievement.dart';
import '../../domain/providers/achievement_domain_providers.dart';

part 'achievement_providers.g.dart';

/// Milik user login: owned + locked (GET /me/achievements).
@riverpod
Future<List<Achievement>> myAchievements(Ref ref, {String? rewardType}) async {
  final result =
      await ref.watch(getMyAchievementsUseCaseProvider)(rewardType: rewardType);
  return result.match((failure) => throw failure, (items) => items);
}

/// Reward milik user publik by username (badge profil).
@riverpod
Future<List<Achievement>> userAchievements(Ref ref, String username) async {
  final result = await ref.watch(getUserAchievementsUseCaseProvider)(username);
  return result.match((failure) => throw failure, (items) => items);
}

/// Border aktif milik user login (overlay avatar profil sendiri). null = tanpa bingkai.
@riverpod
Future<ActiveBorder?> myActiveBorder(Ref ref) async {
  final items =
      await ref.watch(myAchievementsProvider(rewardType: 'profile_border').future);
  for (final item in items) {
    if (item.isActiveBorder && item.badgeUrl != null) {
      return ActiveBorder(
        awardId: item.userAchievementId!,
        imageUrl: item.badgeUrl!,
      );
    }
  }
  return null;
}
