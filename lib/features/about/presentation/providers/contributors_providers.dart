import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/datasources/contributors_remote_datasource.dart';

part 'contributors_providers.g.dart';

@riverpod
ContributorsRemoteDatasource contributorsRemoteDatasource(Ref ref) =>
    ContributorsRemoteDatasource(ref.watch(dioProvider));

/// Data kontributor dari CDN. Null = offline/JSON rusak → sembunyikan
/// section. Data statis jarang berubah; tanpa cache khusus (YAGNI, list
/// kecil).
@riverpod
Future<List<ContributorEntry>?> contributors(Ref ref) async {
  try {
    final list = await ref
        .watch(contributorsRemoteDatasourceProvider)
        .fetchContributors();
    return list;
  } catch (_) {
    return null;
  }
}

/// Map id → username untuk lookup kredit internal (penulis artikel/foto).
/// Null = offline/JSON rusak. Lookup lokal, tanpa fetch tambahan.
@riverpod
Future<Map<String, String>?> contributorsIdToUsername(Ref ref) async {
  final list = await ref.watch(contributorsProvider.future);
  if (list == null) return null;
  return {
    for (final c in list)
      if (c.username != null) c.id: c.username!,
  };
}
