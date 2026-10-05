import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sambasku_mobile/core/theme/font_scale_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('preload: default 1.0 saat belum ada nilai', () async {
    SharedPreferences.setMockInitialValues({});
    await FontScaleController.preload();
    expect(FontScaleController.initial, 1.0);
  });

  test('set: nilai valid persist + state berubah', () async {
    SharedPreferences.setMockInitialValues({});
    FontScaleController.initial = 1.0;
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(fontScaleControllerProvider.notifier).set(1.3);
    expect(container.read(fontScaleControllerProvider), 1.3);
    expect(FontScaleController.initial, 1.3);

    // Nilai tersimpan di prefs mock bisa dibaca ulang via preload.
    await FontScaleController.preload();
    expect(FontScaleController.initial, 1.3);
  });

  test('set: nilai di luar allowed diabaikan', () async {
    SharedPreferences.setMockInitialValues({});
    FontScaleController.initial = 1.0;
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(fontScaleControllerProvider.notifier).set(2.5);
    expect(container.read(fontScaleControllerProvider), 1.0);
  });
}
