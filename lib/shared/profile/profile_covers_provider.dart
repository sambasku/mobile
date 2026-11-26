import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/cache/cache_entry.dart';
import '../../core/cache/cache_key.dart';
import '../../core/cache/cache_providers.dart';
import '../../core/network/network_providers.dart';
import 'profile_covers.dart';

const _profileCoversPath = '/api/v1/about/profile-covers';

/// Cache L1 + SWR (TTL pendek: admin bisa ganti cover). Gagal → null.
final profileCoversProvider = FutureProvider<ProfileCovers?>((ref) async {
  ref.keepAlive();
  final cache = ref.watch(cachedJsonClientProvider);
  final dio = ref.watch(dioProvider);
  final key = buildCacheKey(method: 'GET', path: _profileCoversPath);

  try {
    final envelope = await cache.getOrFetch(
      key: key,
      cacheClass: CacheClass.feedList,
      fetch: () async {
        final resp = await dio.get<Map<String, dynamic>>(
          _profileCoversPath,
          options: Options(receiveTimeout: const Duration(seconds: 5)),
        );
        final body = resp.data;
        if (body == null) {
          throw StateError('Cover profil: envelope kosong');
        }
        return body;
      },
    );
    return ProfileCovers.fromEnvelope(envelope);
  } catch (_) {
    return null;
  }
});