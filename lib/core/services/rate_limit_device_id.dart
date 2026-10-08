import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ULID-like opaque id untuk header X-Device-Id.
/// Bukan FCM UDID (`DeviceIdService`) - jangan digabung.
/// Disimpan di flutter_secure_storage (Keystore/Keystore), bukan
/// SharedPreferences plaintext (#72).
class RateLimitDeviceIdService {
  RateLimitDeviceIdService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(resetOnError: true),
          );

  final FlutterSecureStorage _storage;

  static const _key = 'sambasku_x_device_id';
  static const _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

  Future<String> getId() async {
    final existing = await _readSafe();
    if (existing != null && existing.length >= 8 && existing.length <= 64) {
      return existing;
    }
    final id = _newId();
    await _storage.write(key: _key, value: id);
    return id;
  }

  /// Store terenkripsi bisa tak terbaca lagi (signing key berganti) -
  /// jangan crash di interceptor; regenerate (#72).
  Future<String?> _readSafe() async {
    try {
      return await _storage.read(key: _key);
    } catch (_) {
      return null;
    }
  }

  String _newId() {
    final rand = Random.secure();
    return List.generate(
      26,
      (_) => _alphabet[rand.nextInt(_alphabet.length)],
    ).join();
  }
}
