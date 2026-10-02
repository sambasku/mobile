import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/cache/cache_entry.dart';
import '../../../../core/cache/cache_key.dart';
import '../../../../core/cache/cache_providers.dart';
import '../../../../core/constants/env.dart';
import '../../../../core/network/network_providers.dart';
import '../../data/card_images_config.dart';

part 'card_images_providers.g.dart';

/// Config card dari CDN. Null = fetch gagal / JSON rusak → pakai asset.
/// CacheClass.referenceStatic: fresh 24 jam + SWR — perubahan config
/// terlihat paling lambat ±24 jam, tanpa traffic worker.
@riverpod
Future<CardImagesConfig?> cardImages(Ref ref) async {
  final cache = ref.watch(cachedJsonClientProvider);
  final dio = ref.watch(dioProvider);
  final key = buildCacheKey(method: 'GET', path: '/cdn/mobile/home.json');
  // URL dari env per flavor; fallback konstanta jika env kosong.
  final url = Env.cardConfigUrl ?? kDefaultCardConfigUrl;

  try {
    final data = await cache.getOrFetch(
      key: key,
      cacheClass: CacheClass.referenceStatic,
      fetch: () async {
        final resp = await dio.get<dynamic>(
          url,
          options: Options(receiveTimeout: const Duration(seconds: 5)),
        );
        final body = resp.data;
        if (body is! Map) throw StateError('Envelope home.json tidak valid');
        return Map<String, dynamic>.from(body);
      },
    );
    return CardImagesConfig.tryParse(data);
  } catch (_) {
    return null; // soft-fail: offline / CDN down → asset bundled
  }
}
