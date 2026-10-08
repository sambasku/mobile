import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/admin_analytics/data/repositories/dashboard_repository_impl.dart';

/// Stub adapter: balas dengan status + body tetap (pola
/// announcement_detail_provider_test).
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.status, this.body);

  final int status;
  final String body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dio(int status, {String body = '{"data": []}'}) =>
    Dio()..httpClientAdapter = _StubAdapter(status, body);

void main() {
  group('DashboardRepositoryImpl authz (#69)', () {
    test(
      '401 di endpoint admin MELEMPAR (bukan diam-diam return [])',
      () async {
        final repo = DashboardRepositoryImpl(
          _dio(401, body: '{"error_code":"UNAUTHORIZED"}'),
        );
        await expectLater(
          repo.latestActivity(),
          throwsA(
            isA<DioException>().having(
              (e) => e.response?.statusCode,
              'statusCode',
              401,
            ),
          ),
        );
      },
    );

    test('403 di endpoint admin MELEMPAR', () async {
      final repo = DashboardRepositoryImpl(
        _dio(403, body: '{"error_code":"FORBIDDEN"}'),
      );
      await expectLater(repo.latestActivity(), throwsA(isA<DioException>()));
    });

    test(
      'error server (500) TETAP return [] - resilience activity list',
      () async {
        final repo = DashboardRepositoryImpl(_dio(500, body: '{}'));
        final items = await repo.latestActivity();
        expect(items, isEmpty);
      },
    );
  });
}
