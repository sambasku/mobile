import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/word_summary.dart';
import '../../domain/providers/dictionary_domain_providers.dart';
import '../../domain/usecases/list_words_use_case.dart';
import '../models/letter_words_state.dart';

part 'letter_words_providers.g.dart';

const kAlphabetLetters = 'abcdefghijklmnopqrstuvwxyz';

/// Normalisasi param route ke satu huruf a-z, atau null jika tidak valid.
String? normalizeLetterParam(String raw) {
  final trimmed = raw.trim();
  if (!RegExp(r'^[A-Za-z]$').hasMatch(trimmed)) return null;
  return trimmed.toLowerCase();
}

/// Browse kata per huruf (setara web `/huruf/:letter`).
/// Family per huruf supaya state A tidak bentrok dengan B.
@Riverpod(keepAlive: true)
class LetterWordsNotifier extends _$LetterWordsNotifier {
  int _loadReqId = 0;
  int _loadMoreReqId = 0;
  bool _isLoadingSync = false;
  bool _isLoadingMoreSync = false;

  @override
  LetterWordsState build(String letter) {
    ref.onResume(() {
      scheduleMicrotask(() {
        if (!ref.mounted) return;
        if (state.isLoading && !_isLoadingSync) {
          load();
        }
      });
    });

    scheduleMicrotask(load);
    return const LetterWordsState(isLoading: true);
  }

  Future<void> load() async {
    if (_isLoadingSync) return;
    _isLoadingSync = true;
    final reqId = ++_loadReqId;
    _loadMoreReqId++;

    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      items: const [],
      clearNextCursor: true,
      hasMore: false,
      clearErrorMessage: true,
    );

    try {
      final result = await ref.read(listWordsUseCaseProvider)(
        ListWordsParams(
          q: '',
          letter: letter,
          isVerified: true,
          limit: 50,
        ),
      );

      if (!ref.mounted || reqId != _loadReqId) return;

      result.match(
        (failure) => state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ),
        (page) => state = state.copyWith(
          isLoading: false,
          items: page.items,
          nextCursor: page.nextCursor,
          clearNextCursor: page.nextCursor == null,
          hasMore: page.hasMore,
        ),
      );
    } catch (e) {
      if (ref.mounted && reqId == _loadReqId) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        );
      }
    } finally {
      if (reqId == _loadReqId) {
        _isLoadingSync = false;
      }
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMoreSync ||
        _isLoadingSync ||
        !ref.mounted ||
        state.isLoading ||
        state.isLoadingMore ||
        !state.hasMore ||
        state.nextCursor == null) {
      return;
    }
    _isLoadingMoreSync = true;
    final reqId = ++_loadMoreReqId;

    state = state.copyWith(isLoadingMore: true, clearErrorMessage: true);

    try {
      final result = await ref.read(listWordsUseCaseProvider)(
        ListWordsParams(
          q: '',
          letter: letter,
          isVerified: true,
          limit: 50,
          cursor: state.nextCursor,
        ),
      );

      if (!ref.mounted || reqId != _loadMoreReqId) return;

      result.match(
        (failure) => state = state.copyWith(
          isLoadingMore: false,
          errorMessage: failure.message,
        ),
        (page) {
          final merged = <WordSummary>[...state.items, ...page.items];
          state = state.copyWith(
            isLoadingMore: false,
            items: merged,
            nextCursor: page.nextCursor,
            clearNextCursor: page.nextCursor == null,
            hasMore: page.hasMore,
          );
        },
      );
    } catch (e) {
      if (ref.mounted && reqId == _loadMoreReqId) {
        state = state.copyWith(
          isLoadingMore: false,
          errorMessage: e.toString(),
        );
      }
    } finally {
      if (reqId == _loadMoreReqId) {
        _isLoadingMoreSync = false;
      }
    }
  }
}
