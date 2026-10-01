import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/tabfreeze_log.dart';

/// Penyimpanan token sesi (pola jnn_mobile): access/refresh di
/// flutter_secure_storage (Keychain/Keystore), flag isAuth di
/// shared_preferences untuk redirect router yang cepat.
class AuthTokenStorage {
  AuthTokenStorage({FlutterSecureStorage? storage, SharedPreferences? prefs})
    // resetOnError: wipe store terenkripsi yang tak terbaca lagi (mis.
    // signing key berganti) daripada gagal decrypt di tiap launch.
    : _storage =
          storage
              ?? const FlutterSecureStorage(
                aOptions: AndroidOptions(resetOnError: true),
              ),
      _resolvedPrefs = prefs;

  static AuthTokenStorage? _instance;

  static AuthTokenStorage get instance => _instance ??= AuthTokenStorage();

  final FlutterSecureStorage _storage;
  SharedPreferences? _resolvedPrefs;

  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';
  static const _isAuthKey = 'isAuth';
  static const _usernameKey = 'sessionUsername';
  static const _displayNameKey = 'sessionDisplayName';
  static const _roleKey = 'sessionRole';
  static const _userIdKey = 'sessionUserId';
  static const _avatarUrlKey = 'sessionAvatarUrl';

  final _authStateController = StreamController<bool>.broadcast();

  /// Emit saat [setIsAuth] berubah - dipakai DeviceRegistrationService.
  Stream<bool> get authStateChanges => _authStateController.stream;

  Future<SharedPreferences> get _sharedPrefs async =>
      _resolvedPrefs ??= await SharedPreferences.getInstance();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw ArgumentError(
        'accessToken dan refreshToken wajib non-empty (varian mobile)',
      );
    }
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() async {
    final value = await _storage.read(key: _accessTokenKey);
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<String?> getRefreshToken() async {
    final value = await _storage.read(key: _refreshTokenKey);
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
    final prefs = await _sharedPrefs;
    await Future.wait([
      prefs.remove(_usernameKey),
      prefs.remove(_displayNameKey),
      prefs.remove(_roleKey),
      prefs.remove(_userIdKey),
      prefs.remove(_avatarUrlKey),
    ]);
    await setIsAuth(false);
  }

  /// Simpan info user dari response login (backend tak punya endpoint
  /// "profile/me", jadi username + role + userId dipakai untuk info user
  /// di Profil dan otorisasi aksi milik sendiri di UI, mis. hapus komentar).
  Future<void> saveSessionUser({
    required String username,
    required String? role,
    String? userId,
    String? displayName,
    String? avatarUrl,
  }) async {
    final prefs = await _sharedPrefs;
    await Future.wait([
      prefs.setString(_usernameKey, username),
      if (displayName != null && displayName.isNotEmpty)
        prefs.setString(_displayNameKey, displayName)
      else
        prefs.remove(_displayNameKey),
      if (role != null && role.isNotEmpty) prefs.setString(_roleKey, role),
      if (userId != null && userId.isNotEmpty) prefs.setString(_userIdKey, userId),
      if (avatarUrl != null && avatarUrl.isNotEmpty)
        prefs.setString(_avatarUrlKey, avatarUrl)
      else
        prefs.remove(_avatarUrlKey),
    ]);
  }

  Future<
    ({
      String? username,
      String? displayName,
      String? role,
      String? userId,
      String? avatarUrl,
    })
  >
  getSessionUser() async {
    final prefs = await _sharedPrefs;
    return (
      username: prefs.getString(_usernameKey),
      displayName: prefs.getString(_displayNameKey),
      role: prefs.getString(_roleKey),
      userId: prefs.getString(_userIdKey),
      avatarUrl: prefs.getString(_avatarUrlKey),
    );
  }

  /// Flag prefs bisa stale-true saat secure store ter-wipe (reinstall,
  /// signing key berganti) - keberadaan token adalah kebenaran akhir.
  Future<bool> getIsAuth() async {
    if (!((await _sharedPrefs).getBool(_isAuthKey) ?? false)) return false;
    return await getAccessToken() != null;
  }

  DateTime? _isAuthGateCachedAt;
  bool? _isAuthGateCached;

  /// getIsAuth untuk gerbang router (redirect /profile, tab Profil):
  /// platform channel yang macet tidak boleh mengunci GoRouter selamanya.
  /// Cache singkat + timeout. Timeout = fail-closed (tamu -> /login);
  /// hasil timeout sengaja tidak di-cache.
  Future<bool> getIsAuthForGate({
    Duration ttl = const Duration(seconds: 2),
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final cached = _isAuthGateCached;
    final at = _isAuthGateCachedAt;
    if (cached != null && at != null && DateTime.now().difference(at) < ttl) {
      return cached;
    }
    tfLog('isAuth start');
    final sw = Stopwatch()..start();
    try {
      final v = await getIsAuth().timeout(timeout);
      _isAuthGateCached = v;
      _isAuthGateCachedAt = DateTime.now();
      tfLog('isAuth ok v=$v ms=${sw.elapsedMilliseconds}');
      return v;
    } on TimeoutException {
      tfLog('isAuth timeout');
      return false;
    }
  }

  Future<void> setIsAuth(bool value) async {
    await (await _sharedPrefs).setBool(_isAuthKey, value);
    // Refresh cache gate supaya login/logout tidak pernah serve stale.
    _isAuthGateCached = value;
    _isAuthGateCachedAt = DateTime.now();
    _authStateController.add(value);
  }

  void dispose() {
    _authStateController.close();
  }
}
