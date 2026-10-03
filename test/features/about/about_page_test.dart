import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/features/about/presentation/pages/about_page.dart';
import 'package:sambasku_mobile/flavors.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(
        theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
        localizationsDelegates: FLocalizations.localizationsDelegates,
        supportedLocales: FLocalizations.supportedLocales,
        home: FTheme(data: FThemes.zinc.light.touch, child: child),
      ),
    );

void main() {
  setUpAll(() => F.appFlavor = Flavor.production);

  testWidgets('menampilkan fitur tanpa seksi pengembang', (tester) async {
    // Logo + blok fitur lebih tinggi dari viewport default 800×600;
    // ListView tidak membangun blok di bawah fold.
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(const AboutPage()));
    await tester.pump();
    await tester.pump();

    expect(find.text('Pengembang'), findsNothing);
    expect(find.text('Ibnul Mutaki'), findsNothing);
    expect(find.text('Tentang'), findsWidgets);
    expect(find.text('Apa itu SambasKu?'), findsOneWidget);
    expect(find.text('Cari kosakata'), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);

    // Data sponsor/tim tidak lagi di halaman Tentang (pindah ke halaman
    // Sponsorship & Tim) - tidak boleh ada duplikasi.
    expect(find.text('Sponsor & Mitra'), findsNothing);
    expect(find.text('Pengusul'), findsNothing);

    // Blok baru Sponsor & Tim Kami tersedia sebagai pintasan.
    expect(find.text('Sponsor & Tim Kami'), findsOneWidget);

    final aboutList = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('Usulkan'),
      200,
      scrollable: aboutList.first,
    );
    expect(find.text('Usulkan'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Bagikan kartu'),
      200,
      scrollable: aboutList.first,
    );
    expect(find.text('Bagikan kartu'), findsOneWidget);
  });

  testWidgets('halaman Sponsorship & Tim punya dua tab', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(const SponsorshipTeamPage()));
    await tester.pump();
    await tester.pump();

    expect(find.text('Sponsor & Mitra'), findsWidgets);
    expect(find.text('Tim Kami'), findsOneWidget);

    await tester.tap(find.text('Tim Kami'));
    await tester.pumpAndSettle();

    expect(find.text('Bersama warga Sambas'), findsOneWidget);
    expect(find.text('Kontributor'), findsOneWidget);
    expect(find.text('Verifikator'), findsOneWidget);
    expect(find.text('Kontributor pelafalan'), findsNothing);
  });
}
