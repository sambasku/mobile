import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/achievement/domain/entities/achievement.dart';
import 'package:sambasku_mobile/features/achievement/presentation/widgets/achievement_badge_grid.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

import '../../helpers/l10n_delegates.dart';

Achievement _badge(String title, {int level = 1}) => Achievement(
  id: 'a$level',
  code: 'c$level',
  title: title,
  description: 'deskripsi',
  category: 'badge',
  rewardType: 'badge',
  isActive: true,
  family: 'f$level',
  level: level,
  userAchievementId: 'u$level',
);

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    FTheme(
      data: foruiPalettes['zinc']!.light.touch,
      child: FScaffold(
        child: ListView(
          children: [
            AchievementBadgeGrid(
              items: [
                _badge('Satu'),
                _badge('Dua'),
                _badge('Penjelajah Kosakata Nusantara'),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  // Inti keluhan "gap lencana ke judul terasa renggang": dulu sel dipaksa
  // childAspectRatio 0.72 + Expanded, sisa tinggi diserap BoxFit.contain jadi
  // celah ~16-20pt. Sekarang jarak = Gap(4) saja.
  testWidgets('jarak lencana ke judul = Gap(4)', (tester) async {
    await _pump(tester);

    final icon = tester.getRect(find.byIcon(FLucideIcons.award).first);
    final label = tester.getRect(find.text('Satu'));
    expect(label.top - icon.bottom, moreOrLessEquals(4, epsilon: 0.1));
  });

  testWidgets('sel tanpa judul 2 baris tetap setinggi tetangganya', (
    tester,
  ) async {
    await _pump(tester);

    final short = tester.getRect(find.text('Satu'));
    final long = tester.getRect(find.text('Penjelajah Kosakata Nusantara'));
    expect(short.height, moreOrLessEquals(long.height, epsilon: 0.1));
  });

  testWidgets('sel menerima tap', (tester) async {
    Achievement? tapped;
    await tester.pumpWidget(
      FTheme(
        data: foruiPalettes['zinc']!.light.touch,
        child: FScaffold(
          child: AchievementBadgeGrid(
            items: [_badge('Satu')],
            onItemTap: (item) => tapped = item,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Satu'));
    expect(tapped?.title, 'Satu');
  });

  testWidgets('lebih dari 4: sel ujung overlay, judul ke-5 tidak tampil', (
    tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
        localizationsDelegates: appLocalizationDelegates,
        supportedLocales: appTestSupportedLocales,
        locale: appTestLocale,
        home: FTheme(
          data: foruiPalettes['zinc']!.light.touch,
          child: FScaffold(
            child: AchievementBadgeGrid(
              items: [
                _badge('Satu', level: 1),
                _badge('Dua', level: 2),
                _badge('Tiga', level: 3),
                _badge('Empat', level: 4),
                _badge('Lima', level: 5),
              ],
              maxRows: 1,
              columns: 4,
              compact: true,
              onOverflow: () => opened = true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(AchievementBadgeGrid)),
    );
    expect(find.text(l10n.achievementSeeMore), findsOneWidget);
    expect(find.text('Lima'), findsNothing);
    expect(find.text('Satu'), findsOneWidget);

    await tester.tap(find.text(l10n.achievementSeeMore));
    expect(opened, isTrue);
  });

  testWidgets('tepat 4 lencana kecil: tanpa overlay', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
        localizationsDelegates: appLocalizationDelegates,
        supportedLocales: appTestSupportedLocales,
        locale: appTestLocale,
        home: FTheme(
          data: foruiPalettes['zinc']!.light.touch,
          child: FScaffold(
            child: AchievementBadgeGrid(
              items: [
                _badge('Satu', level: 1),
                _badge('Dua', level: 2),
                _badge('Tiga', level: 3),
                _badge('Empat', level: 4),
              ],
              maxRows: 1,
              columns: 4,
              compact: true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(AchievementBadgeGrid)),
    );
    expect(find.text(l10n.achievementSeeMore), findsNothing);
    expect(find.text('Empat'), findsOneWidget);

    final satu = tester.getRect(find.text('Satu'));
    final empat = tester.getRect(find.text('Empat'));
    expect(satu.top, moreOrLessEquals(empat.top, epsilon: 0.1));
  });
}
