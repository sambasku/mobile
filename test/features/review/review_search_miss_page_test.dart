import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
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
  const missTayang = ReviewSearchMiss(
    id: 'miss-tayang',
    term: 'nandor',
    searchIn: 'translation',
    hitCount: 23,
    isVisible: true,
    isFulfilled: false,
  );

  testWidgets('menampilkan miss + status tayang, 👁 hanya untuk belum tayang', (
    tester,
  ) async {
    await _pumpPanel(tester, items: [missBaru, missTayang]);

    expect(find.text('kepayang'), findsOneWidget);
    expect(find.text('nandor'), findsOneWidget);
    expect(find.textContaining('belum tayang'), findsOneWidget);
    expect(find.textContaining('tayang'), findsWidgets);
    expect(find.byIcon(FLucideIcons.eye), findsOneWidget);
  });

  testWidgets('tap 👁 memanggil setVisible + refresh list', (tester) async {
    final repo = _FakeRepo();
    await _pumpPanel(tester, items: [missBaru], repo: repo);

    await tester.tap(find.byIcon(FLucideIcons.eye));
    await tester.pumpAndSettle();

    expect(repo.setVisibleCalls, [(missBaru.id, true)]);
    expect(find.textContaining('tayang di beranda publik'), findsOneWidget);
  });

  testWidgets('gagal tayang → toast destructive, list tetap', (tester) async {
    final repo = _FakeRepo()..setVisibleFails = true;
    await _pumpPanel(tester, items: [missBaru], repo: repo);

    await tester.tap(find.byIcon(FLucideIcons.eye));
    await tester.pumpAndSettle();

    expect(find.text('Gagal menayangkan'), findsOneWidget);
    expect(find.text('kepayang'), findsOneWidget);
  });

  testWidgets('list kosong → pesan kosong, tanpa tile', (tester) async {
    await _pumpPanel(tester, items: const []);

    expect(find.textContaining('Belum ada pencarian kosong'), findsOneWidget);
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
      child: MaterialApp(
        theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
        localizationsDelegates: FLocalizations.localizationsDelegates,
        supportedLocales: FLocalizations.supportedLocales,
        builder: (context, child) => FToaster(
          child: FTheme(
            data: FThemes.zinc.light.touch,
            child: child!,
          ),
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Navigator(
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => const ReviewSearchMissPage(),
              ),
            ),
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

  bool setVisibleFails = false;

  @override
  Future<Either<ReviewFailure, Unit>> setVisible(String id, bool visible) async {
    setVisibleCalls.add((id, visible));
    if (setVisibleFails) {
      return Either.left(ReviewFailure('Gagal menayangkan'));
    }
    return Either.right(unit);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}
