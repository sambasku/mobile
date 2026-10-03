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
    return await ref
        .watch(contributorsRemoteDatasourceProvider)
        .fetchContributors();
  } catch (_) {
    return null;
  }
}
