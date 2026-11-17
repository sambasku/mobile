import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../data/karya_api.dart';
import '../domain/karya.dart';

final karyaApiProvider = Provider<KaryaApi>(
  (ref) => KaryaApi(ref.watch(dioProvider)),
);

class KaryaBrowseQuery {
  const KaryaBrowseQuery({
    this.kind,
    this.q,
    this.year,
    this.language,
    this.sambasType,
  });

  final String? kind;
  final String? q;
  final int? year;
  final String? language;
  final String? sambasType;

  @override
  bool operator ==(Object other) =>
      other is KaryaBrowseQuery &&
      other.kind == kind &&
      other.q == q &&
      other.year == year &&
      other.language == language &&
      other.sambasType == sambasType;

  @override
  int get hashCode => Object.hash(kind, q, year, language, sambasType);
}

final karyaBrowseProvider = FutureProvider.autoDispose
    .family<List<KaryaEntry>, KaryaBrowseQuery>((ref, query) {
  return ref.watch(karyaApiProvider).list(
        kind: query.kind,
        q: query.q,
        year: query.year,
        language: query.language,
        sambasType: query.sambasType,
      );
});

final karyaBySlugProvider = FutureProvider.autoDispose
    .family<KaryaEntry?, String>((ref, slug) {
  return ref.watch(karyaApiProvider).bySlug(slug);
});

final karyaMineProvider =
    FutureProvider.autoDispose<List<KaryaProposal>>((ref) {
  return ref.watch(karyaApiProvider).mine();
});

final kreatorBySlugProvider = FutureProvider.autoDispose
    .family<KreatorProfile?, String>((ref, slug) {
  return ref.watch(karyaApiProvider).kreatorBySlug(slug);
});