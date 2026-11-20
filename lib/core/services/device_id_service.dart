import 'dart:async';
import 'dart:math';

import 'package:flutter_udid/flutter_udid.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Identitas perangkat stabil untuk register FCM (pola jnn_mobile).
/// Berbeda dari X-Device-Id ULID rate-limit - jangan digabung.
class DeviceIdService {
  DeviceIdService({this._prefs});

  final SharedPreferences? _prefs;
  SharedPreferences? _resolvedPrefs;

  static const _deviceIdKey = 'sambasku_fcm_udid';

  Future<SharedPreferences> get _sharedPrefs async =>
      _prefs ?? (_resolvedPrefs ??= await SharedPreferences.getInstance());

  Future<String> getDeviceId() async {
    final prefs = await _sharedPrefs;
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final deviceId = await _resolveDeviceId();
    await prefs.setString(_deviceIdKey, deviceId);
    return deviceId;
  }

  Future<String> _resolveDeviceId() async {
    try {
      final udid = await FlutterUdid.udid;
      if (udid.isNotEmpty) return udid;
    } catch (_) {}

    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
