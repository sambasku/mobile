import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/karya/domain/karya.dart';
import 'package:sambasku_mobile/features/karya/presentation/widgets/karya_film_stage.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

import '../../../../helpers/l10n_delegates.dart';

KaryaEntry _film({
  List<KaryaCredit> credits = const [],
  int? runtimeMin,
  String? filmType,
}) {
  return KaryaEntry(
    id: '1',
    slug: 'film-tes',
    title: 'Film Tes Panjang Sekali Judulnya',
    kind: 'film',
    year: 2021,
    sambasConnections: const [],
    accessLinks: const [],
    credits: credits,
    excerpts: const [],
    updatedAt: DateTime.utc(2024, 1, 1),
    filmRuntimeMin: runtimeMin,
    filmType: filmType,
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required KaryaEntry item,
  String? watchLabel,
  VoidCallback? onWatch,
  String? trailerLabel,
  VoidCallback? onTrailer,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
      localizationsDelegates: appLocalizationDelegates,
      supportedLocales: appTestSupportedLocales,
      locale: appTestLocale,
      home: FTheme(
        data: foruiPalettes['zinc']!.light.touch,
        child: Scaffold(
          body: SingleChildScrollView(
            child: KaryaFilmStage(
              item: item,
              watchLabel: watchLabel,
              onWatch: onWatch,
              trailerLabel: trailerLabel,
              onTrailer: onTrailer,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('film stage shows director, runtime meta, and watch button', (
    tester,
  ) async {
    await _pump(
      tester,
      item: _film(
        runtimeMin: 95,
        filmType: 'feature',
        credits: const [
          KaryaCredit(role: 'director', nameText: 'Sutradara Sambas'),
        ],
      ),
      watchLabel: 'Tonton di YouTube',
      onWatch: () {},
    );

    expect(find.text('Film Tes Panjang Sekali Judulnya'), findsOneWidget);
    expect(find.text('Sutradara Sambas'), findsOneWidget);
    expect(find.textContaining('95 mnt'), findsOneWidget);
    expect(find.text('Tonton di YouTube'), findsOneWidget);
    expect(find.byIcon(FLucideIcons.play), findsOneWidget);
    expect(find.byType(FButton), findsOneWidget);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(KaryaFilmStage)),
    );
    expect(find.textContaining(l10n.karyaFilmTypeFeature), findsOneWidget);
  });

  testWidgets('film stage shows empty watch copy without link', (tester) async {
    await _pump(tester, item: _film());

    final l10n = AppLocalizations.of(
      tester.element(find.byType(KaryaFilmStage)),
    );
    expect(find.text(l10n.karyaFilmWatchEmpty), findsOneWidget);
    expect(find.byIcon(FLucideIcons.play), findsNothing);
  });

  testWidgets('film stage shows trailer beside watch', (tester) async {
    await _pump(
      tester,
      item: _film(),
      watchLabel: 'Tonton',
      onWatch: () {},
      trailerLabel: 'Trailer',
      onTrailer: () {},
    );

    expect(find.text('Tonton'), findsOneWidget);
    expect(find.text('Trailer'), findsOneWidget);
    expect(find.byIcon(FLucideIcons.play), findsOneWidget);
    expect(find.byType(FButton), findsNWidgets(2));
  });
}
