import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/dev_tool/network_monitor/network_monitor_registry.dart';
import '../services/rate_limit_device_id.dart';
import 'auth_token_storage.dart';
import 'failover/api_host_resolver.dart';
import 'failover/failover_interceptor.dart';
import 'interceptors/app_version_interceptor.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/device_id_interceptor.dart';
import 'interceptors/locale_header_interceptor.dart';
import 'interceptors/network_monitor_interceptor.dart';

part 'network_providers.g.dart';

@riverpod
AuthTokenStorage authTokenStorage(Ref ref) => AuthTokenStorage.instance;

/// Klien HTTP bersama. keepAlive: sheet Google/Facebook menaruh activity
/// di background selama beberapa detik. Provider autoDispose akan menutup
/// adapter di jeda itu (`Can't establish connection after the adapter was
/// closed`) sebelum POST /auth/google sempat jalan.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final resolver = ApiHostResolver.instance;
  final dio = Dio(
    BaseOptions(
      baseUrl: resolver.activeHost,
      connectTimeout: kDefaultTierTimeout,
      receiveTimeout: kDefaultTierTimeout,
      sendTimeout: kDefaultTierTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
  // failover paling depan: `onRequest`-nya menulis baseUrl + timeout tier aktif,
  // jadi network monitor di bawahnya mencatat host yang BENAR-BENAR dipakai.
  dio.interceptors.add(FailoverInterceptor(resolver: resolver));
  // network monitor dulu supaya AuthInterceptor refresh juga terekam
  dio.interceptors.add(
    NetworkMonitorInterceptor(
      repository: NetworkMonitorRegistry.repository,
    ),
  );
  dio.interceptors.add(DeviceIdInterceptor(RateLimitDeviceIdService()));
  dio.interceptors.add(AppVersionInterceptor());
  dio.interceptors.add(LocaleHeaderInterceptor());
  dio.interceptors.add(
    AuthInterceptor(
      tokenStorage: ref.watch(authTokenStorageProvider),
      hostResolver: resolver,
    ),
  );
  ref.onDispose(() {
    // autoDispose: jangan biarkan HttpClient native hidup tanpa pemilik.
    dio.close(force: true);
  });
  return dio;
}
