import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/network/auth_token_storage.dart';
import 'package:sambasku_mobile/core/network/failover/api_host_resolver.dart';
import 'package:sambasku_mobile/core/network/interceptors/auth_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'URL absolut eksternal tidak diberi header Authorization (cegah 404 GitHub + bocor JWT)',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        'accessToken': 'sambasku-access-token',
        'refreshToken': 'sambasku-refresh-token',
      });
      SharedPreferences.setMockInitialValues({'isAuth': true});
      final storage = AuthTokenStorage();
      await storage.setIsAuth(true);

      final seenAuth = <String, Object?>{};
      final adapter = _RecordingAdapter((options) {
        seenAuth[options.path] = options.headers['Authorization'];
        return ResponseBody.fromString(
          jsonEncode({'ok': true}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      ApiHostResolver.instance.configure(
        primaryHost: 'https://api.test',
        fallbackHosts: const ['https://fallback.test'],
      );

      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = adapter
        ..interceptors.add(
          AuthInterceptor(
            tokenStorage: storage,
            hostResolver: ApiHostResolver.instance,
          ),
        );

      const extUrl =
          'https://raw.githubusercontent.com/sambasku/database/main/metadata/active.json';
      await dio.get<Object?>(extUrl);
      await dio.get<Object?>('/api/v1/words');
      await dio.get<Object?>('https://api.test/api/v1/words');
      await dio.get<Object?>('https://fallback.test/api/v1/words');

      expect(seenAuth[extUrl], isNull);
      expect(seenAuth['/api/v1/words'], 'Bearer sambasku-access-token');
      expect(
        seenAuth['https://api.test/api/v1/words'],
        'Bearer sambasku-access-token',
      );
      expect(
        seenAuth['https://fallback.test/api/v1/words'],
        'Bearer sambasku-access-token',
      );
    },
  );
}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this._handler);

  final FutureOr<ResponseBody> Function(RequestOptions options) _handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => await _handler(options);
}
