import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../data/layanan_api.dart';
import '../domain/layanan.dart';

final layananApiProvider = Provider<LayananApi>(
  (ref) => LayananApi(ref.watch(dioProvider)),
);

final layananByRegionProvider = FutureProvider.autoDispose
    .family<List<LayananEntry>, String>((ref, regionId) {
  return ref.watch(layananApiProvider).list(regionId: regionId);
});

final layananBySlugProvider = FutureProvider.autoDispose
    .family<LayananEntry?, String>((ref, slug) {
  return ref.watch(layananApiProvider).bySlug(slug);
});

final layananMineProvider = FutureProvider.autoDispose<List<LayananProposal>>((ref) {
  return ref.watch(layananApiProvider).mine();
});

const layananKecamatanPrefKey = 'layanan_last_kecamatan_id';
