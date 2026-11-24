import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/features/about/presentation/pages/about_page.dart';
import 'package:sambasku_mobile/flavors.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
    localizationsDelegates: [
      ...AppLocalizations.localizationsDelegates,
      ...FLocalizations.localizationsDelegates,
    ],
    supportedLocales: const [Locale('id')],
    locale: const Locale('id'),
    home: FTheme(data: foruiPalettes['zinc']!.light.touch, child: child),
  ),
);

void main() {
  setUpAll(() => F.appFlavor = Flavor.production);

  testWidgets('blok ringkas: Apa itu + GitHub (Sponsor di halaman lain)', (
    tester,
  ) async {
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
    expect(
      find.text('Platform digital bahasa dan budaya Sambas'),
      findsOneWidget,
    );
    expect(find.text('Apa itu SambasKu?'), findsOneWidget);
    expect(find.textContaining('belajar bahasa dan budaya Sambas'), findsOneWidget);
    expect(find.text('Sponsor & Tim Kami'), findsNothing);
    expect(find.text('Kode Sumber & Organisasi'), findsOneWidget);
    expect(find.text('Buka di GitHub'), findsOneWidget);
    expect(find.text('Pustaka sumber terbuka'), findsOneWidget);
    expect(find.text('Lihat daftar pustaka'), findsOneWidget);

    // Blok fitur lama dan blok Organisasi terpisah sudah dilebur.
    expect(find.text('Cari kosakata'), findsNothing);
    expect(find.text('Bagikan kartu'), findsNothing);
    expect(find.text('Organisasi di GitHub'), findsNothing);

    // Data sponsor/tim tidak di halaman Tentang (pindah ke Sponsorship & Tim).
    expect(find.text('Sponsor & Mitra'), findsNothing);
    expect(find.text('Pengusul'), findsNothing);

    double y(String t) => tester.getTopLeft(find.text(t)).dy;
    expect(y('Apa itu SambasKu?'), lessThan(y('Kode Sumber & Organisasi')));
    expect(
      y('Kode Sumber & Organisasi'),
      lessThan(y('Pustaka sumber terbuka')),
    );
  });

  testWidgets('halaman Tim Kami punya chip Tim/Verifikator/Kontributor', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _wrap(const SponsorshipTeamPage(showTeam: true)),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Tim Kami'), findsWidgets);
    expect(find.text('Tim'), findsOneWidget);
    expect(find.text('Verifikator'), findsOneWidget);
    expect(find.text('Kontributor'), findsOneWidget);
    expect(
      find.textContaining('Anggota yang merawat SambasKu'),
      findsOneWidget,
    );

    await tester.tap(find.text('Kontributor'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Mengusulkan kata, perbaikan, dan rekaman'),
      findsOneWidget,
    );
  });
}
