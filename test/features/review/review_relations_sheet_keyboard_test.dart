import 'package:sambasku_mobile/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/review/presentation/widgets/review_word_extras_sheets.dart';

/// Regression #156: dengan keyboard terbuka, kolom cari sinonim tertutup
/// keyboard. Dimensi mengikuti screenshot issue: 1080x2372 px @ dpr 2.75,
/// keyboard Android ~800 px fisik (= 290 logis).
void main() {
  const dpr = 2.75;
  const physical = Size(1080, 2372);
  const keyboardLogical = 290.0; // ~800 px fisik
  final logicalH = physical.height / dpr;
  final topOfKeyboard = logicalH - keyboardLogical;

  testWidgets('keyboard terbuka: kolom cari & tombol Selesai di atas keyboard',
      (tester) async {
    tester.view.devicePixelRatio = dpr;
    tester.view.physicalSize = physical;
    // FakeViewPadding dalam piksel fisik → kali dpr supaya 290 logis.
    tester.view.viewInsets =
        FakeViewPadding(bottom: keyboardLogical * dpr);
    addTearDown(tester.view.reset);

    // Font test (Ahem) lebih lebar dari font asli → FButton overflow di
    // harness saja. Abaikan hanya error overflow; sisanya tetap gagal.
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      original?.call(details);
    };
    addTearDown(() => FlutterError.onError = original);

    await tester.pumpWidget(
      ProviderScope(
        child: FTheme(
          data: foruiPalettes['zinc']!.light.touch,
          child: MaterialApp(
            localizationsDelegates: const [
              ...AppLocalizations.localizationsDelegates,
              ...FLocalizations.localizationsDelegates,
            ],
            supportedLocales: const [Locale('id')],
            locale: const Locale('id'),
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: FButton(
                    onPress: () => showReviewRelationsSheet(
                      context,
                      initial: const [],
                      excludeWordId: 'EXCLUDED',
                      onChanged: (_) {},
                    ),
                    child: const Text('buka'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();

    expect(find.text('Sinonim & antonim'), findsOneWidget);

    final search = tester.getRect(find.byType(FTextField));
    final done = tester.getRect(find.text('Selesai'));
    expect(
      search.bottom,
      lessThanOrEqualTo(topOfKeyboard),
      reason: 'kolom cari (bottom=${search.bottom}) harus seluruhnya '
          'di atas keyboard ($topOfKeyboard)',
    );
    expect(done.top, lessThan(topOfKeyboard));
  });

  testWidgets('landscape / layar pendek: kolom cari & tombol Selesai tetap di atas keyboard',
      (tester) async {
    // Mode landscape: lebar 800, tinggi 400, keyboard 200dp
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 400);
    tester.view.viewInsets = const FakeViewPadding(bottom: 200.0);
    addTearDown(tester.view.reset);

    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      original?.call(details);
    };
    addTearDown(() => FlutterError.onError = original);

    await tester.pumpWidget(
      ProviderScope(
        child: FTheme(
          data: foruiPalettes['zinc']!.light.touch,
          child: MaterialApp(
            localizationsDelegates: const [
              ...AppLocalizations.localizationsDelegates,
              ...FLocalizations.localizationsDelegates,
            ],
            supportedLocales: const [Locale('id')],
            locale: const Locale('id'),
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: FButton(
                    onPress: () => showReviewRelationsSheet(
                      context,
                      initial: const [],
                      excludeWordId: 'EXCLUDED',
                      onChanged: (_) {},
                    ),
                    child: const Text('buka'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();

    // Layar pendek: konten scrollable, kolom cari harus bisa digulir ke area
    // yang terlihat (di atas keyboard).
    await tester.ensureVisible(find.byType(FTextField));
    await tester.pumpAndSettle();
    final search = tester.getRect(find.byType(FTextField));
    final done = tester.getRect(find.text('Selesai'));
    expect(
      search.bottom,
      lessThanOrEqualTo(200.0), // topOfKeyboard = 400 - 200 = 200
      reason: 'kolom cari harus di atas keyboard di landscape',
    );
    expect(done.top, lessThan(200.0));
  });
}
