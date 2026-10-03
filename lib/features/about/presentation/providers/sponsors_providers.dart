import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/datasources/sponsors_remote_datasource.dart';

part 'sponsors_providers.g.dart';

@riverpod
SponsorsRemoteDatasource sponsorsRemoteDatasource(Ref ref) =>
    SponsorsRemoteDatasource(ref.watch(dioProvider));

/// Data sponsor dari CDN. Null = offline/JSON rusak → sembunyikan section.
/// Data statis jarang berubah; tanpa cache khusus (YAGNI, list kecil).
@riverpod
Future<List<SponsorEntry>?> sponsors(Ref ref) async {
  try {
    return await ref.watch(sponsorsRemoteDatasourceProvider).fetchSponsors();
  } catch (_) {
    return null;
  }
}
