import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/network/failover/api_host_resolver.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regresi: pilihan host user harus selamat dari restart aplikasi. Sebelumnya
/// `main.dart` hanya memuat pilihan ini saat devToolsEnabled (debug), jadi
/// build release selalu kembali ke Otomatis.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('pilihan tersimpan dimuat ulang untuk instance baru', () async {
    SharedPreferences.setMockInitialValues({'preferredApiTier': 2});

    final resolver = ApiHostResolver.instance;
    resolver.configure(
      primaryHost: 'https://api.sambasku.com',
      fallbackHosts: const [
        'https://deno.sambasku.com',
        'https://render.sambasku.com',
      ],
    );
    await resolver.setForcedTier(null);
    expect(resolver.forcedTierIndex, isNull);

    // Simulasi boot ulang: pilihan dibaca dari prefs.
    SharedPreferences.setMockInitialValues({'preferredApiTier': 2});
    await resolver.loadSavedTier();

    expect(resolver.forcedTierIndex, 2);
    expect(resolver.activeHost, 'https://render.sambasku.com');

    await resolver.setForcedTier(null);
  });
}