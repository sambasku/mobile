import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/achievement_data_providers.dart';
import '../usecases/achievement_use_cases.dart';

part 'achievement_domain_providers.g.dart';

@riverpod
GetCatalogUseCase getCatalogUseCase(Ref ref) =>
    GetCatalogUseCase(ref.watch(achievementRepositoryProvider));

@riverpod
GetMyAchievementsUseCase getMyAchievementsUseCase(Ref ref) =>
    GetMyAchievementsUseCase(ref.watch(achievementRepositoryProvider));

@riverpod
GetUserAchievementsUseCase getUserAchievementsUseCase(Ref ref) =>
    GetUserAchievementsUseCase(ref.watch(achievementRepositoryProvider));

@riverpod
SetActiveBorderUseCase setActiveBorderUseCase(Ref ref) =>
    SetActiveBorderUseCase(ref.watch(achievementRepositoryProvider));
