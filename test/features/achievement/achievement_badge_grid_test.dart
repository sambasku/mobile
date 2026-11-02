import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/achievement/domain/entities/achievement.dart';
import 'package:sambasku_mobile/features/achievement/presentation/widgets/achievement_badge_grid.dart';

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
}
