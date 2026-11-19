import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/cache/cache_entry.dart';
import 'package:sambasku_mobile/core/cache/cache_providers.dart';
import 'package:sambasku_mobile/core/cache/cached_json_client.dart';
import 'package:sambasku_mobile/core/cache/response_cache_store.dart';
import 'package:sambasku_mobile/core/network/connectivity_provider.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/features/dictionary/data/dataset/lemma_dataset_providers.dart';
import 'package:sambasku_mobile/features/dictionary/data/dataset/lemma_sticky_store.dart';
import 'package:sambasku_mobile/features/dictionary/domain/providers/dictionary_domain_providers.dart';

class _A implements HttpClientAdapter {
  int n = 0;
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    n++;
    print('ADAPTER $n');
    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'data': {
          'id': '01JWORDMAKAN0000000000000A',
          'lemma': 'makan',
          'language_id': 'lang-sbs',
          'word_type': 'word',
          'status': 'published',
          'is_verified': true,
          'is_corrected': false,
        },
      }),
      200,
      headers: {Headers.contentTypeHeader: ['application/json']},
    );
  }
  @override
  void close({bool force = false}) {}
}

class _Mem implements ResponseCacheStore {
  final Map<String, CacheEntry> _e = {};
  @override Future<void> open() async {}
  @override Future<CacheEntry?> get(String key) async => _e[key];
  @override Future<void> put({required String key, required String body, CacheScope scope = CacheScope.public}) async {
    final now = DateTime.now().toUtc();
    _e[key] = CacheEntry(key: key, body: body, cachedAt: now, lastAccess: now, sizeBytes: body.length, scope: scope, schemaVersion: 1);
  }
  @override Future<void> delete(String key) async => _e.remove(key);
  @override Future<void> deleteByPrefix(String prefix) async => _e.removeWhere((k, _) => k.startsWith(prefix));
  @override Future<void> wipeScope(CacheScope scope) async => _e.removeWhere((_, e) => e.scope == scope);
  @override Future<void> wipeAll() async => _e.clear();
  @override List<CacheEntryMeta> listMeta() => _e.values.map((e) => e.meta).toList();
  @override CacheEntry? peek(String key) => _e[key];
  @override int get entryCount => _e.length;
  @override int get totalBytes => _e.values.fold(0, (s, e) => s + e.sizeBytes);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('probe', () async {
    final mem = _Mem();
    final sticky = LemmaStickyStore();
    final adapter = _A();
    final c = ProviderContainer(overrides: [
      dioProvider.overrideWithValue(Dio(BaseOptions(baseUrl: 'https://example.com'))..httpClientAdapter = adapter),
      responseCacheStoreProvider.overrideWithValue(mem),
      cachedJsonClientProvider.overrideWithValue(CachedJsonClient(mem)),
      lemmaStickyStoreProvider.overrideWithValue(sticky),
      isOfflineProvider.overrideWith((ref) => Stream.value(false)),
    ]);
    addTearDown(c.dispose);
    c.listen(isOfflineProvider, (_, __) {});
    await Future<void>.delayed(Duration.zero);
    print('offlineAsync=${c.read(isOfflineProvider)} sticky=${sticky.isActive}');
    final either = await c.read(getWordByLemmaUseCaseProvider)('makan');
    either.match((f) => print('FAIL ${f.errorCode} ${f.message}'), (d) => print('OK ${d.id}'));
    print('hits=${adapter.n} stickyAfter=${sticky.isActive}');
  });
}
