import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/cache/cache_providers.dart';
import '../../../../core/network/network_providers.dart';
import '../../data/datasources/regions_remote_datasource.dart';
import '../../data/repositories/regions_repository_impl.dart';
import '../../domain/entities/region.dart';

part 'regions_providers.g.dart';

@riverpod
RegionsRemoteDatasource regionsRemoteDatasource(Ref ref) =>
    RegionsRemoteDatasource(ref.watch(dioProvider));

@riverpod
RegionsRepositoryImpl regionsRepository(Ref ref) => RegionsRepositoryImpl(
  ref.watch(regionsRemoteDatasourceProvider),
  ref.watch(cachedJsonClientProvider),
);

/// Katalog wilayah (19 kecamatan + desa) dari CDN.
/// Null = offline/JSON rusak (soft-fail). referenceStatic: fresh 24 jam + SWR.
@riverpod
Future<List<Region>?> regions(Ref ref) =>
    ref.watch(regionsRepositoryProvider).getRegions();

/// Pull-to-refresh / tombol muat ulang: hard miss L1 lalu tunggu fetch.
@riverpod
Future<List<Region>?> regionsRefresh(Ref ref) =>
    ref.watch(regionsRepositoryProvider).getRegions(forceRefresh: true);

/// Hanya kecamatan (19) - untuk peta & panel.
@riverpod
Future<List<Region>> regionsKecamatan(Ref ref) async {
  final all = await ref.watch(regionsProvider.future);
  return (all ?? const <Region>[])
      .where((r) => r.type == RegionType.kecamatan)
      .toList();
}
