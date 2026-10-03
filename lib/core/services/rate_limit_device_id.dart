import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// ULID-like opaque id untuk header X-Device-Id .
/// Bukan FCM UDID (`DeviceIdService`) - jangan digabung.
class RateLimitDeviceIdService {
  RateLimitDeviceIdService({SharedPreferences? prefs}) : _prefs = prefs;

  final SharedPreferences? _prefs;
  SharedPreferences? _resolvedPrefs;

  static const _key = 'sambasku_x_device_id';
  static const _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

  Future<SharedPreferences> get _sharedPrefs async =>
      _prefs ?? (_resolvedPrefs ??= await SharedPreferences.getInstance());

  Future<String> getId() async {
    final prefs = await _sharedPrefs;
    final existing = prefs.getString(_key);
    if (existing != null && existing.length >= 8 && existing.length <= 64) {
      return existing;
    }
    final id = _newId();
    await prefs.setString(_key, id);
    return id;
  }

  String _newId() {
    final rand = Random.secure();
    return List.generate(26, (_) => _alphabet[rand.nextInt(_alphabet.length)]).join();
  }
}
