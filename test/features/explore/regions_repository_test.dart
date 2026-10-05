import 'package:dio/dio.dart' as dio;
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/cache/cache_entry.dart';
import 'package:sambasku_mobile/core/cache/response_cache_store.dart';
import 'package:sambasku_mobile/core/cache/cached_json_client.dart';
import 'package:sambasku_mobile/features/explore/data/datasources/regions_remote_datasource.dart';
import 'package:sambasku_mobile/features/explore/data/models/regions_dto.dart';
import 'package:sambasku_mobile/features/explore/data/repositories/regions_repository_impl.dart';

/// Store kosong: cache selalu miss, jadi repo selalu memanggil fetch.
class _MemStore implements ResponseCacheStore {
  @override
  Future<CacheEntry?> get(String key) async => null;
  @override
  Future<void> put({
    required String key,
    required String body,
    CacheScope scope = CacheScope.public,
  }) async {}
  @override
  Future<void> delete(String key) async {}
  @override
  Future<void> deleteByPrefix(String prefix) async {}
  @override
  Future<void> wipeScope(CacheScope scope) async {}
  @override
  Future<void> wipeAll() async {}
  @override
  List<CacheEntryMeta> listMeta() => const [];
  @override
  CacheEntry? peek(String key) => null;
  @override
  int get entryCount => 0;
  @override
  int get totalBytes => 0;
  @override
  Future<void> open() async {}
}

/// Datasource palsu: body dikontrol test.
class _FakeDatasource implements RegionsRemoteDatasource {
  _FakeDatasource(this.body);
  final Object? body;

  @override
  Future<dio.Response<dynamic>> fetchRaw() async => _FakeResponse(body);
  @override
  Future<RegionsDto> fetchRegions() async {
    throw UnimplementedError();
  }
  @override
  String get configUrl => 'fake';
}

class _FakeResponse implements dio.Response<dynamic> {
  _FakeResponse(this.data);
  @override
  final Object? data;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('JSON valid -> daftar region (desa + kecamatan)', () async {
    final repo = RegionsRepositoryImpl(
      _FakeDatasource({
        'version': 1,
        'regions': [
          {
            'id': 'sambas',
            'name': 'Sambas',
            'type': 'kecamatan',
            'lat': 1.34,
            'lng': 109.31,
          },
          {'id': 'sambas/semeto', 'name': 'Semeto', 'type': 'desa', 'parentId': 'sambas'},
          {'name': 'rusak - di-skip'},
        ],
      }),
      CachedJsonClient(_MemStore()),
    );
    final result = await repo.getRegions();
    expect(result, isNotNull);
    expect(result, hasLength(2));
    expect(result![0].name, 'Sambas');
    expect(result[1].parentId, 'sambas');
  });

  test('fetch gagal -> null, tidak throw (soft-fail)', () async {
    final repo = RegionsRepositoryImpl(
      _FakeDatasource(null),
      CachedJsonClient(_MemStore()),
    );
    final result = await repo.getRegions();
    expect(result, isNull);
  });

  test('body rusak (regions bukan list) -> null', () async {
    final repo = RegionsRepositoryImpl(
      _FakeDatasource({'regions': 'bukan-list'}),
      CachedJsonClient(_MemStore()),
    );
    expect(await repo.getRegions(), isNull);
  });
}
