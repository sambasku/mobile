import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_of_day.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_summary.dart';
import 'package:sambasku_mobile/features/dictionary/domain/failures/dictionary_failure.dart';
import 'package:sambasku_mobile/features/dictionary/domain/providers/dictionary_domain_providers.dart';
import 'package:sambasku_mobile/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:sambasku_mobile/features/dictionary/domain/usecases/search_words_use_case.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/providers/word_complete_providers.dart';

void main() {
  group('WordCompleteNotifier', () {
    late ProviderContainer container;
    late _FakeDictionaryRepository repo;

    setUp(() {
      repo = _FakeDictionaryRepository();
      container = ProviderContainer(
        overrides: [
          searchWordsUseCaseProvider.overrideWithValue(SearchWordsUseCase(repo)),
        ],
      );
      // Provider auto-dispose: tanpa listener ia dibuang setelah tiap read,
      // sehingga timer debounce mati sebelum sempat fetch. Pegang subscription
      // selama test - sama seperti lifecycle di widget.
      container.listen(wordCompleteProvider, (_, _) {});
    });

    tearDown(() => container.dispose());

    WordCompleteState state() => container.read(wordCompleteProvider);

    test('di bawah 2 karakter: tidak fetch, tidak loading, hasil dikosongkan', () {
      state();
      container
          .read(wordCompleteProvider.notifier)
          .onQueryChanged('a');

      expect(repo.calls, isEmpty);
      expect(state().isLoading, isFalse);
      expect(state().isSearching, isFalse);
      expect(state().items, isEmpty);
    });

    test('ketik cepat berulang: hanya query terakhir yang di-fetch', () async {
      state();
      final notifier = container.read(wordCompleteProvider.notifier);

      // Satu burst cepat, seperti mengetik dengan benar.
      notifier.onQueryChanged('ba');
      notifier.onQueryChanged('baka');
      notifier.onQueryChanged('bakat');
      await _settle();

      expect(repo.calls, hasLength(1));
      expect(repo.calls.single.query, 'bakat');
      expect(state().items.single.lemma, 'bakat');
      expect(state().isLoading, isFalse);
    });

    test('trims spasi dandukung searchIn lemma', () async {
      state();
      container.read(wordCompleteProvider.notifier).onQueryChanged('  baka  ');
      await _settle();

      expect(repo.calls.single.query, 'baka');
      expect(repo.calls.single.searchIn, 'lemma');
      expect(repo.calls.single.limit, 20);
    });

    test('jawaban request lama tidak menimpa query baru', () async {
      state();
      final notifier = container.read(wordCompleteProvider.notifier);

      // Request 'lama'故意 dibuat lambat, 'baru' cepat resolving.
      repo.holdQuery = 'lama';
      notifier.onQueryChanged('lama');
      await _settle();

      repo.holdQuery = null;
      notifier.onQueryChanged('baru');
      await _settle();
      expect(state().items.single.lemma, 'baru');

      // Sekarang 'lama' baru selesai - harus diabaikan, bukan menimpa.
      repo.releaseHeld();
      await _settle();

      expect(state().items.single.lemma, 'baru');
      expect(state().isLoading, isFalse);
    });

    test('kembalikan query pendek: hasil lama dibuang, tidak ada request', () {
      state();
      final notifier = container.read(wordCompleteProvider.notifier);

      notifier.onQueryChanged('bakat');
      expect(state().items, isEmpty);

      notifier.onQueryChanged('b');
      final callCount = repo.calls.length;

      expect(state().items, isEmpty);
      expect(state().isLoading, isFalse);
      expect(repo.calls, hasLength(callCount));
    });

    test('gagal: pesan error tampil, bukan state kosong', () async {
      state();
      repo.error = true;
      container.read(wordCompleteProvider.notifier).onQueryChanged('bakat');
      await _settle();

      expect(state().isLoading, isFalse);
      expect(state().errorMessage, isNotNull);
    });
  });
}

/// Tunggu jendela debounce (400ms) + microtask completion.
Future<void> _settle() async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
}

class _FakeDictionaryRepository implements DictionaryRepository {
  /// Semua query yang benar-benar sampai ke repository.
  final calls = <({String query, int limit, String searchIn})>[];

  /// Query yang harus ditahan sampai [releaseHeld] dipanggil.
  String? holdQuery;

  /// Menahan [holdQuery] dalam scope test, dilepas eksplisit.
  void releaseHeld() {
    holdQuery = null;
    for (final controller in _pending) {
      if (!controller.isCompleted) controller.complete();
    }
    _pending.clear();
  }

  final _pending = <Completer<void>>[];

  bool error = false;

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> searchWords({
    required String query,
    required int limit,
    String? cursor,
    String searchIn = 'lemma',
  }) async {
    calls.add((query: query, limit: limit, searchIn: searchIn));

    if (error) {
      return Either.left(const DictionaryFailure('Gagal memuat kata'));
    }

    if (query == holdQuery) {
      final gate = Completer<void>();
      _pending.add(gate);
      await gate.future;
    }

    return Either.right(
      WordSearchPage(
        items: [
          WordSummary(
            id: 'id-$query',
            lemma: query,
            languageCode: 'snb',
            wordType: 'noun',
            status: 'published',
            isVerified: true,
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
    String? category,
    String? cursor,
    String? letter,
    bool? isVerified,
  }) => throw UnimplementedError();

  @override
  Future<Either<DictionaryFailure, List<WordCategory>>> listCategories() async =>
      const Right(<WordCategory>[]);

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> listLatest({
    required int limit,
    String? cursor,
    bool forceRefresh = false,
  }) => throw UnimplementedError();
}
