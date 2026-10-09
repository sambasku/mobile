import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/network/failover/api_host_resolver.dart';
import 'package:sambasku_mobile/core/network/failover/api_tier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ApiHostResolver resolver;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    resolver = ApiHostResolver.instance;
    resolver.onWarmUp = null;
    resolver.pinDuration = kTierPinDuration;
    await resolver.setForcedTier(null);
    resolver.configure(
      primaryHost: 'https://t1.test',
      fallbackHosts: const ['https://t2.test', 'https://t3.test'],
    );
  });

  test('mulai di tier 1 tanpa pin', () {
    expect(resolver.activeHost, 'https://t1.test');
    expect(resolver.isOnPrimary, isTrue);
    expect(resolver.pinRemaining, isNull);
  });

  test('tier terakhir memakai timeout cold start, sisanya default', () {
    expect(resolver.tiers[0].timeout, kDefaultTierTimeout);
    expect(resolver.tiers[1].timeout, kDefaultTierTimeout);
    expect(resolver.tiers[2].timeout, kColdStartTierTimeout);
  });

  test('naik SATU tier per kegagalan, tidak langsung ke tier terakhir', () {
    expect(resolver.advanceTier()?.host, 'https://t2.test');
    expect(resolver.activeHost, 'https://t2.test');

    expect(resolver.advanceTier()?.host, 'https://t3.test');
    expect(resolver.activeHost, 'https://t3.test');
  });

  test('tier terakhir terminal - advanceTier null, tidak ada host keempat', () {
    resolver.advanceTier();
    resolver.advanceTier();
    expect(resolver.advanceTier(), isNull);
    expect(resolver.activeHost, 'https://t3.test');
  });

  test('pin habis → kembali ke tier 1, BUKAN ke tier antara', () async {
    resolver.pinDuration = const Duration(milliseconds: 60);
    resolver.advanceTier();
    resolver.advanceTier();
    expect(resolver.activeHost, 'https://t3.test');

    await Future<void>.delayed(const Duration(milliseconds: 120));

    // Langsung tier 1 - primer yang sudah pulih dipakai lagi seketika, tanpa
    // mampir ke tier 2 dulu.
    expect(resolver.activeHost, 'https://t1.test');
    expect(resolver.pinRemaining, isNull);
  });

  test('tombol lepas pin mengembalikan ke tier 1', () {
    resolver.advanceTier();
    expect(resolver.activeHost, 'https://t2.test');
    resolver.resetToPrimary();
    expect(resolver.activeHost, 'https://t1.test');
  });

  test('warm-up membangunkan tier SETELAH yang di-pin, sekali per pin', () {
    final warmed = <ApiTier>[];
    resolver.onWarmUp = warmed.add;

    resolver.advanceTier(); // pin tier 2 → hangatkan tier 3
    expect(warmed.map((t) => t.host), ['https://t3.test']);

    resolver.advanceTier(); // pin tier 3 → tidak ada tier 4
    expect(warmed.length, 1);
  });

  test('tanpa cadangan (staging) breaker tidak punya tujuan', () {
    resolver.configure(primaryHost: 'https://only.test', fallbackHosts: const []);
    expect(resolver.hasFallbacks, isFalse);
    expect(resolver.advanceTier(), isNull);
    expect(resolver.tiers.single.timeout, kDefaultTierTimeout);
  });

  test('saat host dipaksa, breaker tidak cascade ke tier berikutnya', () async {
    await resolver.setForcedTier(0);
    expect(resolver.advanceTier(), isNull);
    expect(resolver.activeHost, 'https://t1.test');
  });

  test('paksa tier mengabaikan pin dan tersimpan di prefs', () async {
    resolver.advanceTier();
    expect(resolver.activeHost, 'https://t2.test');

    await resolver.setForcedTier(2);
    expect(resolver.activeHost, 'https://t3.test');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('preferredApiTier'), 2);

    await resolver.setForcedTier(null);
    expect(prefs.getInt('preferredApiTier'), -1);
  });

  group('label tier untuk UI user', () {
    test('host dikenali jadi label ramah', () {
      expect(apiTierLabelForHost('https://api.sambasku.com'), 'Cloudflare');
      expect(apiTierLabelForHost('https://deno.sambasku.com'), 'Deno Deploy');
      expect(apiTierLabelForHost('https://render.sambasku.com'), 'Render');
    });

    test('host tak dikenal → hostname-nya sendiri', () {
      expect(apiTierLabelForHost('https://kirim.test'), 'kirim.test');
    });
  });

  group('preferensi host tersimpan', () {
    test('pilihan bertahan di prefs key baru', () async {
      await resolver.setForcedTier(2);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('preferredApiTier'), 2);
      await resolver.setForcedTier(null);
      expect(prefs.getInt('preferredApiTier'), -1);
    });

    test('loadSavedTier memuat pilihan tanpa syarat dev tool', () async {
      SharedPreferences.setMockInitialValues({'preferredApiTier': 1});
      await resolver.loadSavedTier();
      expect(resolver.forcedTierIndex, 1);
      expect(resolver.activeHost, 'https://t2.test');
    });

    test('nilai -1 / di luar jangkauan diabaikan', () async {
      SharedPreferences.setMockInitialValues({'preferredApiTier': -1});
      await resolver.loadSavedTier();
      expect(resolver.forcedTierIndex, isNull);

      SharedPreferences.setMockInitialValues({'preferredApiTier': 9});
      await resolver.loadSavedTier();
      expect(resolver.forcedTierIndex, isNull);
    });
  });
}
