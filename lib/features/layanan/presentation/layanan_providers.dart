import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../data/layanan_api.dart';
import '../domain/layanan.dart';

final layananApiProvider = Provider<LayananApi>(
  (ref) => LayananApi(ref.watch(dioProvider)),
);

/// Kunci daftar: ganti chip/filter = fetch baru.
class LayananBrowseQuery {
  const LayananBrowseQuery({this.regionId, this.category});

  final String? regionId;

  /// `ambulance` | `fire` | null = semua.
  final String? category;

  @override
  bool operator ==(Object other) =>
      other is LayananBrowseQuery &&
      other.regionId == regionId &&
      other.category == category;

  @override
  int get hashCode => Object.hash(regionId, category);
}

final layananBrowseProvider = FutureProvider.autoDispose
    .family<List<LayananEntry>, LayananBrowseQuery>((ref, query) {
  return ref.watch(layananApiProvider).list(
        regionId: query.regionId,
        category: query.category,
      );
});

final layananBySlugProvider = FutureProvider.autoDispose
    .family<LayananEntry?, String>((ref, slug) {
  return ref.watch(layananApiProvider).bySlug(slug);
});

final layananMineProvider =
    FutureProvider.autoDispose<List<LayananProposal>>((ref) {
  return ref.watch(layananApiProvider).mine();
});
