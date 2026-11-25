import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/karya/domain/karya.dart';
import 'package:sambasku_mobile/features/karya/presentation/widgets/karya_music_stage.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

import '../../../../helpers/l10n_delegates.dart';

KaryaEntry _entry({
  required String kind,
  List<KaryaCredit> credits = const [],
  int? durationMs,
  bool musicIsCover = false,
}) {
  return KaryaEntry(
    id: '1',
    slug: 'lagu-tes',
    title: 'Lagu Tes',
    kind: kind,
    year: 2020,
    sambasConnections: const [],
    accessLinks: const [],
    credits: credits,
    excerpts: const [],
    updatedAt: DateTime.utc(2024, 1, 1),
    musicDurationMs: durationMs,
    musicReleaseType: kind == 'music' ? 'single' : null,
    musicIsCover: musicIsCover,
  );
}

Future<void> _pumpStage(
  WidgetTester tester, {
  required KaryaEntry item,
  String? listenLabel,
  VoidCallback? onListen,
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
            child: KaryaMusicStage(
              item: item,
              listenLabel: listenLabel,
              onListen: onListen,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('music stage shows artist, duration meta, and top play', (
    tester,
  ) async {
    await _pumpStage(
      tester,
      item: _entry(
        kind: 'music',
        durationMs: 125000,
        credits: const [
          KaryaCredit(role: 'vocal', nameText: 'Artis Sambas'),
        ],
      ),
      listenLabel: 'Dengarkan di Spotify',
      onListen: () {},
    );

    expect(find.text('Lagu Tes'), findsOneWidget);
    expect(find.text('Artis Sambas'), findsOneWidget);
    expect(find.textContaining('2:05'), findsOneWidget);
    expect(find.text('Dengarkan di Spotify'), findsOneWidget);
    expect(find.byIcon(FLucideIcons.play), findsOneWidget);
    expect(find.byType(FButton), findsOneWidget);
  });

  testWidgets('music stage shows empty listen copy without link', (
    tester,
  ) async {
    await _pumpStage(
      tester,
      item: _entry(kind: 'music'),
    );

    final l10n = AppLocalizations.of(
      tester.element(find.byType(KaryaMusicStage)),
    );
    expect(find.text(l10n.karyaMusicListenEmpty), findsOneWidget);
    expect(find.byIcon(FLucideIcons.play), findsNothing);
  });

  testWidgets('music stage shows cover in meta line when musicIsCover', (
    tester,
  ) async {
    await _pumpStage(
      tester,
      item: _entry(kind: 'music', musicIsCover: true),
    );

    final l10n = AppLocalizations.of(
      tester.element(find.byType(KaryaMusicStage)),
    );
    expect(find.textContaining(l10n.karyaMusicIsCoverBadge), findsOneWidget);
  });
}
