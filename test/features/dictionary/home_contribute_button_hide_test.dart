import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/features/activity/domain/entities/feed_activity_item.dart';
import 'package:sambasku_mobile/features/activity/presentation/providers/activity_feed_providers.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_of_day.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/pages/home_search_page.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/providers/word_of_day_providers.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';

void main() {
  testWidgets(
    'header collaps ngikutin jari, kolom cari dan menu ikut bersama',
    (tester) async {
      await pumpHome(tester);

      final collapsible = find.byKey(const ValueKey('header_collapse'));
      expect(collapsible, findsOneWidget);
      final fullHeight = tester.getSize(collapsible).height;
      expect(fullHeight, greaterThan(80));
      // Penanda menu yang ikut menyusut = chip di baris chips header
      // (Usul, sebaris horizontal di kanan A-Z).
      final aZ = tester.getTopLeft(find.text('A-Z'));
      final usul = tester.getTopLeft(find.text('Usul'));
      expect(usul.dy, aZ.dy);
      expect(usul.dx, greaterThan(aZ.dx));

      // 50px / jarak collaps 78 = progress 0.64 (> 0.5) → snap ke tertutup
      // saat jari lepas. Tepat 0.5 akan snap ke TERBUKA (batas tengah).
      // Feed = CustomScrollView dengan controller (yang lain shrink-wrap).
      final feedList = find
          .byWidgetPredicate(
            (w) => w is CustomScrollView && w.controller != null,
          )
          .first;
      final gesture = await tester.startGesture(tester.getCenter(feedList));
      await gesture.moveBy(const Offset(0, -50));
      await tester.pump();
      final partialHeight = tester.getSize(collapsible).height;
      expect(
        partialHeight,
        inExclusiveRange(20, fullHeight - 8),
        reason: 'blok harus menyusut parsial mengikuti jari',
      );
    expect(
      tester.getTopLeft(collapsible).dy,
      lessThan(usul.dy),
      reason: 'menu ada di dalam blok yang menyusut',
    );
    expect(
      tester.getTopLeft(collapsible).dy + partialHeight,
      lessThan(usul.dy + 8),
      reason: 'menu ikut terpotong saat blok menyusut',
    );

      await gesture.up();
      await tester.pumpAndSettle();
      expect(
        tester.getSize(collapsible).height,
        lessThan(8),
        reason: 'lepas jari di progress 0.67 harus snap ke tertutup',
      );

      final feedTop = tester.getTopLeft(feedList).dy;
      expect(
        feedTop,
        lessThan(120),
        reason: 'feed harus naik mengisi ruang yang ditinggalkan header',
      );

    final gestureUp = await tester.startGesture(tester.getCenter(feedList));
    await gestureUp.moveBy(const Offset(0, 200));
    await gestureUp.up();
    // Bukan pumpAndSettle: overscroll memicu RefreshIndicator (spinner
    // berdenyut) yang tak pernah settle di fake async.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getSize(collapsible).height, greaterThan(80));

      expect(find.text('Usul'), findsOneWidget);
      // #193: tile "Dicari warga" pindah ke chips kategori feed; menu
      // header jadi baris chips horizontal (Cari/A-Z/Usul/Diskusi/dll).
      expect(find.text('Dicari warga'), findsNothing);
      expect(find.text('Diskusi'), findsOneWidget);
      await tester.tap(find.text('Usul'), warnIfMissed: false);
      await tester.pump();
      expect(tester.takeException()?.toString(), contains('No GoRouter found'));
      await tester.pump(const Duration(milliseconds: 300));
    },
  );
}

Future<void> pumpHome(WidgetTester tester) async {
  // Feed cukup panjang supaya bisa discroll sungguhan.
  final feedItems = List.generate(12, (i) {
    return FeedActivityItem(
      id: 'a$i',
      kind: FeedActivityKind.comment,
      createdAt: '2026-10-01T10:00:00Z',
      body: 'kata "lading" sering dipakai di Sambas pada obrolan $i',
      actor: const FeedActivityActor(username: 'warga', displayName: 'Warga'),
    );
  });
  final wotd = WordOfDay(
    word: const WordDetail(
      id: 'w1',
      lemma: 'lading',
      languageId: 'mly-smb',
      wordType: 'lemma',
      status: 'published',
      isVerified: true,
      isCorrected: false,
      meanings: [WordMeaning(id: 'm1', definition: 'cicada', orderIndex: 0)],
    ),
    date: '2026-10-02',
    isNewThisWeek: false,
  );

  tester.view.physicalSize = const Size(400, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        activityFeedProvider.overrideWith2(
          (category) => _FakeFeedNotifier(category, feedItems),
        ),
        wordOfDayProvider.overrideWith((ref) async => wotd),
      ],
      child: FTheme(
        data: foruiPalettes['zinc']!.light.touch,
        child: MaterialApp(
          localizationsDelegates: [
            ...AppLocalizations.localizationsDelegates,
            ...FLocalizations.localizationsDelegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeSearchPage(),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pumpAndSettle();
}

class _FakeFeedNotifier extends ActivityFeedNotifier {
  _FakeFeedNotifier(super.category, this.items);

  final List<FeedActivityItem> items;

  @override
  ActivityFeedState build() => ActivityFeedState(items: items, hasLoaded: true);
}
