import 'package:fpdart/fpdart.dart';

import '../entities/achievement.dart';
import '../failures/achievement_failure.dart';
import '../repositories/achievement_repository.dart';

class GetCatalogUseCase {
  const GetCatalogUseCase(this._repository);

  final AchievementRepository _repository;

  Future<Either<AchievementFailure, List<Achievement>>> call({
    String? rewardType,
    String? category,
  }) => _repository.listCatalog(rewardType: rewardType, category: category);
}

class GetMyAchievementsUseCase {
  const GetMyAchievementsUseCase(this._repository);

  final AchievementRepository _repository;

  Future<Either<AchievementFailure, List<Achievement>>> call({
    String? rewardType,
    String? category,
  }) => _repository.listMine(rewardType: rewardType, category: category);
}

class GetUserAchievementsUseCase {
  const GetUserAchievementsUseCase(this._repository);

  final AchievementRepository _repository;

  Future<Either<AchievementFailure, List<Achievement>>> call(String username) =>
      _repository.listByUsername(username);
}

class SetActiveBorderUseCase {
  const SetActiveBorderUseCase(this._repository);

  final AchievementRepository _repository;

  /// [awardId] null = lepas bingkai.
  Future<Either<AchievementFailure, String?>> call(String? awardId) =>
      _repository.setBorder(awardId);
}
