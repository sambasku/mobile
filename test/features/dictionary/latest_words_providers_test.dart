import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/features/dictionary/data/providers/dictionary_data_providers.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_of_day.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_summary.dart';
import 'package:sambasku_mobile/features/dictionary/domain/failures/dictionary_failure.dart';
import 'package:sambasku_mobile/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/providers/latest_words_providers.dart';

WordSummary _word(String lemma) => WordSummary(
  id: lemma.padRight(26, '0'),
  lemma: lemma,
  languageCode: 'SBS',
  wordType: 'word',
  status: 'published',
  isVerified: true,
  sense: 'arti $lemma',
  approvedAt: DateTime.utc(2026, 9, 1),
);

class _FakeDictionaryRepository implements DictionaryRepository {
  final calls = <String?>[];
  bool failNext = false;
  int freshLoads = 0;
  Completer<Either<DictionaryFailure, WordSearchPage>>? pendingCursor;

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> listLatest({
    required int limit,
    String? cursor,
    bool forceRefresh = false,
  }) async {
    calls.add(cursor);
    if (failNext) {
      failNext = false;
      return Either.left(const DictionaryFailure('gagal memuat'));
    }
    if (cursor != null) {
      final gate = pendingCursor;
      if (gate != null) return gate.future;
    }
    if (cursor == null) {
      freshLoads++;
      if (freshLoads > 1) {
        return Either.right(
          WordSearchPage(
            items: [_word('baru')],
            nextCursor: null,
            hasMore: false,
          ),
        );
      }
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
  Future<Either<DictionaryFailure, WordSearchPage>> listWords({
    required String q,
    required int limit,
    String? category,
    String? cursor,
    String? letter,
    bool? isVerified,
  }) async => throw UnimplementedError();

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
  }) async => throw UnimplementedError();
}

Future<void> _flush() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test('build memuat halaman 1; loadMore menggabungkan halaman 2', () async {
    final repo = _FakeDictionaryRepository();
    final container = ProviderContainer(
      overrides: [dictionaryRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final sub = container.listen(latestWordsProvider, (_, _) {});
    await _flush();

    var state = container.read(latestWordsProvider);
    expect(state.isLoading, false);
    expect(state.items.map((w) => w.lemma), ['apam', 'budu']);
    expect(state.items.first.sense, 'arti apam');
    expect(state.nextCursor, 'page-2');
    expect(state.hasMore, true);
    expect(repo.calls.single, isNull);

    await container.read(latestWordsProvider.notifier).loadMore();
    state = container.read(latestWordsProvider);
    expect(state.items.map((w) => w.lemma), ['apam', 'budu', 'capai']);
    expect(state.hasMore, false);
    expect(state.nextCursor, isNull);
    expect(repo.calls.last, 'page-2');
    sub.close();
  });

  test('gagal → errorMessage terisi, item lama tetap', () async {
    final repo = _FakeDictionaryRepository();
    final container = ProviderContainer(
      overrides: [dictionaryRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final sub = container.listen(latestWordsProvider, (_, _) {});
    await _flush();

    repo.failNext = true;
    await container.read(latestWordsProvider.notifier).load();

    final state = container.read(latestWordsProvider);
    expect(state.errorMessage, 'gagal memuat');
    expect(state.isLoading, false);
    expect(state.items.map((w) => w.lemma), ['apam', 'budu']);
    sub.close();
  });

  test('load membatalkan loadMore yang masih berjalan', () async {
    final repo = _FakeDictionaryRepository();
    final container = ProviderContainer(
      overrides: [dictionaryRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final sub = container.listen(latestWordsProvider, (_, _) {});
    await _flush();

    repo.pendingCursor = Completer();
    final more = container.read(latestWordsProvider.notifier).loadMore();
    await Future<void>.delayed(Duration.zero);

    await container.read(latestWordsProvider.notifier).load();
    repo.pendingCursor!.complete(
      Either.right(
        WordSearchPage(
          items: [_word('capai')],
          nextCursor: null,
          hasMore: false,
        ),
      ),
    );
    await more;

    final state = container.read(latestWordsProvider);
    expect(state.items.map((w) => w.lemma), ['baru']);
    expect(state.isLoadingMore, isFalse);
    expect(state.isLoading, isFalse);
    sub.close();
  });
}
