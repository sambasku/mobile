import 'package:dio/dio.dart';

import '../auth_token_storage.dart';
import '../failover/api_host_resolver.dart';
import '../jwt_payload.dart';

/// Key di [RequestOptions.extra] untuk melewati refresh+retry pada 401.
const kSkipAuthRefreshExtra = 'skipAuthRefresh';

/// Interceptor auth (pola jnn_mobile, varian sambasku):
/// - onRequest: sisipkan Bearer access token
/// - onError 401: refresh SEKALI (queue via `_refreshFuture`), lalu retry.
///   Hanya 401/403 pada refresh yang menghapus sesi. Timeout, 5xx, dan
///   gagalnya request yang diulang TIDAK logout - jaringan putus bukan
///   sesi mati.
///
/// Path yang di-skip (tidak trigger refresh):
/// - `/auth/login|google|facebook|refresh|register|verify-email|resend-otp`
///   401 di login sosial adalah token penyedia ditolak, bukan sesi kedaluwarsa.
/// - `/device/revoke` (detach FCM; 401 di sini tidak boleh memicu refresh)
/// - `/device/register` (FCM best-effort #171; 401 jangan clear sesi login baru)
/// - request dengan `extra[kSkipAuthRefreshExtra] == true`
///
/// Refresh memakai body mobile:
/// `POST /api/v1/auth/refresh` body `{ refresh_token }`
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required AuthTokenStorage tokenStorage,
    required ApiHostResolver hostResolver,
    Dio? refreshDio,
  }) : _tokenStorage = tokenStorage,
       _hostResolver = hostResolver,
       _refreshDio =
           refreshDio ??
           Dio(
             BaseOptions(
               baseUrl: hostResolver.activeHost,
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 15),
               sendTimeout: const Duration(seconds: 15),
               responseType: ResponseType.json,
               headers: {
                 'Accept': 'application/json',
                 'Content-Type': 'application/json',
               },
             ),
           );

  final AuthTokenStorage _tokenStorage;

  /// Dibaca ULANG tiap refresh. `_refreshDio` tidak punya interceptor, jadi
  /// `baseUrl`-nya tidak ikut ditulis FailoverInterceptor; kalau host aktif
  /// tidak disalin lagi di sini, pencarian pindah tier sementara refresh token
  /// tetap menembak tier 1 yang sedang mati.
  final ApiHostResolver _hostResolver;
  final Dio _refreshDio;
  Future<_RefreshResult>? _refreshFuture;
  bool _clearingSession = false;

  /// Backoff refresh (#74): setelah gagal transient (timeout/5xx), tahan
  /// refresh berikutnya sebelum jeda ini - hindari hammer endpoint refresh.
  DateTime? _transientFailedAt;
  static const _refreshBackoff = Duration(seconds: 5);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      // Token kosong/whitespace = tidak ada token. Tanpa cek ini header
      // `Bearer ` (spasi ekor) terkirim dan server membalas "Token tidak
      // valid atau kadaluarsa" alih-alih "Token tidak disertakan" -
      // menyamarkan sesi mati sebagai token rusak.
      if (token != null && token.trim().isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
        return;
      }
      // #127 pre-flight: login-only request tanpa token jangan ditembak ke
      // server - 401 "Token tidak disertakan" pasti. Gagal lokal supaya
      // UI langsung tahu sesi mati, hemat round-trip.
      if (_isAuthRequired(options)) {
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.unknown,
            error: const _MissingTokenError(),
            response: Response(
              requestOptions: options,
              statusCode: 401,
              data: {
                'error_code': 'UNAUTHORIZED',
                'message': 'Token tidak disertakan',
              },
            ),
          ),
          true,
        );
        return;
      }
    } catch (_) {
      // lanjut tanpa header auth
    }
    handler.next(options);
  }

  /// Endpoint yang 100% butuh Bearer. Path publik (login, counts, feed,
  /// dsb.) tidak masuk daftar - cek routes API: hanya endpoint ber-mount
  /// `authenticate` wajib. Daftar prefiks eksplisit supaya murah + jelas.
  static const _authRequiredPrefixes = <String>[
    '/api/v1/votes/deck',
    '/api/v1/votes/my',
    '/api/v1/votes/history',
    '/api/v1/votes',
    // JANGAN blanket '/api/v1/contributions': POST /contributions/words
    // (+ /words/batch) publik (optionalAuthenticate) - tamu boleh submit.
    '/api/v1/contributions/my',
    '/api/v1/contributions/duplicate-confirm',
    '/api/v1/bookmarks',
    '/api/v1/notifications',
    '/api/v1/users/me',
    '/api/v1/auth/logout',
    '/api/v1/device',
    '/api/v1/search-miss',
  ];

  /// Path publik yang berada di bawah prefiks login-only (pengecualian).
  static const _publicPaths = <String>{'/api/v1/votes/counts'};

  bool _isAuthRequired(RequestOptions options) {
    final path = options.path.split('?').first;
    if (_publicPaths.contains(path)) return false;
    return _authRequiredPrefixes.any(
      (p) => path == p || path.startsWith('$p/'),
    );
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 ||
        _shouldSkipAuthRefresh(err.requestOptions)) {
      return handler.next(err);
    }

    // Fingerprint token yang dipakai retry (setelah refresh sukses). Dipakai
    // agar clear setelah retry 401 tidak menghapus sesi login yang baru
    // menimpa storage di tengah jalan.
    String? retryFingerprint;

    try {
      final result = await _refreshToken();
      if (result.outcome == _RefreshOutcome.terminal) {
        await _clearSession(expectedFingerprint: result.fingerprint);
        return handler.next(err);
      }
      if (result.outcome != _RefreshOutcome.success) {
        return handler.next(err);
      }

      final options = err.requestOptions;
      final newToken = await _tokenStorage.getAccessToken();
      final refreshSnap = await _tokenStorage.getRefreshToken();
      retryFingerprint = _sessionFingerprint(newToken, refreshSnap);
      if (newToken != null) {
        options.headers['Authorization'] = 'Bearer $newToken';
      }

      // Multipart: FormData sudah `finalize()` di attempt pertama. Retry
      // dengan objek yang sama melempar StateError / body kosong (UI lihat
      // TOKEN_EXPIRED padahal refresh sukses). Clone supaya bisa dikirim
      // ulang; MultipartFile.clone() membuka stream file baru.
      final body = options.data;
      if (body is FormData && body.isFinalized) {
        options.data = body.clone();
      }

      final response = await _refreshDio.fetch(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      // Refresh sudah sukses. Gagalnya retry bukan alasan menghapus sesi -
      // KECUALI token baru pun ditolak (revoked global / clock skew):
      // sesi benar-benar mati (#74).
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) {
        await _clearSession(expectedFingerprint: retryFingerprint);
      }
      return handler.next(e);
    } catch (_) {
      return handler.next(err);
    }
  }

  bool _shouldSkipAuthRefresh(RequestOptions options) {
    if (options.extra[kSkipAuthRefreshExtra] == true) return true;
    final path = options.path;
    return path.contains('/auth/login') ||
        path.contains('/auth/google') ||
        path.contains('/auth/facebook') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/register') ||
        path.contains('/auth/verify-email') ||
        path.contains('/auth/resend-otp') ||
        path.contains('/device/revoke') ||
        // Register FCM best-effort (#171): 401 di sini (race token belum
        // tersimpan / azp gate) tidak boleh memicu refresh apalagi clear
        // session - device service sudah catch dan coba lagi nanti.
        path.contains('/device/register');
  }

  /// Hapus sesi lokal. Tidak memanggil revoke FCM: endpoint revoke wajib
  /// Bearer valid, jadi memanggilnya di sini (access/refresh sudah mati)
  /// memicu 401 → refresh → revoke → infinite loop.
  /// Detach FCM tetap di logout eksplisit ([AuthStatusNotifier.logout]).
  ///
  /// [expectedFingerprint]: snapshot access+refresh saat refresh/retry
  /// dimulai. Bila storage sudah berbeda (login baru menang), jangan wipe.
  Future<void> _clearSession({String? expectedFingerprint}) async {
    if (_clearingSession) return;
    _clearingSession = true;
    try {
      if (expectedFingerprint != null) {
        final access = await _tokenStorage.getAccessToken();
        final refresh = await _tokenStorage.getRefreshToken();
        final current = _sessionFingerprint(access, refresh);
        if (current != expectedFingerprint) {
          // Sesi sudah diganti (login Google/dll.) - biarkan.
          return;
        }
      }
      await _tokenStorage.clearTokens();
    } finally {
      _clearingSession = false;
    }
  }

  /// Single-flight: beberapa 401 bersamaan berbagi satu panggilan refresh.
  /// Backoff (#74): bila refresh terakhir gagal transient <5 detik lalu,
  /// jangan panggil ulang - langsung anggap transient.
  Future<_RefreshResult> _refreshToken() {
    final failedAt = _transientFailedAt;
    if (failedAt != null &&
        DateTime.now().difference(failedAt) < _refreshBackoff) {
      return Future.value(const _RefreshResult(_RefreshOutcome.transient));
    }
    return _refreshFuture ??= _doRefresh().whenComplete(() {
      _refreshFuture = null;
    });
  }

  Future<_RefreshResult> _doRefresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    final accessToken = await _tokenStorage.getAccessToken();
    final fingerprint = _sessionFingerprint(accessToken, refreshToken);
    // Epoch saat refresh dimulai: login baru (saveTokens) menaikkan angka
    // ini - jangan timpa / anggap sukses jika sesi sudah diganti.
    final epochAtStart = _tokenStorage.sessionGeneration;
    if (refreshToken == null) {
      return _RefreshResult(
        _RefreshOutcome.terminal,
        fingerprint: fingerprint,
      );
    }

    try {
      final tier = _hostResolver.activeTier;
      _refreshDio.options.baseUrl = tier.host;
      // Refresh tidak boleh menunggu cold start 75s - session recovery
      // yang menggantung main isolate terasa sebagai ANR.
      _refreshDio.options.connectTimeout = kDefaultTierTimeout;
      _refreshDio.options.receiveTimeout = kDefaultTierTimeout;
      _refreshDio.options.sendTimeout = kDefaultTierTimeout;
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/api/v1/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final raw = response.data;
      if (raw == null || raw['success'] != true) {
        return const _RefreshResult(_RefreshOutcome.transient);
      }

      final data = raw['data'];
      if (data is! Map) {
        return const _RefreshResult(_RefreshOutcome.transient);
      }

      final newAccess = data['access_token'] as String?;
      final rotatedRefresh = data['refresh_token'] as String?;
      if (newAccess == null || newAccess.isEmpty) {
        return const _RefreshResult(_RefreshOutcome.transient);
      }

      // Race B: login Google menimpa token saat refresh masih in-flight.
      // Jangan write hasil refresh usang ke atas sesi baru.
      if (await _isRefreshStale(
        epochAtStart: epochAtStart,
        refreshTokenUsed: refreshToken,
      )) {
        return const _RefreshResult(_RefreshOutcome.transient);
      }

      // Rotasi wajib di backend mobile; fallback ke token lama hanya
      // jika body tidak mengirimkan (mis. bug server).
      await _tokenStorage.saveTokens(
        accessToken: newAccess,
        refreshToken: (rotatedRefresh != null && rotatedRefresh.isNotEmpty)
            ? rotatedRefresh
            : refreshToken,
      );
      // JWT refresh memuat username terkini dari DB - sync prefs agar
      // navigasi profil tidak memakai handle lama pra-migrate.
      await _syncUsernameFromAccessToken(newAccess);
      return const _RefreshResult(_RefreshOutcome.success);
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) {
        return _RefreshResult(
          _RefreshOutcome.terminal,
          fingerprint: fingerprint,
        );
      }
      _transientFailedAt = DateTime.now();
      return const _RefreshResult(_RefreshOutcome.transient);
    } catch (_) {
      _transientFailedAt = DateTime.now();
      return const _RefreshResult(_RefreshOutcome.transient);
    }
  }

  /// true bila sesi diganti sejak refresh dimulai (login baru / clear).
  Future<bool> _isRefreshStale({
    required int epochAtStart,
    required String refreshTokenUsed,
  }) async {
    if (_tokenStorage.sessionGeneration != epochAtStart) return true;
    final currentRefresh = await _tokenStorage.getRefreshToken();
    return currentRefresh != refreshTokenUsed;
  }

  /// Snapshot access+refresh untuk bandingkan sebelum clear session.
  static String _sessionFingerprint(String? access, String? refresh) =>
      '${access ?? ''}\u0000${refresh ?? ''}';

  Future<void> _syncUsernameFromAccessToken(String accessToken) async {
    final username = usernameFromAccessToken(accessToken);
    if (username == null) return;
    final user = await _tokenStorage.getSessionUser();
    if (user.username == username) return;
    await _tokenStorage.saveSessionUser(
      username: username,
      displayName: user.displayName,
      role: user.role,
      userId: user.userId,
      avatarUrl: user.avatarUrl,
    );
  }
}

enum _RefreshOutcome { success, terminal, transient }

/// Hasil refresh + fingerprint token saat refresh dimulai (untuk clear aman).
class _RefreshResult {
  const _RefreshResult(this.outcome, {this.fingerprint});

  final _RefreshOutcome outcome;

  /// Diisi saat outcome terminal: akses+refresh sebelum panggilan refresh.
  /// `_clearSession` menolak wipe jika storage sudah beda.
  final String? fingerprint;
}

/// Marker error pre-flight #127: token absen sebelum request jalan.
class _MissingTokenError implements Exception {
  const _MissingTokenError();
  @override
  String toString() => 'Token tidak disertakan (pre-flight)';
}
