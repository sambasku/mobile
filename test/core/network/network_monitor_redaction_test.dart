import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/network/interceptors/network_monitor_interceptor.dart';
import 'package:sambasku_mobile/shared/dev_tool/network_monitor/data/repositories/in_memory_network_monitor_repository.dart';

/// DevTool Network Monitor tidak boleh menyimpan rahasia di memori/
/// ringkasan (#73): header auth, field credential, token.
void main() {
  late InMemoryNetworkMonitorRepository repo;
  late NetworkMonitorInterceptor interceptor;

  setUp(() {
    repo = InMemoryNetworkMonitorRepository();
    interceptor = NetworkMonitorInterceptor(repository: repo);
  });

  RequestOptions req(
    String path, {
    Object? data,
    Map<String, dynamic>? headers,
  }) => RequestOptions(
    path: path,
    method: 'POST',
    data: data,
    headers: headers ?? const {},
  );

  test('header Authorization / Cookie di-*redact*', () {
    interceptor.onRequest(
      req(
        '/v1/login',
        headers: {
          'Authorization': 'Bearer super-secret',
          'Cookie': 'session=abc',
          'Content-Type': 'application/json',
        },
      ),
      RequestInterceptorHandler(),
    );

    final record = repo.getRecords().first;
    expect(record.requestHeaders['Authorization'], '***');
    expect(record.requestHeaders['Cookie'], '***');
    expect(
      record.requestHeaders['Content-Type'],
      'application/json',
      reason: 'header non-rahasia tetap terlihat',
    );
    expect(
      record.requestHeaders.values.join(),
      isNot(contains('super-secret')),
    );
  });

  test('field credential di body di-*redact*, field lain utuh', () {
    interceptor.onRequest(
      req(
        '/v1/login',
        data: {
          'email': 'user@sambasku.com',
          'password': 'raw-password',
          'refresh_token': 'raw-refresh',
          'new_password': 'raw-new',
          'confirm_password': 'raw-confirm',
          'otp': '123456',
          'username': 'player1',
        },
      ),
      RequestInterceptorHandler(),
    );

    final body = repo.getRecords().first.requestBody!;
    expect(body, contains('user@sambasku.com'));
    expect(body, contains('player1'));
    expect(body, isNot(contains('raw-password')));
    expect(body, isNot(contains('raw-refresh')));
    expect(body, isNot(contains('raw-new')));
    expect(body, isNot(contains('raw-confirm')));
    expect(body, isNot(contains('123456')));
    expect(body, contains('***'));
  });

  test('response Set-Cookie di-*redact*', () {
    final options = req('/v1/session');
    interceptor.onRequest(options, RequestInterceptorHandler());
    interceptor.onResponse(
      Response(
        requestOptions: options,
        statusCode: 200,
        headers: Headers.fromMap({
          'set-cookie': ['sid=raw-session'],
          'content-type': ['application/json'],
        }),
        data: {'ok': true},
      ),
      ResponseInterceptorHandler(),
    );

    final record = repo.getRecords().first;
    expect(record.responseHeaders['set-cookie'], '***');
    expect(
      record.responseHeaders.values.join(),
      isNot(contains('raw-session')),
    );
  });

  test('histori dibatasi 200 record (cap ringkas)', () {
    for (var i = 0; i < 230; i++) {
      interceptor.onRequest(req('/v1/seed-$i'), RequestInterceptorHandler());
    }
    expect(repo.getRecords().length, 200);
  });
}
