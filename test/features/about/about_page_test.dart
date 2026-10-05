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

  testWidgets('blok ringkas: Apa itu, Sponsor & Tim, GitHub', (tester) async {
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
    expect(find.text('Sponsor & Tim Kami'), findsOneWidget);
    expect(find.text('Kode Sumber & Organisasi'), findsOneWidget);
    expect(find.text('Buka di GitHub'), findsOneWidget);

    // Blok fitur lama dan blok Organisasi terpisah sudah dilebur.
    expect(find.text('Cari kosakata'), findsNothing);
    expect(find.text('Bagikan kartu'), findsNothing);
    expect(find.text('Organisasi di GitHub'), findsNothing);

    // Data sponsor/tim tidak lagi di halaman Tentang (pindah ke halaman
    // Sponsorship & Tim) - tidak boleh ada duplikasi.
    expect(find.text('Sponsor & Mitra'), findsNothing);
    expect(find.text('Pengusul'), findsNothing);

    double y(String t) => tester.getTopLeft(find.text(t)).dy;
    expect(y('Apa itu SambasKu?'), lessThan(y('Sponsor & Tim Kami')));
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
