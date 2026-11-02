import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/cache/cache_providers.dart';
import '../../../../core/network/network_providers.dart';
import '../../data/datasources/places_remote_datasource.dart';
import '../../data/repositories/places_repository_impl.dart';
import '../../domain/entities/place.dart';

part 'places_providers.g.dart';

@riverpod
PlacesRemoteDatasource placesRemoteDatasource(Ref ref) =>
    PlacesRemoteDatasource(ref.watch(dioProvider));

@riverpod
PlacesRepositoryImpl placesRepository(Ref ref) => PlacesRepositoryImpl(
  ref.watch(placesRemoteDatasourceProvider),
  ref.watch(cachedJsonClientProvider),
);

/// Katalog Place dari API publik. Null = offline/JSON rusak (soft-fail).
/// referenceStatic: fresh 24 jam + SWR, update terlihat ≤24 jam.
@riverpod
Future<List<Place>?> places(Ref ref) =>
    ref.watch(placesRepositoryProvider).getPlaces();

/// Pull-to-refresh / tombol muat ulang: hard miss L1 lalu tunggu fetch.
@riverpod
Future<List<Place>?> placesRefresh(Ref ref) =>
    ref.watch(placesRepositoryProvider).getPlaces(forceRefresh: true);

/// Detail satu place by slug. Pakai katalog yang sudah ada di memori;
/// kalau miss → `GET /places/:slug` (tidak tunggu walk katalog penuh).
@riverpod
Future<Place?> placeBySlug(Ref ref, String slug) async {
  final normalized = slug.trim();
  if (normalized.isEmpty) return null;
  final catalog = ref.watch(placesProvider).asData?.value;
  final hit = catalog?.where((p) => p.slug == normalized).firstOrNull;
  if (hit != null) return hit;
  return ref.watch(placesRepositoryProvider).fetchBySlug(normalized);
}
