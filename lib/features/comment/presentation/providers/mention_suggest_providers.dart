import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/utils/parse_mentions.dart';
import '../../../user_profile/domain/entities/public_profile.dart';
import '../../../user_profile/domain/providers/user_profile_domain_providers.dart';

part 'mention_suggest_providers.g.dart';

/// State autocomplete mention: kandidat + query aktif.
class MentionSuggestState {
  const MentionSuggestState({
    this.items = const [],
    this.query = '',
    this.isLoading = false,
  });

  final List<MentionSuggestion> items;
  final String query;
  final bool isLoading;

  bool get isVisible => query.length >= 2 && items.isNotEmpty;

  MentionSuggestState copyWith({
    List<MentionSuggestion>? items,
    String? query,
    bool? isLoading,
  }) =>
      MentionSuggestState(
        items: items ?? this.items,
        query: query ?? this.query,
        isLoading: isLoading ?? this.isLoading,
      );
}

/// Autocomplete mention @username: debounce 300ms, hanya query >= 2 char.
/// Gagal fetch = diam (suggestion disembunyikan), bukan error block.
/// Race condition: cancel request sebelumnya via AbortController.
@riverpod
class MentionSuggestController extends _$MentionSuggestController {
  Timer? _debounce;
  static const _debounceDuration = Duration(milliseconds: 300);
  _AbortController _abortController = _AbortController();

  @override
  MentionSuggestState build() {
    ref.onDispose(() {
      _debounce?.cancel();
      _abortController.cancel();
    });
    return const MentionSuggestState();
  }

  /// Dipanggil tiap perubahan teks composer.
  void onTextChanged(String text, int cursor) {
    final active = parseMentionCandidates(text, cursor: cursor).firstOrNull;
    if (active == null || active.length < 2) {
      _debounce?.cancel();
      _abortController.cancel();
      state = const MentionSuggestState();
      return;
    }
    _debounce?.cancel();
    _abortController.cancel();
    _abortController = _AbortController();
    _debounce = Timer(_debounceDuration, () => _fetch(active, _abortController.signal));
    state = state.copyWith(query: active, isLoading: true);
  }

  Future<void> _fetch(String query, _AbortSignal signal) async {
    if (signal.aborted) return;
    final result = await ref.read(suggestMentionsUseCaseProvider)(query);
    if (signal.aborted) return;
    result.match(
      (failure) {
        // Diam: suggestion disembunyikan saat gagal (rate limit / offline).
        if (state.query == query) {
          state = MentionSuggestState(query: query);
        }
      },
      (items) {
        if (state.query == query) {
          state = MentionSuggestState(items: items, query: query);
        }
      },
    );
  }

  /// Tutup suggestion (mis. setelah insert atau submit).
  void dismiss() {
    _debounce?.cancel();
    _abortController.cancel();
    state = const MentionSuggestState();
  }
}

/// Simple AbortController port (stdlib - no deps).
class _AbortController {
  _AbortSignal _signal = _AbortSignal();

  _AbortSignal get signal => _signal;

  void cancel() {
    _signal = _AbortSignal(aborted: true);
  }
}

class _AbortSignal {
  final bool aborted;

  _AbortSignal({this.aborted = false});

  bool get isAborted => aborted;
}
