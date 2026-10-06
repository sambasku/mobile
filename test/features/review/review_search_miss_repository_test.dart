import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/review/data/repositories/review_search_miss_repository_impl.dart';

void main() {
  test('parse list admin search-miss (belum tayang) + meta', () async {
    final repo = ReviewSearchMissRepositoryImpl(_dio({
      'success': true,
      'data': [
        {
          'id': '01HXAMPLE000000000000000A',
          'term': 'kepayang',
          'direction': 'lemma',
          'hit_count': 7,
          'last_searched_at': '2026-10-05T10:00:00.000Z',
          'is_fulfilled': false,
          'is_visible': false,
          'created_at': '2026-10-05T09:00:00.000Z',
        },
      ],
      'meta': {'limit': 50, 'next_cursor': null, 'has_more': false},
    }));

    final result = await repo.list(fulfilled: false, limit: 50);
    final page = result.getOrElse((l) => throw StateError('harus sukses'));

    expect(page.items.single.term, 'kepayang');
    expect(page.items.single.searchIn, 'lemma');
    expect(page.items.single.hitCount, 7);
    expect(page.items.single.isVisible, isFalse);
    expect(page.items.single.isFulfilled, isFalse);
    expect(page.hasMore, isFalse);
    expect(page.nextCursor, isNull);
  });

  test('setVisible mengirim PATCH is_visible ke path benar', () async {
    final requests = <RequestOptions>[];
    final dio = _dio({'success': true, 'data': null})
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests.add(options);
            handler.next(options);
          },
        ),
      );

    final repo = ReviewSearchMissRepositoryImpl(dio);
    final result = await repo.setVisible('01HXAMPLE000000000000000A', true);

    result.getOrElse((l) => throw StateError('harus sukses'));
    final req = requests.single;
    expect(req.path, contains('/api/v1/admin/search-misses/01HXAMPLE000000000000000A'));
    expect(req.method, 'PATCH');
    expect(req.data['is_visible'], true);
  });

  test('skip mengirim POST /:id/skip ke path benar', () async {
    final requests = <RequestOptions>[];
    final dio = _dio({'success': true, 'data': null})
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests.add(options);
            handler.next(options);
          },
        ),
      );

    final repo = ReviewSearchMissRepositoryImpl(dio);
    final result = await repo.skip('01HXAMPLE000000000000000A');

    result.getOrElse((l) => throw StateError('harus sukses'));
    final req = requests.single;
    expect(req.path, contains('/api/v1/admin/search-misses/01HXAMPLE000000000000000A/skip'));
    expect(req.method, 'POST');
  });

  test('error DioException dipetakan jadi ReviewFailure', () async {
    final dio = Dio(BaseOptions())..httpClientAdapter = _ErrorAdapter();
    final repo = ReviewSearchMissRepositoryImpl(dio);

    final result = await repo.list();

    final failure = result.swap().getOrElse((r) => throw StateError('harus gagal'));
    expect(failure.message, 'Gagal memuat pencarian kosong');
  });
}

Dio _dio(Map<String, dynamic> body) => Dio()..httpClientAdapter = _FakeAdapter(body);

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.body);

  final Map<String, dynamic> body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      ResponseBody.fromString(
        jsonEncode(body),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}

class _ErrorAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      ResponseBody.fromString('{}', 500, headers: const {});

  @override
  void close({bool force = false}) {}
}
