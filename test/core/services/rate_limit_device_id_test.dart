import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/services/rate_limit_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// X-Device-Id harus di secure storage (Keystore/Keystore), bukan
/// SharedPreferences plaintext (#72).
void main() {
  const key = 'sambasku_x_device_id';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('id disimpan di flutter_secure_storage, bukan prefs', () async {
    final service = RateLimitDeviceIdService();
    final id = await service.getId();

    expect(id.length, inInclusiveRange(8, 64));
    final stored = await const FlutterSecureStorage().read(key: key);
    expect(stored, id, reason: 'id harus hidup di secure storage');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(key), isNull, reason: 'jangan di prefs (#72)');
  });

  test('id stable: panggilan berikutnya pakai nilai yang sama', () async {
    final service = RateLimitDeviceIdService();
    final first = await service.getId();
    final second = await RateLimitDeviceIdService().getId();
    expect(second, first);
  });

  test('nilai korup (terlalu pendek) → regenerate', () async {
    final storage = const FlutterSecureStorage();
    await storage.write(key: key, value: 'abc');
    final service = RateLimitDeviceIdService();
    final id = await service.getId();
    expect(id, isNot('abc'));
    expect(id.length, inInclusiveRange(8, 64));
  });
}
