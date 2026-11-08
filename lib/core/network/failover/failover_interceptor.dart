import 'package:dio/dio.dart';

import 'api_host_resolver.dart';
import 'api_tier.dart';
import 'cold_host_gate.dart';
import 'infra_failure.dart';

/// Penanda supaya satu request tidak diulang berkali-kali.
const kFailoverRetriedExtra = 'failoverRetried';

/// Request ini sudah memegang slot [ColdHostGate].
const kColdGatedExtra = 'coldHostGated';

/// Circuit breaker tiga tier, dipasang sebagai interceptor.
///
/// Kunci desainnya ada di `onRequest`: `RequestOptions.baseUrl` bisa ditulis dan
/// Dio baru menyusun URI final SETELAH semua interceptor jalan. Jadi satu baris
/// di sini memindahkan 13 klien Retrofit dan semua panggilan `dio.get/post`
/// mentah sekaligus - tidak ada satu pun file fitur yang perlu tahu.
class FailoverInterceptor extends Interceptor {
  FailoverInterceptor({
    required ApiHostResolver resolver,
    Dio? probeDio,
    ColdHostGate? coldGate,
  })  : _resolver = resolver,
        _coldGate = coldGate ?? ColdHostGate(),
        _probeDio = probeDio ??
            Dio(
              BaseOptions(
                connectTimeout: kHealthProbeTimeout,
                receiveTimeout: kHealthProbeTimeout,
                sendTimeout: kHealthProbeTimeout,
              ),
            ) {
    _resolver.onWarmUp = _warmUp;
    _resolver.onCancelBackgroundProbes = _cancelWarmUp;
  }

  final ApiHostResolver _resolver;
  final ColdHostGate _coldGate;

  /// Dio TANPA interceptor: dipakai untuk mengulang request dan untuk warm-up,
  /// supaya tidak masuk kembali ke breaker ini secara rekursif.
  final Dio _probeDio;
  CancelToken? _warmUpToken;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_resolver.hasFallbacks) {
      final tier = _resolver.activeTier;
      _applyTier(options, tier);
      if (_isCold(tier)) {
        await _coldGate.acquire();
        options.extra[kColdGatedExtra] = true;
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _releaseGated(response.requestOptions);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    _releaseGated(err.requestOptions);

    if (!_resolver.hasFallbacks || !isInfraFailure(err)) {
      return handler.next(err);
    }

    final options = err.requestOptions;
    if (options.extra[kFailoverRetriedExtra] == true ||
        !isReplayableMethod(options.method)) {
      // Mutasi: pin boleh maju, request tidak diulang.
      if (_sameHost(options.baseUrl, _resolver.activeHost)) {
        _resolver.advanceTier();
      }
      return handler.next(err);
    }

    // Ledakan request gagal bersamaan: hanya request yang GAGAL di host
    // aktif yang menaikkan tier. Yang lain replay ke host yang sudah baru
    // tanpa lompat 1→2→3 dalam satu wave (itu membuka banyak koneksi 75s).
    final ApiTier? target;
    if (_sameHost(options.baseUrl, _resolver.activeHost)) {
      target = _resolver.advanceTier();
    } else {
      target = _resolver.activeTier;
    }
    if (target == null || _sameHost(options.baseUrl, target.host)) {
      return handler.next(err);
    }

    _applyTier(options, target);
    options.extra[kFailoverRetriedExtra] = true;
    try {
      return handler.resolve(await _fetchReplay(options, target));
    } on DioException catch (e) {
      return handler.next(e);
    } catch (_) {
      return handler.next(err);
    }
  }

  Future<Response<dynamic>> _fetchReplay(
    RequestOptions options,
    ApiTier target,
  ) async {
    if (_isCold(target)) {
      await _coldGate.acquire();
      options.extra[kColdGatedExtra] = true;
    }
    try {
      return await _probeDio.fetch(options);
    } finally {
      _releaseGated(options);
    }
  }

  static bool _sameHost(String a, String b) {
    String norm(String s) => s.endsWith('/') ? s.substring(0, s.length - 1) : s;
    return norm(a) == norm(b);
  }

  static bool _isCold(ApiTier tier) => tier.timeout > kDefaultTierTimeout;

  void _releaseGated(RequestOptions options) {
    if (options.extra[kColdGatedExtra] != true) return;
    options.extra[kColdGatedExtra] = false;
    _coldGate.release();
  }

  static void _applyTier(RequestOptions options, ApiTier tier) {
    options.baseUrl = tier.host;
    // Connect/send JANGAN 75s: TCP hang sepanjang itu di ColorOS = ANR.
    // Receive 75s hanya untuk body setelah koneksi sudah berdiri.
    options.connectTimeout = kDefaultTierTimeout;
    options.sendTimeout = kDefaultTierTimeout;
    options.receiveTimeout = tier.timeout;
  }

  void _cancelWarmUp() {
    _warmUpToken?.cancel();
    _warmUpToken = null;
  }

  /// Bangunkan tier berikutnya di belakang layar. Sengaja tanpa await dan tanpa
  /// melempar - berguna bila ada host cold-start di belakang.
  void _warmUp(ApiTier tier) {
    _warmUpToken?.cancel();
    _warmUpToken = CancelToken();
    _probeDio
        .get<void>(
          '${tier.host}/health',
          cancelToken: _warmUpToken,
          options: Options(
            connectTimeout: kHealthProbeTimeout,
            receiveTimeout: kHealthProbeTimeout,
            sendTimeout: kHealthProbeTimeout,
            validateStatus: (_) => true,
          ),
        )
        .ignore();
  }
}
