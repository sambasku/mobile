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
  testWidgets('header home tergulung saat scroll bawah, balik saat scroll atas', (
    tester,
  ) async {
    await pumpHome(tester);

    // Header konten tampil di posisi awal.
    expect(find.text('Usul kata baru'), findsOneWidget);
    expect(find.text('Cari kata Sambas...'), findsOneWidget);

    // Scroll ke bawah: search bar + tombol usul keluar viewport.
    await tester.fling(find.byType(CustomScrollView), const Offset(0, -600), 800);
    await tester.pumpAndSettle();
    expect(find.text('Usul kata baru'), findsNothing);
    expect(find.text('Cari kata Sambas...'), findsNothing);

    // Scroll ke atas: header konten muncul lagi.
    await tester.fling(find.byType(CustomScrollView), const Offset(0, 600), 800);
    await tester.pumpAndSettle();
    expect(find.text('Usul kata baru'), findsOneWidget);
    expect(find.text('Cari kata Sambas...'), findsOneWidget);  });
}

Future<void> pumpHome(WidgetTester tester) async {
  // Feed siap: cukup item supaya konten melebihi viewport (bisa scroll).
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
      meanings: [
        WordMeaning(id: 'm1', definition: 'cicada', orderIndex: 0),
      ],
    ),
    date: '2026-10-02',
    isNewThisWeek: false,
  );

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
  // Frame: build + microtask notifier + async WOTD resolve.
  await tester.pump();
  tester.view.physicalSize = const Size(400, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
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
