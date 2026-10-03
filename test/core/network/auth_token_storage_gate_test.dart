import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/network/auth_token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gerbang auth router: timeout + cache singkat. Channel yang macet tidak
/// boleh mengunci GoRouter selamanya, dan hasil timeout tidak di-cache.
class _GateStorage extends AuthTokenStorage {
  _GateStorage(this.behavior);

  final Future<bool> Function(int call) behavior;
  int reads = 0;

  @override
  Future<bool> getIsAuth() => behavior(++reads);
}

void main() {
  setUpAll(() {
    // setIsAuth menulis prefs; getIsAuth cadangan membaca secure storage.
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('channel macet -> false setelah timeout, tidak di-cache', () async {
    var hang = true;
    final storage = _GateStorage(
      (call) => hang ? Completer<bool>().future : Future.value(true),
    );

    final v = await storage
        .getIsAuthForGate(timeout: const Duration(milliseconds: 50))
        .timeout(const Duration(seconds: 1));
    expect(v, isFalse);
    expect(storage.reads, 1);

    // Timeout tidak di-cache: bacaan berikutnya tetap ke storage.
    hang = false;
    final v2 = await storage.getIsAuthForGate(
      timeout: const Duration(seconds: 1),
    );
    expect(v2, isTrue);
    expect(storage.reads, 2);
  });

  test('cache dalam TTL: satu bacaan untuk dua panggilan', () async {
    final storage = _GateStorage((_) => Future.value(true));

    expect(await storage.getIsAuthForGate(), isTrue);
    expect(await storage.getIsAuthForGate(), isTrue);
    expect(storage.reads, 1);
  });

  test('TTL habis -> baca ulang', () async {
    final storage = _GateStorage((_) => Future.value(false));

    await storage.getIsAuthForGate(ttl: Duration.zero);
    await storage.getIsAuthForGate(ttl: Duration.zero);
    expect(storage.reads, 2);
  });

  test('setIsAuth me-refresh cache (login/logout tidak stale)', () async {
    final storage = _GateStorage((_) => Future.value(false));

    expect(await storage.getIsAuthForGate(), isFalse);
    await storage.setIsAuth(true);
    expect(await storage.getIsAuthForGate(), isTrue);
    expect(storage.reads, 1);
  });
}
