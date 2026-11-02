import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/datasources/usaha_remote_datasource.dart';
import '../../data/repositories/usaha_repository_impl.dart';
import '../../domain/entities/usaha.dart';

part 'usaha_providers.g.dart';

@riverpod
UsahaRemoteDatasource usahaRemoteDatasource(Ref ref) =>
    UsahaRemoteDatasource(ref.watch(dioProvider));

@riverpod
UsahaRepositoryImpl usahaRepository(Ref ref) =>
    UsahaRepositoryImpl(ref.watch(usahaRemoteDatasourceProvider));

@riverpod
UsahaContributionApi usahaContributionApi(Ref ref) =>
    UsahaContributionApi(ref.watch(dioProvider));

/// Detail usaha by slug. Null = 404 atau dibatasi (restricted).
@riverpod
Future<Usaha?> usahaBySlug(Ref ref, String slug) =>
    ref.watch(usahaRepositoryProvider).getBySlug(slug);

/// Katalog kategori usaha (published).
@riverpod
Future<List<UsahaCategoryRef>> usahaCategories(Ref ref) =>
    ref.watch(usahaRepositoryProvider).categories();

/// Usaha yang saya kelola. Guest = data kosong (bukan error).
@Riverpod(keepAlive: true)
class UsahaMineController extends _$UsahaMineController {
  @override
  Future<UsahaMine> build() async {
    final auth = ref.watch(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) {
      return const UsahaMine(items: [], pendingClaimCount: 0);
    }
    return ref.watch(usahaRepositoryProvider).mine();
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Usulan usaha milik user (status usulan).
@Riverpod(keepAlive: true)
class UsahaProposalsController extends _$UsahaProposalsController {
  @override
  Future<List<UsahaContribution>> build() async {
    final auth = ref.watch(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) return const [];
    return ref.watch(usahaContributionApiProvider).mine();
  }

  Future<void> cancel(String id) async {
    await ref.read(usahaContributionApiProvider).cancel(id);
    ref.invalidateSelf();
  }
}

/// Klaim pengelolaan milik user.
@Riverpod(keepAlive: true)
class UsahaClaimsController extends _$UsahaClaimsController {
  @override
  Future<List<UsahaClaim>> build() async {
    final auth = ref.watch(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) return const [];
    return ref.watch(usahaContributionApiProvider).myClaims();
  }

  Future<void> cancel(String id) async {
    await ref.read(usahaContributionApiProvider).cancelClaim(id);
    ref.invalidateSelf();
  }
}
