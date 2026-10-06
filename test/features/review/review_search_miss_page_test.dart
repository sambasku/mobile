import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:sambasku_mobile/core/widgets/swipe_decision_card.dart';
import 'package:sambasku_mobile/features/review/data/repositories/review_search_miss_repository_impl.dart';
import 'package:sambasku_mobile/features/review/domain/entities/review_search_miss.dart';
import 'package:sambasku_mobile/features/review/domain/failures/review_failure.dart';
import 'package:sambasku_mobile/features/review/presentation/pages/review_search_miss_page.dart';
import 'package:sambasku_mobile/features/review/presentation/providers/review_search_miss_providers.dart';

void main() {
  const missBaru = ReviewSearchMiss(
    id: 'miss-baru',
    term: 'kepayang',
    searchIn: 'lemma',
    hitCount: 7,
    isVisible: false,
    isFulfilled: false,
  );
  const missKedua = ReviewSearchMiss(
    id: 'miss-kedua',
    term: 'nandor',
    searchIn: 'translation',
    hitCount: 23,
    isVisible: false,
    isFulfilled: false,
  );
  const missTayang = ReviewSearchMiss(
    id: 'miss-tayang',
    term: 'kalumpe',
    searchIn: 'lemma',
    hitCount: 2,
    isVisible: true,
    isFulfilled: false,
  );

  testWidgets('deck menampilkan kartu pertama, kartu berikutnya disembunyikan', (
    tester,
  ) async {
    await _pumpPanel(tester, items: [missBaru, missKedua]);

    expect(find.text('kepayang'), findsOneWidget);
    expect(find.textContaining('belum tayang'), findsOneWidget);
    expect(find.text('nandor'), findsNothing);
    expect(find.text('Lewati'), findsOneWidget);
    expect(find.text('Singkirkan'), findsOneWidget);
    expect(find.text('Tayang'), findsOneWidget);
  });

  testWidgets('swipe kanan tayang + pindah kartu optimis (tanpa tunggu request)', (
    tester,
  ) async {
    final repo = _FakeRepo()..holdVisible = true;
    await _pumpPanel(tester, items: [missBaru, missKedua], repo: repo);

    await tester.fling(find.text('kepayang'), const Offset(400, 0), 800);
    await tester.pumpAndSettle();

    expect(repo.setVisibleCalls, [(missBaru.id, true)]);
    // Kartu berikutnya sudah tampil; request pertama belum selesai
    // (Completer masih tertahan) — ini bukti advance optimis.
    expect(find.text('nandor'), findsOneWidget);
    expect(find.text('kepayang'), findsNothing);

    repo.completePending(Either.right(unit));
    await tester.pumpAndSettle();
    expect(find.text('nandor'), findsOneWidget);
  });

  testWidgets('swipe kiri singkirkan + lanjut ke kartu berikutnya', (
    tester,
  ) async {
    final repo = _FakeRepo();
    await _pumpPanel(tester, items: [missBaru, missKedua], repo: repo);

    await tester.fling(find.text('kepayang'), const Offset(-400, 0), 800);
    await tester.pumpAndSettle();

    expect(repo.dismissCalls, [missBaru.id]);
    expect(find.text('nandor'), findsOneWidget);
    expect(find.text('kepayang'), findsNothing);
  });

  testWidgets('swipe atas lewati → POST skip (per user) + lanjut', (
    tester,
  ) async {
    final repo = _FakeRepo();
    await _pumpPanel(tester, items: [missBaru, missKedua], repo: repo);

    final card = find.byWidgetPredicate((w) => w is SwipeDecisionCard);
    await tester.timedDrag(card, const Offset(0, -300), const Duration(milliseconds: 120));
    await tester.pumpAndSettle();

    expect(repo.skipCalls, [missBaru.id]);
    expect(find.text('nandor'), findsOneWidget);
    expect(find.text('kepayang'), findsNothing);
  });

  testWidgets('tombol Lewati di action bar memanggil skip', (tester) async {
    final repo = _FakeRepo();
    await _pumpPanel(tester, items: [missBaru, missKedua], repo: repo);

    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();

    expect(repo.skipCalls, [missBaru.id]);
    expect(find.text('nandor'), findsOneWidget);
  });

  testWidgets('gagal tayang → kartu kembali ke depan + toast destructive', (
    tester,
  ) async {
    final repo = _FakeRepo()..setVisibleFails = true;
    await _pumpPanel(tester, items: [missBaru, missKedua], repo: repo);

    await tester.fling(find.text('kepayang'), const Offset(400, 0), 800);
    await tester.pumpAndSettle();

    expect(find.text('Gagal menayangkan'), findsOneWidget);
    expect(find.text('kepayang'), findsOneWidget);
    expect(find.text('nandor'), findsNothing);
  });

  testWidgets('gagal lewati → kartu kembali ke depan + toast destructive', (
    tester,
  ) async {
    final repo = _FakeRepo()..skipFails = true;
    await _pumpPanel(tester, items: [missBaru], repo: repo);

    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();

    expect(find.text('Gagal melewati'), findsOneWidget);
    expect(find.text('kepayang'), findsOneWidget);
  });

  testWidgets('kartu sudah tayang → swipe kanan tanpa aksi (spring back)', (
    tester,
  ) async {
    final repo = _FakeRepo();
    await _pumpPanel(tester, items: [missTayang], repo: repo);

    expect(find.text('kalumpe'), findsOneWidget);
    expect(find.text('tayang'), findsOneWidget);
    // Tombol Tayang dinonaktifkan untuk kartu sudah tayang.
    final tayangText = find.text('Tayang');
    final tayangBtn = tester.widget<FButton>(
      find.ancestor(of: tayangText, matching: find.byType(FButton)).first,
    );
    expect(tayangBtn.onPress, isNull);

    await tester.fling(find.text('kalumpe'), const Offset(400, 0), 800);
    await tester.pumpAndSettle();

    expect(repo.setVisibleCalls, isEmpty);
    expect(find.text('kalumpe'), findsOneWidget);
  });

  testWidgets('ketuk kartu → form usulan (prefill)', (tester) async {
    await _pumpPanel(tester, items: [missBaru]);

    await tester.tap(find.text('kepayang'));
    await tester.pumpAndSettle();

    expect(find.text('form usul'), findsOneWidget);
  });

  testWidgets('deck habis → pesan selesai + muat ulang', (tester) async {
    await _pumpPanel(tester, items: [missBaru]);

    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Selesai — semua pencarian kosong'), findsOneWidget);
    expect(find.text('Muat ulang'), findsOneWidget);
  });

  testWidgets('list kosong → pesan kosong, tanpa kartu', (tester) async {
    await _pumpPanel(tester, items: const []);

    expect(find.textContaining('Belum ada pencarian kosong'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is SwipeDecisionCard), findsNothing);
  });
}

Future<void> _pumpPanel(
  WidgetTester tester, {
  required List<ReviewSearchMiss> items,
  _FakeRepo? repo,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        reviewSearchMissRepositoryProvider.overrideWithValue(
          repo ?? _FakeRepo(),
        ),
        reviewSearchMissProvider.overrideWith((ref) async => items),
      ],
      child: MaterialApp.router(
        theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
        localizationsDelegates: FLocalizations.localizationsDelegates,
        supportedLocales: FLocalizations.supportedLocales,
        routerConfig: GoRouter(
          initialLocation: '/review/search-misses',
          routes: [
            GoRoute(
              path: '/review/search-misses',
              builder: (_, _) => const ReviewSearchMissPage(),
            ),
            GoRoute(
              path: '/contribute',
              builder: (_, _) => const Scaffold(body: Text('form usul')),
            ),
          ],
        ),
        builder: (context, child) => FToaster(
          child: FTheme(
            data: FThemes.zinc.light.touch,
            child: child!,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

class _FakeRepo implements ReviewSearchMissRepositoryImpl {
  List<(String, bool)> setVisibleCalls = [];
  List<String> dismissCalls = [];
  List<String> skipCalls = [];

  bool setVisibleFails = false;
  bool dismissFails = false;
  bool skipFails = false;

  /// Kalau [holdVisible] true, setVisible menunggu [completePending] —
  /// dipakai bukti pindah kartu optimis.
  bool holdVisible = false;
  Completer<Either<ReviewFailure, Unit>>? _held;

  void completePending(Either<ReviewFailure, Unit> value) {
    final completer = _held;
    _held = null;
    completer?.complete(value);
  }

  @override
  Future<Either<ReviewFailure, Unit>> setVisible(String id, bool visible) async {
    setVisibleCalls.add((id, visible));
    if (setVisibleFails) {
      return Either.left(ReviewFailure('Gagal menayangkan'));
    }
    if (holdVisible) {
      final completer = _held = Completer<Either<ReviewFailure, Unit>>();
      return completer.future;
    }
    return Either.right(unit);
  }

  @override
  Future<Either<ReviewFailure, Unit>> dismiss(String id) async {
    dismissCalls.add(id);
    if (dismissFails) {
      return Either.left(ReviewFailure('Gagal menyingkirkan'));
    }
    return Either.right(unit);
  }

  @override
  Future<Either<ReviewFailure, Unit>> skip(String id) async {
    skipCalls.add(id);
    if (skipFails) {
      return Either.left(ReviewFailure('Gagal melewati'));
    }
    return Either.right(unit);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}
