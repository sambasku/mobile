import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/contribution/presentation/widgets/kbbi_translation_field.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

void main() {
  testWidgets('terjemahan panjang membungkus, ikon buku tetap di kanan atas', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = TextEditingController(
      text:
          'hampan yang digunakan saat memasak sayur di dapur bersama keluarga besar',
    );
    addTearDown(controller.dispose);
    var opened = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          ...FLocalizations.localizationsDelegates,
        ],
        supportedLocales: const [Locale('id')],
        locale: const Locale('id'),
        builder: (context, child) =>
            FTheme(data: foruiPalettes['zinc']!.light.touch, child: child!),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: KbbiTranslationField(
              controller: controller,
              label: const Text('Terjemahan'),
              onOpenKbbi: () => opened++,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final box = tester.getRect(find.byType(TextField));
    final icon = tester.getRect(find.byIcon(FLucideIcons.bookOpen));

    expect(box.height, greaterThan(icon.height * 1.4));
    expect(icon.top - box.top, lessThanOrEqualTo(16));
    expect(box.right - icon.right, lessThanOrEqualTo(16));
    expect(icon.center.dy, lessThan(box.top + box.height / 2));

    await tester.tap(find.byIcon(FLucideIcons.bookOpen));
    await tester.pump(const Duration(milliseconds: 200));
    expect(opened, 1);
  });

  testWidgets('ikon buku satu baris tetap di dalam kotak', (tester) async {
    final controller = TextEditingController(text: 'makan');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          ...FLocalizations.localizationsDelegates,
        ],
        supportedLocales: const [Locale('id')],
        locale: const Locale('id'),
        builder: (context, child) =>
            FTheme(data: foruiPalettes['zinc']!.light.touch, child: child!),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: KbbiTranslationField(
              controller: controller,
              onOpenKbbi: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final box = tester.getRect(find.byType(TextField));
    final icon = tester.getRect(find.byIcon(FLucideIcons.bookOpen));
    expect(icon.top, greaterThanOrEqualTo(box.top));
    expect(icon.bottom, lessThanOrEqualTo(box.bottom));
    expect(icon.right, lessThanOrEqualTo(box.right));
  });
}
