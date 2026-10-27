import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/network_providers.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/culinary_contribution_api.dart';
import '../../data/datasources/cuisine_remote_datasource.dart';
import '../../data/models/cuisine_dto.dart';
import '../../data/repositories/cuisine_repository_impl.dart';
import '../../domain/entities/cuisine.dart';
import '../../domain/entities/culinary_proposal.dart';
part 'cuisine_providers.g.dart';

@riverpod
CuisineRemoteDatasource cuisineRemoteDatasource(Ref ref) =>
    CuisineRemoteDatasource(ref.watch(dioProvider));

@riverpod
CuisineRepositoryImpl cuisineRepository(Ref ref) =>
    CuisineRepositoryImpl(ref.watch(cuisineRemoteDatasourceProvider));

/// Katalog kuliner dari API. Null = offline/error (soft-fail) supaya UI
/// menampilkan tombol coba lagi, bukan crash.
@riverpod
Future<List<Cuisine>?> cuisine(Ref ref) async {
  try {
    return await ref.watch(cuisineRepositoryProvider).getAll();
  } catch (_) {
    return null;
  }
}

/// Pull-to-refresh / tombol muat ulang: fetch ulang penuh dari API.
@riverpod
Future<List<Cuisine>?> cuisineRefresh(Ref ref) async {
  try {
    return await ref.watch(cuisineRepositoryProvider).getAll();
  } catch (_) {
    return null;
  }
}

/// Detail satu kuliner by slug + daftar tempat penyedia.
@riverpod
Future<CuisineDtoItem?> cuisineBySlug(Ref ref, String slug) =>
    ref.watch(cuisineRepositoryProvider).getBySlug(slug);

@riverpod
CulinaryContributionApi culinaryContributionApi(Ref ref) =>
    CulinaryContributionApi(ref.watch(dioProvider));

/// Usulan kuliner milik user login. Guest = list kosong (bukan error),
/// pola sama dengan usulan acara/usaha.
@riverpod
Future<List<CulinaryProposal>> culinaryProposals(Ref ref) async {
  final auth = ref.watch(authStatusProvider).value;
  if (!(auth?.isAuth ?? false)) return const [];
  return ref.watch(culinaryContributionApiProvider).mine();
}

/// Daftar tempat/penjual kuliner (halaman pertama). Null = gagal (soft-fail).
@riverpod
Future<CulinaryPlacePage?> culinaryPlaces(Ref ref, {String? q, String? type}) async {
  try {
    return await ref.watch(cuisineRepositoryProvider).places(q: q, type: type);
  } catch (_) {
    return null;
  }
}
