import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:sambasku_mobile/features/dictionary/dictionary_router.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_of_day.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_summary.dart';
import 'package:sambasku_mobile/features/dictionary/domain/failures/dictionary_failure.dart';
import 'package:sambasku_mobile/features/dictionary/domain/providers/dictionary_domain_providers.dart';
import 'package:sambasku_mobile/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:sambasku_mobile/features/dictionary/domain/usecases/search_words_use_case.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/pages/word_complete_page.dart';

void main() {
  testWidgets('awalnya meminta minimal 2 huruf, bukan layar kosong', (
    tester,
  ) async {
    await _pumpPage(tester, _FakeDictionaryRepository());

    expect(find.text('Ketik minimal 2 huruf untuk mencari kata.'), findsOneWidget);
    expect(find.byType(FCircularProgress), findsNothing);
  });

  testWidgets('hasil kosong menjelaskan kata yang diketik', (tester) async {
    final repo = _FakeDictionaryRepository()..empty = true;
    await _pumpPage(tester, repo);

    await tester.enterText(find.byType(FTextField), 'zzz');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    // Satu assertion: pesan ikut menyebut query yang diketik.
    expect(
      find.textContaining('Tidak ada kata yang cocok dengan "zzz"'),
      findsOneWidget,
    );
  });

  testWidgets('hasil menampilkan lemma lalu tap membuka detail kata', (
    tester,
  ) async {
    final router = await _pumpPage(tester, _FakeDictionaryRepository());

    await tester.enterText(find.byType(FTextField), 'bakat');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    final tile = find.widgetWithText(FTile, 'bakat');
    expect(tile, findsOneWidget);
    expect(find.textContaining('membuat'), findsOneWidget);

    await tester.tap(tile);
    await tester.pumpAndSettle();

    expect(find.text('detail-service'), findsOneWidget);
    expect(
      router.routerDelegate.currentConfiguration.matches.map(
        (m) => m.matchedLocation,
      ),
      // matchedLocation sudah me-resolve parameter ke path aktual.
      contains('/words/service'),
    );
  });

  testWidgets('kegagalan pencarian menampilkan pesan dan tombol coba lagi', (
    tester,
  ) async {
    final repo = _FakeDictionaryRepository()..fail = true;
    await _pumpPage(tester, repo);

    await tester.enterText(find.byType(FTextField), 'bakat');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('Gagal memuat kata'), findsOneWidget);
    expect(find.widgetWithText(FButton, 'Coba lagi'), findsOneWidget);
  });
}

Future<GoRouter> _pumpPage(
  WidgetTester tester,
  _FakeDictionaryRepository repo,
) async {
  final router = GoRouter(
    initialLocation: DictionaryRouter.complete.path,
    routes: [
      GoRoute(
        path: DictionaryRouter.complete.path,
        builder: (_, _) => const WordCompletePage(),
      ),
      GoRoute(
        path: DictionaryRouter.detail.path,
        builder: (_, state) =>
            Scaffold(body: Text('detail-${state.pathParameters['id']}')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        searchWordsUseCaseProvider.overrideWithValue(SearchWordsUseCase(repo)),
      ],
      child: MaterialApp.router(
        theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
        localizationsDelegates: FLocalizations.localizationsDelegates,
        supportedLocales: FLocalizations.supportedLocales,
        routerConfig: router,
        builder: (context, child) => FTheme(
          data: FThemes.zinc.light.touch,
          child: child!,
        ),
      ),
    ),
  );
  await tester.pump();
  return router;
}

class _FakeDictionaryRepository implements DictionaryRepository {
  bool empty = false;
  bool fail = false;

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> searchWords({
    required String query,
    required int limit,
    String? cursor,
    String searchIn = 'lemma',
  }) async {
    if (fail) return Either.left(const DictionaryFailure('Gagal memuat kata'));
    return Either.right(
      WordSearchPage(
        items: empty
            ? const []
            : [
                WordSummary(
                  id: 'service',
                  lemma: query,
                  languageCode: 'snb',
                  wordType: 'noun',
                  status: 'published',
                  isVerified: true,
                  sense: 'membuat atau mengerjakan sesuatu',
                ),
              ],
        hasMore: false,
      ),
    );
  }

  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordById(
    String id, {
    bool forceRefresh = false,
  }) => throw UnimplementedError();

  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordByLemma(
    String lemma, {
    bool forceRefresh = false,
  }) => throw UnimplementedError();

  @override
  Future<Either<DictionaryFailure, WordOfDay?>> getWordOfDay({
    bool forceRefresh = false,
  }) => throw UnimplementedError();

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> listWords({
    required String q,
    required int limit,
    String? cursor,
    String? letter,
    bool? isVerified,
  }) => throw UnimplementedError();

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> listLatest({
    required int limit,
    String? cursor,
    bool forceRefresh = false,
  }) => throw UnimplementedError();
}
