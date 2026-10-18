import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/cache/cache_entry.dart';
import 'package:sambasku_mobile/core/cache/cache_providers.dart';
import 'package:sambasku_mobile/core/cache/response_cache_store.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/features/contribution/presentation/providers/lemma_check_providers.dart';

/// Adapter meniru server:
/// /api/v1/words/lemma/makan → 200 detail; failPaths → network error;
/// lainnya → 404 WORD_NOT_FOUND. getWordByLemma tanpa cache branch
/// (repository di-inject tanpa dio cache) memakai datasource retrofit.
class _LemmaAdapter implements HttpClientAdapter {
  _LemmaAdapter({this.failPaths = const {}, this.delayMs = 0});

  final Set<String> failPaths;

  /// Delay buatan supaya stale-response race bisa diuji (ms timer).
  final int delayMs;
  int requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    final path = options.uri.path;
    if (delayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: delayMs));
    }
    if (failPaths.contains(path)) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'mock offline',
      );
    }
    final Object body;
    final int status;
    if (path == '/api/v1/words/lemma/makan') {
      status = 200;
      body = {
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
      };
    } else {
      status = 404;
      body = {
        'success': false,
        'error_code': 'WORD_NOT_FOUND',
        'message': 'Kata dengan lemma tersebut tidak ditemukan',
      };
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ProviderContainer _container(_LemmaAdapter adapter) => ProviderContainer(
  overrides: [
    dioProvider.overrideWithValue(Dio()..httpClientAdapter = adapter),
    responseCacheStoreProvider.overrideWithValue(_MemoryCacheStore()),
  ],
);

/// Store minimal supaya branch cache di repository jalan tanpa plugin.
class _MemoryCacheStore implements ResponseCacheStore {
  final Map<String, CacheEntry> _entries = {};

  @override
  Future<void> open() async {}

  @override
  Future<CacheEntry?> get(String key) async => _entries[key];

  @override
  Future<void> put({
    required String key,
    required String body,
    CacheScope scope = CacheScope.public,
  }) async {
    final now = DateTime.now().toUtc();
    _entries[key] = CacheEntry(
      key: key,
      body: body,
      cachedAt: now,
      lastAccess: now,
      sizeBytes: body.length,
      scope: scope,
      schemaVersion: 1,
    );
  }

  @override
  Future<void> delete(String key) async => _entries.remove(key);

  @override
  Future<void> deleteByPrefix(String prefix) async =>
      _entries.removeWhere((k, _) => k.startsWith(prefix));

  @override
  Future<void> wipeScope(CacheScope scope) async =>
      _entries.removeWhere((_, e) => e.scope == scope);

  @override
  Future<void> wipeAll() async => _entries.clear();

  @override
  List<CacheEntryMeta> listMeta() =>
      _entries.values.map((e) => e.meta).toList(growable: false);

  @override
  CacheEntry? peek(String key) => _entries[key];

  @override
  int get entryCount => _entries.length;

  @override
  int get totalBytes => _entries.values.fold(0, (sum, e) => sum + e.sizeBytes);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('lemma pendek (< 2 char) dan kosong tidak menembak request', () {
    fakeAsync((async) {
      final adapter = _LemmaAdapter();
      final container = _container(adapter);
      addTearDown(container.dispose);

      container.read(lemmaCheckProvider.notifier).onLemmaChanged('m');
      expect(container.read(lemmaCheckProvider).checking, isFalse);
      async.elapse(const Duration(seconds: 2));
      expect(adapter.requestCount, 0);
      expect(container.read(lemmaCheckProvider).exists, isNull);
    });
  });

  test('debounce: sebelum 600ms belum fetch, setelahnya selesai', () {
    fakeAsync((async) {
      final adapter = _LemmaAdapter();
      final container = _container(adapter);
      addTearDown(container.dispose);

      // autoDispose: tahan provider hidup lewat listener (mimik widget watch).
      final sub = container.listen(lemmaCheckProvider, (_, _) {});

      container.read(lemmaCheckProvider.notifier).onLemmaChanged('makan');
      expect(container.read(lemmaCheckProvider).checking, isTrue);
      async.elapse(const Duration(milliseconds: 300));
      expect(adapter.requestCount, 0, reason: 'masih dalam debounce');

      async.elapse(const Duration(milliseconds: 400));
      async.flushTimers();

      final state = container.read(lemmaCheckProvider);
      expect(adapter.requestCount, 1);
      expect(state.checking, isFalse);
      expect(state.exists, isTrue);
      expect(state.wordId, '01JWORDMAKAN0000000000000A');
      sub.close();
    });
  });

  test('404 WORD_NOT_FOUND → exists false', () {
    fakeAsync((async) {
      final adapter = _LemmaAdapter();
      final container = _container(adapter);
      addTearDown(container.dispose);

      final sub = container.listen(lemmaCheckProvider, (_, _) {});
      container.read(lemmaCheckProvider.notifier).onLemmaChanged('makatn');
      async.elapse(const Duration(seconds: 1));
      async.flushTimers();

      final state = container.read(lemmaCheckProvider);
      expect(state.checking, isFalse);
      expect(state.exists, isFalse);
      sub.close();
    });
  });

  test('network error → state unknown (diam), tanpa crash', () {
    fakeAsync((async) {
      final adapter = _LemmaAdapter(failPaths: {'/api/v1/words/lemma/makan'});
      final container = _container(adapter);
      addTearDown(container.dispose);

      container.read(lemmaCheckProvider.notifier).onLemmaChanged('makan');
      async.elapse(const Duration(seconds: 1));
      async.flushTimers();

      final state = container.read(lemmaCheckProvider);
      expect(state.checking, isFalse);
      expect(state.exists, isNull);
    });
  });

  test('response basi tidak menimpa state baru (reqId guard)', () {
    fakeAsync((async) {
      // 'makan' balas lambat (200 exists), 'makatn' balas cepat (404).
      // Ketik makan → tunggu debounce fetch terkirim → ketik makatn
      // SEBELUM jawaban makan tiba → jawaban makan harus dibuang.
      final adapter = _LemmaAdapter(delayMs: 500);
      final container = _container(adapter);
      addTearDown(container.dispose);

      final sub = container.listen(lemmaCheckProvider, (_, _) {});

      container.read(lemmaCheckProvider.notifier).onLemmaChanged('makan');
      async.elapse(const Duration(milliseconds: 700)); // fetch makan terkirim
      expect(adapter.requestCount, 1);

      container.read(lemmaCheckProvider.notifier).onLemmaChanged('makatn');
      async.elapse(const Duration(milliseconds: 700)); // fetch makatn terkirim
      expect(adapter.requestCount, 2);

      async.elapse(const Duration(milliseconds: 1000)); // jawaban makan tiba
      async.flushTimers();

      final state = container.read(lemmaCheckProvider);
      expect(state.exists, isFalse, reason: 'hasil makatn (404) bertahan');
      expect(state.checkedLemma, 'makatn');
      sub.close();
    });
  });
}
