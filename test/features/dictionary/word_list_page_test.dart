import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:sambasku_mobile/features/dictionary/data/providers/dictionary_data_providers.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_of_day.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_summary.dart';
import 'package:sambasku_mobile/features/dictionary/domain/failures/dictionary_failure.dart';
import 'package:sambasku_mobile/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/pages/word_list_page.dart';

WordSummary _word(String lemma, {String? sense, String? matchType}) =>
    WordSummary(
      id: lemma.padRight(26, '0'),
      lemma: lemma,
      languageCode: 'SBS',
      wordType: 'word',
      status: 'published',
      isVerified: true,
      sense: sense,
      matchType: matchType,
    );

/// PRD relasi-lemma: hasil perluasan kelompok makna dibedakan di subtitle.
class _RelatedGroupStub extends _StubDictionaryRepository {
  @override
  Future<Either<DictionaryFailure, WordSearchPage>> listWords({
    required String q,
    required int limit,
    String? category,
    String? cursor,
    String? letter,
    bool? isVerified,
  }) async =>
      Either.right(WordSearchPage(
        items: [
          _word('apam', sense: 'sejenis kue'),
          _word('misai', sense: 'bulu di atas bibir', matchType: 'related_group'),
          _word('kumis', matchType: 'related_group'),
        ],
        nextCursor: null,
        hasMore: false,
      ));
}

class _StubDictionaryRepository implements DictionaryRepository {
  @override
  Future<Either<DictionaryFailure, WordSearchPage>> listWords({
    required String q,
    required int limit,
    String? category,
    String? cursor,
    String? letter,
    bool? isVerified,
  }) async =>
      Either.right(WordSearchPage(
        items: [_word('apam'), _word('budu'), _word("'caci")],
        nextCursor: null,
        hasMore: false,
      ));

  @override
  Future<Either<DictionaryFailure, List<WordCategory>>> listCategories() async =>
      const Right(<WordCategory>[]);

  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordById(
    String id, {
    bool forceRefresh = false,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordByLemma(
    String lemma, {
    bool forceRefresh = false,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<DictionaryFailure, WordOfDay?>> getWordOfDay({
    bool forceRefresh = false,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> searchWords({
    required String query,
    required int limit,
    String? cursor,
    String searchIn = 'lemma',
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> listLatest({
    required int limit,
    String? cursor,
    bool forceRefresh = false,
  }) async =>
      throw UnimplementedError();
}

void main() {
  testWidgets('render item + header huruf (A/B/#) - tap buka detail', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/words',
      routes: [
        GoRoute(
          path: '/words',
          builder: (context, state) => const WordListPage(),
        ),
        GoRoute(
          path: '/words/:id',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('DETAIL_SENTINEL')),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dictionaryRepositoryProvider.overrideWithValue(
            _StubDictionaryRepository(),
          ),
        ],
        child: MaterialApp.router(
          theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          routerConfig: router,
          builder: (context, child) =>
              FTheme(data: FThemes.zinc.light.touch, child: child!),
        ),
      ),
    );

    // Flush microtask build-then-load + settle frame.
    await tester.runAsync(() async {
      for (var i = 0; i < 5; i++) {
        await Future<void>.delayed(Duration.zero);
      }
    });
    await tester.pumpAndSettle();

    // List normal urut server - tanpa grouping header huruf.
    expect(find.text('apam'), findsOneWidget);
    expect(find.text('budu'), findsOneWidget);
    expect(find.text("'caci"), findsOneWidget);

    // Tap item → push /words/:id (detail existing).
    await tester.tap(find.text('apam'));
    await tester.pumpAndSettle();
    expect(find.text('DETAIL_SENTINEL'), findsOneWidget);
    expect(find.text('apam'), findsNothing);
  });

  // PRD relasi-lemma: hasil perluasan grup diberi penanda, hasil langsung tidak.
  testWidgets('subtitle "Makna terkait" hanya untuk hasil related_group', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/words',
      routes: [
        GoRoute(
          path: '/words',
          builder: (context, state) => const WordListPage(),
        ),
        GoRoute(
          path: '/words/:id',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('DETAIL_SENTINEL')),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dictionaryRepositoryProvider.overrideWithValue(_RelatedGroupStub()),
        ],
        child: MaterialApp.router(
          theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          routerConfig: router,
          builder: (context, child) =>
              FTheme(data: FThemes.zinc.light.touch, child: child!),
        ),
      ),
    );

    await tester.runAsync(() async {
      for (var i = 0; i < 5; i++) {
        await Future<void>.delayed(Duration.zero);
      }
    });
    await tester.pumpAndSettle();

    // Hasil langsung: subtitle tetap gloss apa adanya.
    expect(find.text('sejenis kue'), findsOneWidget);
    expect(find.text('Makna terkait · sejenis kue'), findsNothing);

    // Hasil perluasan grup: penanda + gloss, atau penanda saja.
    expect(find.text('Makna terkait · bulu di atas bibir'), findsOneWidget);
    expect(find.text('Makna terkait'), findsOneWidget);
  });
}
