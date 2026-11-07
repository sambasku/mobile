import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';
import 'package:sambasku_mobile/features/activity/domain/entities/feed_activity_item.dart';
import 'package:sambasku_mobile/features/activity/presentation/providers/activity_feed_providers.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_of_day.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/pages/home_search_page.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/providers/word_of_day_providers.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';

void main() {
  testWidgets('dbg', (tester) async {
    final feedItems = List.generate(12, (i) => FeedActivityItem(
      id: 'a$i', kind: FeedActivityKind.comment,
      createdAt: '2026-10-01T10:00:00Z', body: 'obrolan $i',
      actor: const FeedActivityActor(username: 'warga', displayName: 'Warga'),
    ));
    final wotd = WordOfDay(
      word: const WordDetail(id: 'w1', lemma: 'lading', languageId: 'mly-smb',
        wordType: 'lemma', status: 'published', isVerified: true, isCorrected: false,
        meanings: [WordMeaning(id: 'm1', definition: 'cicada', orderIndex: 0)]),
      date: '2026-10-02', isNewThisWeek: false,
    );
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        activityFeedProvider.overrideWith2((category) => _FakeFeedNotifier(category, feedItems)),
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
    ));
    await tester.pump();
    await tester.pumpAndSettle();
    final collapsible = find.byKey(const ValueKey('header_collapse'));
    final feedList = find.byWidgetPredicate((w) => w is CustomScrollView && w.controller != null).first;
    print('H0=${tester.getSize(collapsible).height}');
    final g = await tester.startGesture(tester.getCenter(feedList));
    await g.moveBy(const Offset(0, -50));
    await tester.pump();
    print('H50=${tester.getSize(collapsible).height}');
    await g.up();
    await tester.pumpAndSettle();
    print('Hsnapped=${tester.getSize(collapsible).height}');
    final g2 = await tester.startGesture(tester.getCenter(feedList));
    await g2.moveBy(const Offset(0, 200));
    await g2.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    print('Hafter=${tester.getSize(collapsible).height}');
    expect(true, isTrue);
  });
}
class _FakeFeedNotifier extends ActivityFeedNotifier {
  _FakeFeedNotifier(super.category, this.items);
  final List<FeedActivityItem> items;
  @override
  ActivityFeedState build() => ActivityFeedState(items: items, hasLoaded: true);
}
