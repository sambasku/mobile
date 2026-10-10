import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/features/dictionary/data/providers/dictionary_data_providers.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_of_day.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_summary.dart';
import 'package:sambasku_mobile/features/dictionary/domain/failures/dictionary_failure.dart';
import 'package:sambasku_mobile/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/providers/word_list_providers.dart';

WordSummary _word(String lemma) => WordSummary(
  id: lemma.padRight(26, '0'),
  lemma: lemma,
  languageCode: 'SBS',
  wordType: 'word',
  status: 'published',
  isVerified: true,
);

/// Mock repository: halaman 1 (2 item + cursor) lalu halaman 2 (1 item,
/// habis). Mencatat tiap panggilan listWords untuk assert filter/pagination.
class _FakeDictionaryRepository implements DictionaryRepository {
  final calls = <({String q, String? cursor})>[];
  final searchCalls = <({String query, String searchIn, String? cursor})>[];
  bool failNext = false;
  bool empty = false;
  bool searchReturnsVariant = false;

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> listWords({
    required String q,
    required int limit,
    String? category,
    String? cursor,
    String? letter,
    bool? isVerified,
  }) async {
    calls.add((q: q, cursor: cursor));
    if (failNext) {
      failNext = false;
      return Either.left(const DictionaryFailure('gagal memuat'));
    }
    if (empty) {
      return Either.right(
        const WordSearchPage(items: [], nextCursor: null, hasMore: false),
      );
    }
    if (cursor == 'page-2') {
      return Either.right(
        WordSearchPage(
          items: [_word('capai')],
          nextCursor: null,
          hasMore: false,
        ),
      );
    }
    return Either.right(
      WordSearchPage(
        items: [_word('apam'), _word('budu')],
        nextCursor: 'page-2',
        hasMore: true,
      ),
    );
  }

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
  }) async {
    searchCalls.add((query: query, searchIn: searchIn, cursor: cursor));
    if (searchReturnsVariant && cursor == null) {
      return Either.right(
        WordSearchPage(
          items: [_word('ketek')],
          nextCursor: 'search-2',
          hasMore: false,
        ),
      );
    }
    return Either.right(
      const WordSearchPage(items: [], nextCursor: null, hasMore: false),
    );
  }

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> listLatest({
    required int limit,
    String? cursor,
    bool forceRefresh = false,
  }) async => throw UnimplementedError();
}

Future<void> _flush() async {
  // microtask build-then-load + await repo (semua sync/immediate).
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test(
    'build memuat halaman 1; loadMore merge halaman 2 + cursor jalan',
    () async {
      final repo = _FakeDictionaryRepository();
      final container = ProviderContainer(
        overrides: [dictionaryRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final sub = container.listen(wordListProvider, (_, _) {});
      await _flush();

      var state = container.read(wordListProvider);
      expect(state.isLoading, false);
      expect(state.items.map((w) => w.lemma), ['apam', 'budu']);
      expect(state.nextCursor, 'page-2');
      expect(state.hasMore, true);
      expect(repo.calls.single.q, '');
      expect(repo.calls.single.cursor, isNull);

      await container.read(wordListProvider.notifier).loadMore();
      state = container.read(wordListProvider);
      expect(state.items.map((w) => w.lemma), ['apam', 'budu', 'capai']);
      expect(state.hasMore, false);
      expect(state.nextCursor, isNull);
      expect(repo.calls.last.cursor, 'page-2');
      sub.close();
    },
  );

  test('onQueryChanged: q kosong refetch langsung tanpa debounce', () async {
    final repo = _FakeDictionaryRepository();
    final container = ProviderContainer(
      overrides: [dictionaryRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final sub = container.listen(wordListProvider, (_, _) {});
    await _flush();
    final callsBefore = repo.calls.length;

    container.read(wordListProvider.notifier).onQueryChanged('');
    await _flush();

    expect(repo.calls.length, callsBefore + 1);
    expect(repo.calls.last.q, isEmpty);
    expect(repo.calls.last.cursor, isNull);
    sub.close();
  });

  test('onQueryChanged: q berisi → debounce 400ms → fetch dengan q', () async {
    final repo = _FakeDictionaryRepository();
    final container = ProviderContainer(
      overrides: [dictionaryRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final sub = container.listen(wordListProvider, (_, _) {});
    await _flush();
    final callsBefore = repo.calls.length;

    container.read(wordListProvider.notifier).onQueryChanged('  ke  ');

    // Sebelum 400ms: belum ada request baru.
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(repo.calls.length, callsBefore);

    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(repo.calls.length, callsBefore + 1);
    // q ter-trim sebelum sampai repo (dilakukan use case).
    expect(repo.calls.last.q, 'ke');
    expect(container.read(wordListProvider).isLoading, false);
    sub.close();
  });

  test('gagal → errorMessage terisi, tidak throw, item lama tetap', () async {
    final repo = _FakeDictionaryRepository();
    final container = ProviderContainer(
      overrides: [dictionaryRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final sub = container.listen(wordListProvider, (_, _) {});
    await _flush();

    repo.failNext = true;
    await container.read(wordListProvider.notifier).load();

    final state = container.read(wordListProvider);
    expect(state.errorMessage, 'gagal memuat');
    expect(state.isLoading, false);
    sub.close();
  });

  test(
    'empty: unsubscribe+resubscribe tidak stuck loading (keepAlive)',
    () async {
      final repo = _FakeDictionaryRepository()..empty = true;
      final container = ProviderContainer(
        overrides: [dictionaryRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      var sub = container.listen(wordListProvider, (_, _) {});
      await _flush();
      expect(container.read(wordListProvider).isLoading, false);
      expect(container.read(wordListProvider).items, isEmpty);
      final callsAfterFirst = repo.calls.length;

      sub.close();
      await _flush();

      sub = container.listen(wordListProvider, (_, _) {});
      await _flush();
      expect(container.read(wordListProvider).isLoading, false);
      expect(container.read(wordListProvider).items, isEmpty);
      // keepAlive: tidak refetch hanya karena listener hilang/kembali
      expect(repo.calls.length, callsAfterFirst);
      sub.close();
    },
  );

  test(
    'onQueryChanged empty idle tidak refetch (hindari remount loop)',
    () async {
      final repo = _FakeDictionaryRepository()..empty = true;
      final container = ProviderContainer(
        overrides: [dictionaryRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final sub = container.listen(wordListProvider, (_, _) {});
      await _flush();
      final callsBefore = repo.calls.length;

      container.read(wordListProvider.notifier).onQueryChanged('');
      await _flush();

      expect(repo.calls.length, callsBefore);
      expect(container.read(wordListProvider).isLoading, false);
      sub.close();
    },
  );

  test('saringan Sambas kosong memanggil search lemma', () async {
    final repo = _FakeDictionaryRepository()..empty = true;
    final container = ProviderContainer(
      overrides: [dictionaryRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final sub = container.listen(wordListProvider, (_, _) {});
    await _flush();

    container.read(wordListProvider.notifier).onQueryChanged('ketex');
    await Future<void>.delayed(const Duration(milliseconds: 500));

    expect(repo.searchCalls, hasLength(1));
    expect(repo.searchCalls.single.searchIn, 'lemma');
    expect(repo.searchCalls.single.query, 'ketex');
    expect(container.read(wordListProvider).items, isEmpty);
    expect(container.read(wordListProvider).viaSearch, isTrue);
    sub.close();
  });

  test('saringan kosong yang cocok variasi menampilkan hasil search', () async {
    final repo = _FakeDictionaryRepository()
      ..empty = true
      ..searchReturnsVariant = true;
    final container = ProviderContainer(
      overrides: [dictionaryRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final sub = container.listen(wordListProvider, (_, _) {});
    await _flush();

    container.read(wordListProvider.notifier).onQueryChanged('ketex');
    await Future<void>.delayed(const Duration(milliseconds: 500));

    expect(container.read(wordListProvider).items.map((w) => w.lemma), [
      'ketek',
    ]);
    expect(container.read(wordListProvider).viaSearch, isTrue);
    sub.close();
  });

  test(
    'mode Indonesia memakai search translation, q kosong tidak fetch',
    () async {
      final repo = _FakeDictionaryRepository();
      final container = ProviderContainer(
        overrides: [dictionaryRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final sub = container.listen(wordListProvider, (_, _) {});
      await _flush();
      final listCalls = repo.calls.length;

      container
          .read(wordListProvider.notifier)
          .onSearchInChanged('translation');
      await _flush();

      expect(repo.calls.length, listCalls);
      expect(repo.searchCalls, isEmpty);
      expect(container.read(wordListProvider).isLoading, isFalse);
      expect(container.read(wordListProvider).items, isEmpty);

      container.read(wordListProvider.notifier).onQueryChanged('makan');
      await Future<void>.delayed(const Duration(milliseconds: 500));

      expect(repo.searchCalls, hasLength(1));
      expect(repo.searchCalls.single.searchIn, 'translation');
      expect(repo.searchCalls.single.query, 'makan');
      expect(repo.calls.length, listCalls);
      sub.close();
    },
  );
}
