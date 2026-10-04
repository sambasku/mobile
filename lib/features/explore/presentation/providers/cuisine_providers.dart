import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/cache/cache_providers.dart';
import '../../../../core/network/network_providers.dart';
import '../../data/datasources/cuisine_remote_datasource.dart';
import '../../data/repositories/cuisine_repository_impl.dart';
import '../../domain/entities/cuisine.dart';

part 'cuisine_providers.g.dart';

@riverpod
CuisineRemoteDatasource cuisineRemoteDatasource(Ref ref) =>
    CuisineRemoteDatasource(ref.watch(dioProvider));

@riverpod
CuisineRepositoryImpl cuisineRepository(Ref ref) => CuisineRepositoryImpl(
  ref.watch(cuisineRemoteDatasourceProvider),
  ref.watch(cachedJsonClientProvider),
);

/// Katalog cuisine dari CDN. Null = offline/JSON rusak (soft-fail).
/// referenceStatic: fresh 24 jam + SWR, update terlihat ≤24 jam.
@riverpod
Future<List<Cuisine>?> cuisine(Ref ref) =>
    ref.watch(cuisineRepositoryProvider).getCuisines();

/// Pull-to-refresh / tombol muat ulang: hard miss L1 lalu tunggu fetch.
@riverpod
Future<List<Cuisine>?> cuisineRefresh(Ref ref) =>
    ref.watch(cuisineRepositoryProvider).getCuisines(forceRefresh: true);
