import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/vote/presentation/pages/periksa_kata_guide_page.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

/// Simulasi panduan Periksa Kata: ambang +5 / -5 (selaras backend).
void main() {
  Future<void> pumpGuide(WidgetTester tester) async {
    // Viewport tinggi supaya seluruh ListView (termasuk tombol simulasi) ter-build.
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          ...AppLocalizations.localizationsDelegates,
          ...FLocalizations.localizationsDelegates,
        ],
        supportedLocales: const [Locale('id')],
        locale: const Locale('id'),
        home: FTheme(
          data: foruiPalettes['zinc']!.light.touch,
          child: const PeriksaKataGuidePage(),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> tapText(WidgetTester tester, String label, {int times = 1}) async {
    for (var i = 0; i < times; i++) {
      final finder = find.text(label).first;
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump();
    }
  }

  testWidgets('status awal menunggu, lalu terverifikasi setelah 5 setuju', (tester) async {
    await pumpGuide(tester);

    expect(find.textContaining('Masih menunggu'), findsOneWidget);

    await tapText(tester, '+1 Sudah pas', times: 5);
    await tester.pumpAndSettle();

    expect(find.text('Terverifikasi otomatis'), findsWidgets);
    expect(find.textContaining('Masih menunggu'), findsNothing);
  });

  testWidgets('5 perlu dicek ulang → ditolak otomatis', (tester) async {
    await pumpGuide(tester);

    await tapText(tester, '+1 Perlu dicek ulang', times: 5);
    await tester.pumpAndSettle();

    expect(find.text('Ditolak otomatis'), findsWidgets);
  });

  testWidgets('reset mengembalikan simulasi ke menunggu', (tester) async {
    await pumpGuide(tester);

    await tapText(tester, '+1 Sudah pas', times: 5);
    await tester.pumpAndSettle();
    expect(find.text('Terverifikasi otomatis'), findsWidgets);

    await tapText(tester, 'Ulangi simulasi');
    await tester.pumpAndSettle();

    expect(find.textContaining('Masih menunggu'), findsOneWidget);
  });
}
