import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/baleho/domain/leaderboard_models.dart';
import 'package:sambasku_mobile/features/baleho/presentation/pages/baleho_leaderboard_points_page.dart';
import 'package:sambasku_mobile/features/baleho/presentation/widgets/weekly_leaderboard_entry_tile.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

import '../../helpers/l10n_delegates.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
    localizationsDelegates: appLocalizationDelegates,
    supportedLocales: appTestSupportedLocales,
    locale: appTestLocale,
    home: FTheme(data: foruiPalettes['zinc']!.light.touch, child: child),
  );
}

void main() {
  testWidgets('halaman cara dapat poin: tabel poin + aturan adil', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const BalehoLeaderboardPointsPage()));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BalehoLeaderboardPointsPage)),
    );
    expect(find.text(l10n.balehoPointsGuideCreateTitle), findsOneWidget);
    expect(find.text(l10n.balehoPointsGuideEditTitle), findsOneWidget);
    expect(find.text(l10n.balehoPointsGuideApprovedTitle), findsOneWidget);
    expect(find.text(l10n.balehoPointsGuideVerifyTitle), findsOneWidget);
    expect(find.text('+5'), findsOneWidget);
    expect(find.text('+3'), findsOneWidget);
    expect(find.text('+2'), findsNWidgets(2));
    expect(
      find.text(l10n.balehoPointsGuideRuleRejected, skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('tile peringkat: poin pakai pemisah ribuan', (tester) async {
    const entry = LeaderboardEntry(
      rank: 4,
      username: 'budi',
      submittedPoints: 1240,
      approvedPoints: 8,
      verificationPoints: 1000,
      combined: 2248,
      isVerifier: false,
    );
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) => FTileGroup(
            children: [
              leaderboardEntryTile(
                context: context,
                entry: entry,
                l10n: AppLocalizations.of(context),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2.248 poin'), findsOneWidget);
    expect(find.textContaining('+1.240 usul'), findsOneWidget);
    expect(find.textContaining('+1.000 verif'), findsOneWidget);
  });
}
