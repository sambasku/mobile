import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/repositories/achievement_repository.dart';
import '../datasources/achievement_remote_datasource.dart';
import '../repositories/achievement_repository_impl.dart';

part 'achievement_data_providers.g.dart';

@riverpod
AchievementRemoteDatasource achievementRemoteDatasource(Ref ref) =>
    AchievementRemoteDatasource(ref.watch(dioProvider));

@riverpod
AchievementRepository achievementRepository(Ref ref) =>
    AchievementRepositoryImpl(ref.watch(achievementRemoteDatasourceProvider));
