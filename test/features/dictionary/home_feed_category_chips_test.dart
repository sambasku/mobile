import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/features/activity/data/activity_feed_repository.dart';
import 'package:sambasku_mobile/features/activity/domain/entities/feed_activity_item.dart';
import 'package:sambasku_mobile/features/activity/presentation/providers/activity_feed_providers.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_of_day.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/pages/home_search_page.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/providers/word_of_day_providers.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';

/// #193: chips kategori feed beranda.
///
/// Yang dijaga: chip full-bleed (tidak kena gutter horizontal), kategori
/// lain TIDAK auto-load (nol request sampai chip di-tap), dan sekali ketap
/// kategori = satu request dengan wire value yang benar.
class RecordingRepository implements ActivityFeedRepository {
  final calls = <FeedCategory>[];

  /// Jumlah item per halaman feed (test scroll butuh feed panjang).
  int itemCount = 1;

  @override
  Future<ActivityFeedPage> list({
    int limit = 20,
    String? cursor,
    bool forceRefresh = false,
    bool excludeSelf = false,
    FeedCategory category = FeedCategory.all,
  }) async {
    calls.add(category);
    return ActivityFeedPage(
      items: [
        for (var i = 0; i < itemCount; i++)
          FeedActivityItem(
            id: 'a-${category.wire}-$i',
            kind: FeedActivityKind.comment,
            createdAt: '2026-10-01T10:00:00Z',
            body: 'aktivitas kategori ${category.wire} baris $i',
            // Actor diisi supaya tile tidak memakai label fallback 'Warga'
            // yang bentrok dengan text chip kategori `joined`.
            actor: const FeedActivityActor(
              username: 'budi',
              displayName: 'Budi Santoso',
            ),
          ),
      ],
      nextCursor: null,
      hasMore: false,
    );
  }
}

void main() {
  testWidgets('chips kategori tampil dan full-bleed (tanpa gutter)', (
    tester,
  ) async {
    final repo = RecordingRepository();
    await pumpHome(tester, repo);

    // Kelima chip ada (viewport test 560px → semua muat).
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Pencarian warga'), findsOneWidget);
    expect(find.text('Perbaikan'), findsOneWidget);
    expect(find.text('Pengumuman'), findsOneWidget);
    expect(find.text('Warga'), findsOneWidget);

    // Full-bleed: ListView chips menempel tepi kiri viewport (gutter 12
    // hanya padding internal scroll view, bukan margin konten). Diukur di
    // container scroll-nya, bukan text chip - offset text ikut padding
    // internal FButton yang bisa berubah antar versi forui.
    final screenLeft = tester.getTopLeft(find.byType(FTheme)).dx;
    final listLeft = tester
        .getTopLeft(find.byKey(const ValueKey('feed_category_chips')))
        .dx;
    expect(listLeft - screenLeft, lessThan(1));

    // Chips berada di atas list feed (di bawah heading, sebelum item).
    final chipTop = tester.getTopLeft(find.text('Semua')).dy;
    final firstItemTop = tester
        .getTopLeft(find.textContaining('aktivitas kategori all'))
        .dy;
    expect(chipTop, lessThan(firstItemTop));
  });

  testWidgets('kategori lain TIDAK load sebelum chip di-tap (nol request)', (
    tester,
  ) async {
    final repo = RecordingRepository();
    await pumpHome(tester, repo);
    await tester.pumpAndSettle();

    // Hanya kategori all yang auto-load di frame pertama.
    expect(repo.calls, [FeedCategory.all]);

    // Ketuk chip "Warga" → tepat satu request tambahan.
    await tapChip(tester, 'Warga');

    expect(repo.calls, contains(FeedCategory.joined));
    expect(repo.calls.where((c) => c == FeedCategory.joined), hasLength(1));
  });

  testWidgets('tap chip yang sama dua kali = satu request (cache memori)', (
    tester,
  ) async {
    final repo = RecordingRepository();
    await pumpHome(tester, repo);
    await tester.pumpAndSettle();

    await tapChip(tester, 'Pengumuman');
    await tester.pumpAndSettle();
    final afterFirst = repo.calls
        .where((c) => c == FeedCategory.announcement)
        .length;

    await tapChip(tester, 'Semua');
    await tester.pumpAndSettle();
    await tapChip(tester, 'Pengumuman');
    await tester.pumpAndSettle();

    expect(
      repo.calls.where((c) => c == FeedCategory.announcement).length,
      afterFirst,
      reason: 'kategori yang sudah pernah dimuat tidak boleh fetch ulang',
    );
  });

  testWidgets('konten chip ikut berubah sesuai kategori', (tester) async {
    final repo = RecordingRepository();
    await pumpHome(tester, repo);
    await tester.pumpAndSettle();

    await tapChip(tester, 'Perbaikan');
    await tester.pumpAndSettle();

    expect(
      find.textContaining('aktivitas kategori correction'),
      findsOneWidget,
    );
    expect(find.textContaining('aktivitas kategori all'), findsNothing);
  });

  testWidgets('chip terpilih tetap benar & bisa di-tap saat kategori memuat', (
    tester,
  ) async {
    final repo = RecordingRepository();
    // get() ditahan supaya state loading (isLoading, belum hasLoaded) terlihat.
    await pumpHome(tester, repo);
    await tester.pumpAndSettle();

    // Tap lalu jangan settle: masih dalam frame loading kategori baru.
    await tester.tap(find.text('Warga'));
    await tester.pump();

    // Dulu: seluruh scroll view diganti skeleton yang chip-nya hard-code
    // "Semua" + disabled -> pilihan terlihat balik ke Semua + tak bisa tap.
    expect(find.byKey(const ValueKey('feed_category_chips')), findsOneWidget);
    final wargaChip = find.ancestor(
      of: find.text('Warga'),
      matching: find.byType(FButton),
    );
    expect(
      tester.widget<FButton>(wargaChip).variant,
      FButtonVariant.primary,
      reason: 'chip yang di-tap harus tampil terpilih selama loading',
    );
    await tester.pumpAndSettle();
  });

  testWidgets('baris chip menempel di bawah app bar saat feed di-scroll', (
    tester,
  ) async {
    final repo = RecordingRepository();
    await pumpHome(tester, repo, itemCount: 30);
    await tester.pumpAndSettle();

    final chipTopBefore = tester.getTopLeft(find.text('Semua')).dy;
    // Scroll feed jauh ke bawah.
    final feed = find
        .byWidgetPredicate((w) => w is CustomScrollView && w.controller != null)
        .first;
    await tester.drag(feed, const Offset(0, -600));
    await tester.pumpAndSettle();

    // Chip masih ada (tidak hilang) dan posisinya di layar (tidak keluar
    // viewport) - inilah efek "pinned".
    expect(find.text('Semua'), findsOneWidget);
    final chipTopAfter = tester.getTopLeft(find.text('Semua')).dy;
    expect(
      chipTopAfter,
      lessThan(chipTopBefore),
      reason: 'baris chip harus naik ke atas (menempel) saat feed di-scroll',
    );
    expect(
      chipTopAfter,
      greaterThanOrEqualTo(0),
      reason: 'baris chip harus tetap di dalam viewport',
    );
  });
}

Future<void> tapChip(WidgetTester tester, String label) async {
  // Viewport test dibuat cukup lebar → semua chip di dalam layar, tanpa
  // perlu scroll horizontal.
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Future<void> pumpHome(
  WidgetTester tester,
  RecordingRepository repo, {
  int itemCount = 1,
}) async {
  repo.itemCount = itemCount;
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

  // Layar cukup lebar untuk 5 chip (hemat scroll helper yang rapuh).
  // forui 0.27: padding FButton lebih besar - 560px membuat chip ke-4/5
  // offscreen (ListView horizontal lazy), pakai 1000px.
  tester.view.physicalSize = const Size(1000, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        activityFeedRepositoryProvider.overrideWithValue(repo),
        wordOfDayProvider.overrideWith((ref) async => wotd),
      ],
      child: FTheme(
        data: foruiPalettes['zinc']!.light.touch,
        child: const MaterialApp(home: HomeSearchPage()),
      ),
    ),
  );
  await tester.pump();
  await tester.pumpAndSettle();
}
