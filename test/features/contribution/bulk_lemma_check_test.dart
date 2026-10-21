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
import 'package:sambasku_mobile/features/contribution/presentation/providers/bulk_lemma_check_provider.dart';
import 'package:sambasku_mobile/features/contribution/presentation/providers/bulk_submit_word_providers.dart';

class _LemmaAdapter implements HttpClientAdapter {
  int requestCount = 0;
  final List<String> paths = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    final path = options.uri.path;
    paths.add(path);
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

ProviderContainer _container(_LemmaAdapter adapter) => ProviderContainer(
  overrides: [
    dioProvider.overrideWithValue(Dio()..httpClientAdapter = adapter),
    responseCacheStoreProvider.overrideWithValue(_MemoryCacheStore()),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('lemma pendek dan duplikat kapital tidak menggandakan cek', () {
    expect(bulkLemmasToCheck(['a', '  ', 'Makan', 'makan']), {
      'makan': 'Makan',
    });
  });

  test('debounce: ketukan beruntun satu request, icon id hanya jika ada', () {
    fakeAsync((async) {
      final adapter = _LemmaAdapter();
      final container = _container(adapter);
      addTearDown(container.dispose);

      final sub = container.listen(bulkLemmaCheckProvider, (_, _) {});
      final rows = container.read(bulkSubmitWordProvider.notifier);

      rows.updateRow('row_0', lemma: 'ma');
      async.elapse(const Duration(milliseconds: 200));
      rows.updateRow('row_0', lemma: 'makan');
      async.elapse(const Duration(milliseconds: 300));
      expect(adapter.requestCount, 0);
      expect(container.read(bulkLemmaCheckProvider)['makan']?.wordId, isNull);

      async.elapse(const Duration(milliseconds: 400));
      async.flushTimers();

      expect(adapter.requestCount, 1);
      expect(adapter.paths.single, '/api/v1/words/lemma/makan');
      expect(
        container.read(bulkLemmaCheckProvider)['makan']?.wordId,
        '01JWORDMAKAN0000000000000A',
      );
      sub.close();
    });
  });

  test('dua baris lemma sama hanya satu request', () {
    fakeAsync((async) {
      final adapter = _LemmaAdapter();
      final container = _container(adapter);
      addTearDown(container.dispose);

      final sub = container.listen(bulkLemmaCheckProvider, (_, _) {});
      final rows = container.read(bulkSubmitWordProvider.notifier);
      rows.updateRow('row_0', lemma: 'makan');
      rows.updateRow('row_1', lemma: 'Makan');
      async.elapse(const Duration(milliseconds: 700));
      async.flushTimers();

      expect(adapter.requestCount, 1);
      expect(container.read(bulkLemmaCheckProvider)['makan']?.exists, isTrue);
      sub.close();
    });
  });

  test(
    '404 tidak mengisi wordId dan tidak diulang saat baris lain berubah',
    () {
      fakeAsync((async) {
        final adapter = _LemmaAdapter();
        final container = _container(adapter);
        addTearDown(container.dispose);

        final sub = container.listen(bulkLemmaCheckProvider, (_, _) {});
        final rows = container.read(bulkSubmitWordProvider.notifier);
        rows.updateRow('row_0', lemma: 'oke');
        async.elapse(const Duration(milliseconds: 700));
        async.flushTimers();
        expect(adapter.requestCount, 1);
        final mark = container.read(bulkLemmaCheckProvider)['oke'];
        expect(mark?.exists, isFalse);
        expect(mark?.wordId, isNull);

        rows.updateRow('row_1', lemma: 'makan');
        async.elapse(const Duration(milliseconds: 700));
        async.flushTimers();

        expect(adapter.requestCount, 2);
        expect(adapter.paths.last, '/api/v1/words/lemma/makan');
        sub.close();
      });
    },
  );
}
