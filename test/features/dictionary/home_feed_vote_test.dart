import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:sambasku_mobile/features/activity/domain/entities/feed_activity_item.dart';
import 'package:sambasku_mobile/features/activity/presentation/providers/activity_feed_providers.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_of_day.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/pages/home_search_page.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/providers/word_of_day_providers.dart';

// #94: feed penilaian di home tampil dengan @username + deskripsi beku
// (payload "lemma" sudah pas / perlu dicek ulang) — tile shared
// ActivityFeedTile dipakai di home, bukan row duplikat tanpa username.
void main() {
  testWidgets('item vote di home menampilkan @username + body beku', (tester) async {
    final feedItems = [
      FeedActivityItem(
        id: 'vote1',
        kind: FeedActivityKind.vote,
        createdAt: '2026-10-01T10:00:00Z',
        body: '"apam" sudah pas',
        actor: const FeedActivityActor(username: 'budi', displayName: 'Budi'),
        subtitle: 'apam',
      ),
    ];
    await pumpHome(tester, feedItems);

    // Baris @username aktor tampil (perilaku ActivityFeedTile).
    expect(find.text('@budi'), findsOneWidget);
    // Deskripsi beku tampil (Text.rich split lemma bold — cek per bagian).
    expect(find.textContaining('apam'), findsWidgets);
    expect(find.textContaining('sudah pas'), findsOneWidget);
  });

  testWidgets('item vote arah tolak menampilkan body perlu dicek ulang', (tester) async {
    final feedItems = [
      FeedActivityItem(
        id: 'vote2',
        kind: FeedActivityKind.vote,
        createdAt: '2026-10-01T10:00:00Z',
        body: '"apam" perlu dicek ulang',
        actor: const FeedActivityActor(username: 'budi', displayName: 'Budi'),
        subtitle: 'apam',
      ),
    ];
    await pumpHome(tester, feedItems);

    expect(find.text('@budi'), findsOneWidget);
    expect(find.textContaining('perlu dicek ulang'), findsOneWidget);
  });
}

Future<void> pumpHome(WidgetTester tester, List<FeedActivityItem> feedItems) async {
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
        activityFeedProvider.overrideWith(() => _FakeFeedNotifier(feedItems)),
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
