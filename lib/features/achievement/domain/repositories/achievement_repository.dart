import 'package:fpdart/fpdart.dart';

import '../entities/achievement.dart';
import '../failures/achievement_failure.dart';

abstract interface class AchievementRepository {
  /// Katalog aktif (publik).
  Future<Either<AchievementFailure, List<Achievement>>> listCatalog({
    String? rewardType,
    String? category,
  });

  /// Reward milik user (publik, badge profil).
  Future<Either<AchievementFailure, List<Achievement>>> listByUsername(
    String username,
  );

  /// Milik saya: owned + locked.
  Future<Either<AchievementFailure, List<Achievement>>> listMine({
    String? rewardType,
    String? category,
  });

  /// Set border aktif (award id) atau lepas dengan null.
  Future<Either<AchievementFailure, String?>> setBorder(String? awardId);
}
