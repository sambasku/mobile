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

  late AuthTokenStorage storage;
  late _RecordingAdapter adapter;
  late Dio dio;
  late Dio refreshDio;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({
      'accessToken': 'stale-access',
      'refreshToken': 'stale-refresh',
    });
    SharedPreferences.setMockInitialValues({'isAuth': true});
    storage = AuthTokenStorage();
    await storage.setIsAuth(true);

    adapter = _RecordingAdapter();
    refreshDio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    refreshDio.httpClientAdapter = adapter;

    dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    dio.httpClientAdapter = adapter;
    // Satu tier saja: test ini soal alur 401, bukan failover.
    ApiHostResolver.instance.configure(
      primaryHost: 'https://api.test',
      fallbackHosts: const [],
    );
    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: storage,
        hostResolver: ApiHostResolver.instance,
        refreshDio: refreshDio,
      ),
    );
  });

  test(
    '401 + refresh gagal → clearTokens sekali, tidak panggil /device/revoke',
    () async {
      var refreshHits = 0;
      adapter.handler = (options) {
        if (options.path.contains('/auth/refresh')) {
          refreshHits++;
          return _json(401, {
            'success': false,
            'error': {'code': 'UNAUTHORIZED'},
          });
        }
        if (options.path.contains('/device/revoke')) {
          fail(
            'Interceptor tidak boleh memanggil /device/revoke saat session-death',
          );
        }
        return _json(401, {
          'success': false,
          'error': {'code': 'UNAUTHORIZED'},
        });
      };

      await expectLater(
        () => dio.get('/api/v1/words/w1'),
        throwsA(isA<DioException>()),
      );

      expect(refreshHits, 1);
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
      expect(await storage.getIsAuth(), isFalse);
    },
  );

  test('401 pada /auth/google tidak memicu POST /auth/refresh', () async {
    var refreshHits = 0;
    var googleHits = 0;
    adapter.handler = (options) {
      if (options.path.contains('/auth/refresh')) {
        refreshHits++;
        return _json(200, {
          'success': true,
          'data': {
            'access_token': 'new-access',
            'refresh_token': 'new-refresh',
          },
        });
      }
      if (options.path.contains('/auth/google')) {
        googleHits++;
        return _json(401, {
          'success': false,
          'error_code': 'INVALID_GOOGLE_TOKEN',
          'message': 'Tidak bisa masuk dengan Google.',
        });
      }
      return _json(500, {'success': false});
    };

    await expectLater(
      () => dio.post('/api/v1/auth/google', data: {'id_token': 'tok'}),
      throwsA(isA<DioException>()),
    );

    expect(googleHits, 1);
    expect(refreshHits, 0);
    expect(await storage.getAccessToken(), 'stale-access');
  });

  test('401 pada /device/revoke tidak memicu POST /auth/refresh', () async {
    var refreshHits = 0;
    var revokeHits = 0;
    adapter.handler = (options) {
      if (options.path.contains('/auth/refresh')) {
        refreshHits++;
        return _json(200, {
          'success': true,
          'data': {
            'access_token': 'new-access',
            'refresh_token': 'new-refresh',
          },
        });
      }
      if (options.path.contains('/device/revoke')) {
        revokeHits++;
        return _json(401, {
          'success': false,
          'error': {'code': 'UNAUTHORIZED'},
        });
      }
      return _json(500, {'success': false});
    };

    await expectLater(
      () => dio.patch('/api/v1/device/revoke', data: {'udid': 'dev-1'}),
      throwsA(isA<DioException>()),
    );

    expect(revokeHits, 1);
    expect(refreshHits, 0);
    expect(await storage.getAccessToken(), 'stale-access');
  });

  test(
    '401 pada /device/register tidak memicu refresh / clear session (#171)',
    () async {
      var refreshHits = 0;
      var registerHits = 0;
      adapter.handler = (options) {
        if (options.path.contains('/auth/refresh')) {
          refreshHits++;
          return _json(401, {'success': false});
        }
        if (options.path.contains('/device/register')) {
          registerHits++;
          return _json(401, {
            'success': false,
            'error_code': 'UNAUTHORIZED',
            'message': 'Token tidak valid atau kadaluarsa',
          });
        }
        return _json(500, {'success': false});
      };

      await expectLater(
        () => dio.post(
          '/api/v1/device/register',
          data: {'udid': 'dev-1', 'fcm_token': 'fcm-1'},
        ),
        throwsA(isA<DioException>()),
      );

      expect(registerHits, 1);
      expect(refreshHits, 0);
      // Sesi TIDAK boleh ikut terhapus - register FCM best-effort.
      expect(await storage.getAccessToken(), 'stale-access');
      expect(await storage.getRefreshToken(), 'stale-refresh');
      expect(await storage.getIsAuth(), isTrue);
    },
  );

  test(
    'refresh terminal tidak clear sesi yang diganti login di tengah jalan',
    () async {
      // Simulasi: 401 → refresh mulai → login Google menimpa token →
      // refresh gagal 401. Clear harus skip supaya profil tidak 401.
      final refreshStarted = Completer<void>();
      final loginDone = Completer<void>();
      var refreshHits = 0;

      adapter.handler = (options) async {
        if (options.path.contains('/auth/refresh')) {
          refreshHits++;
          if (!refreshStarted.isCompleted) refreshStarted.complete();
          await loginDone.future;
          return _json(401, {
            'success': false,
            'error_code': 'UNAUTHORIZED',
          });
        }
        return _json(401, {'success': false});
      };

      final pending = dio.get('/api/v1/words/w1');
      await refreshStarted.future;
      await storage.saveTokens(
        accessToken: 'fresh-access',
        refreshToken: 'fresh-refresh',
      );
      await storage.setIsAuth(true);
      loginDone.complete();

      await expectLater(pending, throwsA(isA<DioException>()));
      expect(refreshHits, 1);
      expect(await storage.getAccessToken(), 'fresh-access');
      expect(await storage.getRefreshToken(), 'fresh-refresh');
      expect(await storage.getIsAuth(), isTrue);
    },
  );

  test(
    'refresh 200 tidak menimpa token yang ditulis login di tengah jalan',
    () async {
      // Race B: refresh usang SUKSES setelah login Google. Jangan
      // saveTokens hasil refresh di atas sesi baru (generation bump).
      final refreshStarted = Completer<void>();
      final loginDone = Completer<void>();
      var refreshHits = 0;
      var wordHits = 0;

      adapter.handler = (options) async {
        if (options.path.contains('/auth/refresh')) {
          refreshHits++;
          if (!refreshStarted.isCompleted) refreshStarted.complete();
          await loginDone.future;
          return _json(200, {
            'success': true,
            'data': {
              'access_token': 'from-stale-refresh',
              'refresh_token': 'from-stale-refresh-rt',
            },
          });
        }
        if (options.path.contains('/words/w1')) {
          wordHits++;
          return _json(401, {'success': false});
        }
        return _json(500, {'success': false});
      };

      final pending = dio.get('/api/v1/words/w1');
      await refreshStarted.future;
      await storage.saveTokens(
        accessToken: 'google-access',
        refreshToken: 'google-refresh',
      );
      await storage.setIsAuth(true);
      loginDone.complete();

      // Refresh transient → request asli tetap gagal 401, tapi sesi Google
      // tidak boleh tertimpa token dari refresh usang.
      await expectLater(pending, throwsA(isA<DioException>()));
      expect(refreshHits, 1);
      expect(wordHits, 1);
      expect(await storage.getAccessToken(), 'google-access');
      expect(await storage.getRefreshToken(), 'google-refresh');
      expect(await storage.getIsAuth(), isTrue);
    },
  );

  test('401 + extra skipAuthRefresh tidak memicu refresh', () async {
    var refreshHits = 0;
    adapter.handler = (options) {
      if (options.path.contains('/auth/refresh')) {
        refreshHits++;
        return _json(200, {
          'success': true,
          'data': {
            'access_token': 'new-access',
            'refresh_token': 'new-refresh',
          },
        });
      }
      return _json(401, {'success': false});
    };

    await expectLater(
      () => dio.get(
        '/api/v1/words/w1',
        options: Options(extra: {kSkipAuthRefreshExtra: true}),
      ),
      throwsA(isA<DioException>()),
    );

    expect(refreshHits, 0);
    expect(await storage.getAccessToken(), 'stale-access');
  });

  test('401 + refresh sukses → retry request asli sekali', () async {
    var refreshHits = 0;
    var wordHits = 0;
    adapter.handler = (options) {
      if (options.path.contains('/auth/refresh')) {
        refreshHits++;
        return _json(200, {
          'success': true,
          'data': {
            'access_token': 'new-access',
            'refresh_token': 'new-refresh',
          },
        });
      }
      if (options.path.contains('/words/w1')) {
        wordHits++;
        if (wordHits == 1) {
          return _json(401, {'success': false});
        }
        return _json(200, {
          'success': true,
          'data': {'id': 'w1'},
        });
      }
      return _json(500, {'success': false});
    };

    final res = await dio.get('/api/v1/words/w1');
    expect(res.statusCode, 200);
    expect(refreshHits, 1);
    expect(wordHits, 2);
    expect(await storage.getAccessToken(), 'new-access');
    expect(await storage.getRefreshToken(), 'new-refresh');
  });

  test('timeout saat refresh tidak menghapus sesi', () async {
    adapter.handler = (options) {
      if (options.path.contains('/auth/refresh')) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        );
      }
      return _json(401, {'success': false});
    };

    await expectLater(
      () => dio.get('/api/v1/words/w1'),
      throwsA(isA<DioException>()),
    );

    expect(await storage.getAccessToken(), 'stale-access');
    expect(await storage.getRefreshToken(), 'stale-refresh');
    expect(await storage.getIsAuth(), isTrue);
  });

  test('refresh sukses lalu retry 500 tidak menghapus sesi', () async {
    var wordHits = 0;
    adapter.handler = (options) {
      if (options.path.contains('/auth/refresh')) {
        return _json(200, {
          'success': true,
          'data': {
            'access_token': 'new-access',
            'refresh_token': 'new-refresh',
          },
        });
      }
      wordHits++;
      if (wordHits == 1) return _json(401, {'success': false});
      return _json(500, {'success': false});
    };

    await expectLater(
      () => dio.get('/api/v1/words/w1'),
      throwsA(isA<DioException>()),
    );

    expect(await storage.getAccessToken(), 'new-access');
    expect(await storage.getRefreshToken(), 'new-refresh');
    expect(await storage.getIsAuth(), isTrue);
  });

  test(
    'refresh transient gagal → backoff: 401 berikutnya tak refresh ulang',
    () async {
      var refreshHits = 0;
      adapter.handler = (options) {
        if (options.path.contains('/auth/refresh')) {
          refreshHits++;
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
          );
        }
        return _json(401, {'success': false});
      };

      // Burst 3 request 401 bersamaan → 1 refresh (single-flight).
      final results = await Future.wait(
        [1, 2, 3]
            .map((_) => dio.get('/api/v1/words/w1'))
            .map((f) => f.then<Response?>((r) => r).catchError((_) => null)),
      );
      expect(results.every((r) => r == null), isTrue);
      expect(refreshHits, 1);

      // 401 baru segera setelah transient → backoff aktif, tak refresh ulang.
      await expectLater(
        () => dio.get('/api/v1/words/w1'),
        throwsA(isA<DioException>()),
      );
      expect(refreshHits, 1, reason: 'backoff harus menahan refresh #74');
    },
  );

  test(
    'retry setelah refresh sukses masih 401 → clear session (#74)',
    () async {
      adapter.handler = (options) {
        if (options.path.contains('/auth/refresh')) {
          return _json(200, {
            'success': true,
            'data': {
              'access_token': 'new-access',
              'refresh_token': 'new-refresh',
            },
          });
        }
        // Selalu 401: token baru pun ditolak (revoked global / clock skew).
        return _json(401, {'success': false});
      };

      await expectLater(
        () => dio.get('/api/v1/words/w1'),
        throwsA(isA<DioException>()),
      );

      expect(
        await storage.getAccessToken(),
        isNull,
        reason: 'token baru ditolak → sesi mati (#74)',
      );
      expect(await storage.getRefreshToken(), isNull);
      expect(await storage.getIsAuth(), isFalse);
    },
  );

  group('tamu tanpa token', () {    setUp(() async {
      await storage.clearTokens();
    });

    for (final path in const [
      '/api/v1/contributions/words',
      '/api/v1/contributions/words/batch',
    ]) {
      test('POST $path tetap ditembak ke server (submit anonim)', () async {
        var hits = 0;
        adapter.handler = (options) {
          hits++;
          expect(options.headers.containsKey('Authorization'), isFalse);
          return _json(201, {
            'success': true,
            'data': {'word_id': 'w1', 'status': 'pending_review'},
          });
        };

        final res = await dio.post<Object?>(path, data: <String, Object?>{});

        expect(res.statusCode, 201);
        expect(hits, 1);
      });
    }

    for (final path in const [
      '/api/v1/contributions/my',
      '/api/v1/contributions/duplicate-confirm',
    ]) {
      test('$path tetap ditolak lokal (login-only, #127)', () async {
        adapter.handler = (_) => fail('tidak boleh sampai server');

        await expectLater(
          () => dio.post<Object?>(path),
          throwsA(
            isA<DioException>().having(
              (e) => e.response?.statusCode,
              'status',
              401,
            ),
          ),
        );
      });
    }
  });

  test('token kosong/whitespace tidak mengirim header Bearer kosong', () async {
    // `bearer` tulis '' atau '   ' ke secure storage (bukan null). Tanpa
    // guard, interceptor mengirim `Bearer ` dan server menjawab
    // "Token tidak valid atau kadaluarsa" - menyesatkan.
    for (final raw in const ['', '   ']) {
      await storage.clearTokens();
      await storage.rawWriteAccessTokenForTest(raw);
      var hits = 0;
      adapter.handler = (options) {
        hits++;
        expect(options.headers.containsKey('Authorization'), isFalse);
        return _json(401, <String, Object?>{
          'success': false,
          'error_code': 'UNAUTHORIZED',
          'message': 'Token tidak disertakan',
        });
      };
      final res = await dio.get<Object?>(
        '/api/v1/words',
        options: Options(validateStatus: (_) => true),
      );
      expect(res.statusCode, 401);
      expect(hits, 1);
    }
  });
}

ResponseBody _json(int status, Map<String, Object?> body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

typedef _AdapterHandler =
    FutureOr<ResponseBody> Function(RequestOptions options);

class _RecordingAdapter implements HttpClientAdapter {
  _AdapterHandler? handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final h = handler;
    if (h == null) {
      return _json(500, {'success': false});
    }
    return await h(options);
  }
}
