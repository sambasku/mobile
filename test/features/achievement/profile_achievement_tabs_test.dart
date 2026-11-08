import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/achievement/domain/entities/achievement.dart';
import 'package:sambasku_mobile/features/achievement/presentation/providers/achievement_providers.dart';
import 'package:sambasku_mobile/features/achievement/presentation/widgets/profile_achievement_tabs.dart';

import '../../helpers/l10n_delegates.dart';

Achievement _badge(String title, {int level = 1}) => Achievement(
  id: 'a$level',
  code: 'c$level',
  title: title,
  description: 'deskripsi $title',
  category: 'badge',
  rewardType: 'badge',
  isActive: true,
  family: 'f$level',
  level: level,
  userAchievementId: 'u$level',
);

Future<void> _pump(
  WidgetTester tester, {
  required List<Achievement> items,
  String? username,
  bool showAllButton = true,
}) async {
  tester.view.physicalSize = const Size(390, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final overrides = username == null
      ? [myAchievementsProvider().overrideWith((ref) async => items)]
      : [userAchievementsProvider(username).overrideWith((ref) async => items)];

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: FTheme(
        data: foruiPalettes['zinc']!.light.touch,
        child: MaterialApp(
          theme: foruiPalettes['zinc']!.light.touch
              .toApproximateMaterialTheme(),
          localizationsDelegates: appLocalizationDelegates,
          supportedLocales: appTestSupportedLocales,
          locale: appTestLocale,
          home: FScaffold(
            child: SingleChildScrollView(
              child: ProfileAchievementTabs(
                username: username,
                showAllButton: showAllButton,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('satu lencana: baris rapat, tanpa deskripsi, tanpa sisa layar', (
    tester,
  ) async {
    await _pump(tester, items: [_badge('Satu', level: 1)]);
    final section = tester.getSize(find.byType(ProfileAchievementTabs));
    final tile = tester.getSize(find.byType(FTile).first);
    expect(find.text('deskripsi Satu'), findsNothing);
    expect(tile.height, lessThan(48));
    expect(section.height, lessThan(160));
  });

  testWidgets('belum ada lencana: seksi ciut', (tester) async {
    await _pump(tester, items: const []);
    expect(find.text('Lencana'), findsNothing);
    expect(find.text('Belum ada lencana.'), findsNothing);
    expect(find.byType(FTileGroup), findsNothing);
    expect(tester.getSize(find.byType(ProfileAchievementTabs)).height, 0);
  });

  testWidgets('lebih dari 3: hanya 3 baris plus lihat lainnya', (tester) async {
    await _pump(
      tester,
      items: [
        _badge('Satu', level: 1),
        _badge('Dua', level: 2),
        _badge('Tiga', level: 3),
        _badge('Empat', level: 4),
        _badge('Lima', level: 5),
      ],
    );

    expect(find.text('Satu'), findsOneWidget);
    expect(find.text('Dua'), findsOneWidget);
    expect(find.text('Tiga'), findsOneWidget);
    expect(find.text('Empat'), findsNothing);
    expect(find.text('Lima'), findsNothing);
    expect(find.text('Lihat lainnya'), findsOneWidget);
    expect(find.text('Lihat semua pencapaian'), findsNothing);
    expect(find.byType(FTileGroup), findsOneWidget);
  });

  testWidgets('1 sampai 3 lencana: tombol lihat semua, tanpa lihat lainnya', (
    tester,
  ) async {
    await _pump(
      tester,
      items: [_badge('Satu', level: 1), _badge('Dua', level: 2)],
    );

    expect(find.text('Satu'), findsOneWidget);
    expect(find.text('Dua'), findsOneWidget);
    expect(find.text('Lihat lainnya'), findsNothing);
    expect(find.text('Lihat semua pencapaian'), findsOneWidget);
  });

  testWidgets('profil publik: lihat lainnya membuka daftar lengkap', (
    tester,
  ) async {
    await _pump(
      tester,
      username: 'ani',
      showAllButton: false,
      items: [
        _badge('Satu', level: 1),
        _badge('Dua', level: 2),
        _badge('Tiga', level: 3),
        _badge('Empat', level: 4),
      ],
    );

    expect(find.text('Empat'), findsNothing);
    await tester.tap(find.text('Lihat lainnya'));
    await tester.pumpAndSettle();

    expect(find.text('Empat'), findsOneWidget);
    expect(find.text('Lihat semua pencapaian'), findsNothing);
  });
}
