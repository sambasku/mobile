import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/features/activity/domain/entities/feed_activity_item.dart';
import 'package:sambasku_mobile/features/activity/presentation/providers/activity_feed_providers.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_of_day.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/pages/home_search_page.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/providers/word_of_day_providers.dart';

void main() {
  testWidgets('header collaps ngikutin jari, snap saat lepas, balik saat naik', (
    tester,
  ) async {
    await pumpHome(tester);

    // Awal: search + tombol usul terlihat penuh.
    final collapsible = find.byKey(const ValueKey('header_collapse'));
    expect(collapsible, findsOneWidget);
    expect(tester.getSize(collapsible).height, greaterThan(80));

    // Drag turun sedikit (jari masih menempel): blok menyusut parsial,
    // proporsional dengan jarak drag - bukan biner show/hide.
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ListView)),
    );
    await gesture.moveBy(const Offset(0, -50));
    await tester.pump();
    final partialHeight = tester.getSize(collapsible).height;
    expect(
      partialHeight,
      inExclusiveRange(20, 90),
      reason: 'blok harus menyusut parsial mengikuti jari',
    );

    // Jari lepas: snap mulus ke ujung terdekat (progress 0.55 -> tertutup).
    await gesture.up();
    await tester.pumpAndSettle();
    expect(
      tester.getSize(collapsible).height,
      lessThan(8),
      reason: 'lepas jari di progress 0.5 harus snap ke tertutup',
    );

    // Blok tertutup: feed naik mengisi ruang.
    final feedTop = tester.getTopLeft(find.byType(ListView)).dy;
    expect(
      feedTop,
      lessThan(120),
      reason: 'feed harus naik mengisi ruang yang ditinggalkan header',
    );

    // Drag naik: blok balik penuh.
    final gestureUp = await tester.startGesture(
      tester.getCenter(find.byType(ListView)),
    );
    await gestureUp.moveBy(const Offset(0, 200));
    await gestureUp.up();
    await tester.pumpAndSettle();
    expect(tester.getSize(collapsible).height, greaterThan(80));

    // Tombol hidup lagi: onPress terpanggil (tap melempar FlutterError
    // "No GoRouter found" karena test tanpa GoRouter - yang dibuktikan
    // adalah gesture sampai ke onPress).
    await tester.tap(find.text('Usul kata baru'), warnIfMissed: false);
    await tester.pump();
    expect(
      tester.takeException()?.toString(),
      contains('No GoRouter found'),
    );
    // Frame animasi FButton bisa tinggalkan timer; drain sebelum dispose.
    await tester.pumpAndSettle();
    final buttonRectBack = tester.getRect(find.text('Usul kata baru'));
    expect(buttonRectBack.top, greaterThan(0));
    expect(
      buttonRectBack.bottom,
      lessThan(200),
      reason: 'tombol balik ke posisi header atas',
    );
  });
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
        activityFeedProvider.overrideWith(
          () => _FakeFeedNotifier(feedItems),
        ),
        wordOfDayProvider.overrideWith((ref) async => wotd),
      ],
      child: FTheme(
        data: FThemes.zinc.light.touch,
        child: const MaterialApp(home: HomeSearchPage()),
      ),
    ),
  );
  await tester.pump();
  await tester.pumpAndSettle();
}

class _FakeFeedNotifier extends ActivityFeedNotifier {
  _FakeFeedNotifier(this.items);

  final List<FeedActivityItem> items;

  @override
  ActivityFeedState build() {
    state = ActivityFeedState(items: items);
    return state;
  }
}
