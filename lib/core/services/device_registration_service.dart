import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../features/device/domain/repositories/device_repository.dart';
import '../network/auth_token_storage.dart';
import 'device_id_service.dart';

/// Sync FCM token ke backend saat login / token refresh (pola jnn_mobile).
class DeviceRegistrationService {
  DeviceRegistrationService({
    required DeviceRepository repository,
    required AuthTokenStorage tokenStorage,
    required DeviceIdService deviceIdService,
    required String initialFcmToken,
  }) : _repository = repository,
       _tokenStorage = tokenStorage,
       _deviceIdService = deviceIdService,
       _lastFcmToken = initialFcmToken;

  final DeviceRepository _repository;
  final AuthTokenStorage _tokenStorage;
  final DeviceIdService _deviceIdService;
  /// Lazy: di web preview (tanpa Firebase.initializeApp) akses getter ini
  /// tidak dieksekusi di konstruktor — [FirebaseMessaging.instance] throw
  /// kalau Firebase belum di-init.
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  String _lastFcmToken;
  bool _revoking = false;
  StreamSubscription<bool>? _authSub;
  StreamSubscription<String>? _fcmSub;

  Future<void> start() async {
    final isAuth = await _tokenStorage.getIsAuth();
    if (isAuth) {
      await _register();
    }

    _authSub = _tokenStorage.authStateChanges.listen((isAuth) {
      if (isAuth) {
        _revoking = false;
        _register();
      }
    });

    _fcmSub = _messaging.onTokenRefresh.listen((newToken) {
      _lastFcmToken = newToken;
      _registerIfAuth();
    });
  }

  /// Panggil sebelum clearTokens saat logout / session mati.
  Future<void> revokeBestEffort() async {
    _revoking = true;
    try {
      try {
        await _messaging.unsubscribeFromTopic('sambasku_campaigns');
      } catch (e) {
        debugPrint('FCM topic unsubscribe failed: $e');
      }
      final udid = await _deviceIdService.getDeviceId();
      await _repository.revokeDevice(udid: udid);
    } catch (e) {
      debugPrint('device revoke failed: $e');
    }
  }

  /// Setelah user izinkan notifikasi (onboarding), sync token terbaru.
  Future<void> refreshFcmTokenAndRegister() async {
    await _registerIfAuth();
  }

  Future<void> _registerIfAuth() async {
    final isAuth = await _tokenStorage.getIsAuth();
    if (isAuth) await _register();
  }

  Future<void> _register() async {
    if (_revoking) return;

    // Selalu ambil token terbaru. Cold start sering kosong karena izin
    // belum diberikan; login setelah Izinkan harus fetch ulang di sini.
    final fresh = await _messaging.getToken() ?? '';
    if (fresh.isNotEmpty) {
      _lastFcmToken = fresh;
    }
    if (_lastFcmToken.isEmpty) {
      debugPrint('device register skipped: FCM token masih kosong');
      return;
    }

    final isAuth = await _tokenStorage.getIsAuth();
    if (!isAuth || _revoking) return;

    try {
      final udid = await _deviceIdService.getDeviceId();
      debugPrint(
        'device register: udid=${udid.substring(0, udid.length.clamp(0, 8))}… '
        'fcm=${_lastFcmToken.substring(0, 12)}…',
      );
      await _repository.registerDevice(
        udid: udid,
        fcmToken: _lastFcmToken,
      );
      // Topic broadcast campaign (semua device aktif).
      try {
        await _messaging.subscribeToTopic('sambasku_campaigns');
      } catch (e) {
        debugPrint('FCM topic subscribe failed: $e');
      }
    } catch (e) {
      debugPrint('device register failed: $e');
    }
  }

  void dispose() {
    _authSub?.cancel();
    _fcmSub?.cancel();
  }
}
