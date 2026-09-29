import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../vote/domain/providers/vote_domain_providers.dart';
import '../../domain/entities/word_comment.dart';
import '../../domain/failures/comment_failure.dart';
import '../../domain/providers/comment_domain_providers.dart';
import '../models/comment_list_state.dart';

part 'comment_providers.g.dart';

/// State list komentar per kata (1 keluarga = 1 wordId). Load halaman
/// pertama; saat login, seed `myVote` per komentar dari GET /votes/my
/// (satu request batch, bukan N+1). Method mutasi (create/delete/loadMore)
/// meng-update state in-place dan mengembalikan `CommentFailure?` agar
/// widget bisa menampilkan toast.
@riverpod
class CommentListController extends _$CommentListController {
  static const _pageSize = 20;

  @override
  FutureOr<CommentListState> build(String wordId) async {
    final result = await ref.watch(listWordCommentsUseCaseProvider)(
      wordId: wordId,
      limit: _pageSize,
    );
    final page = result.match((failure) => throw failure, (page) => page);

    final items = await _attachMyVotes(page.items);

    return CommentListState(
      items: items,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
  }

  /// Seed myVote per komentar (batch) saat login; gagal = bukan blocker
  /// (tombol tampil tanpa state aktif, toggle tetap jalan).
  Future<List<WordComment>> _attachMyVotes(List<WordComment> items) async {
    if (items.isEmpty) return items;

    final auth = await ref.watch(authStatusProvider.future);
    if (!auth.isAuth) return items;

    final mine = await ref.watch(getMyVotesUseCaseProvider)(
      items.map((c) => c.voteTarget).toList(growable: false),
    );
    return mine.match(
      (failure) => items,
      (map) => items
          .map(
            (c) => map.containsKey(c.voteTarget.key)
                ? c.copyWith(myVote: map[c.voteTarget.key])
                : c,
          )
          .toList(growable: false),
    );
  }

  Future<CommentFailure?> toggleVote(WordComment comment, int value) async {
    final current = state.value;
    if (current == null) {
      return const CommentFailure('Komentar belum dimuat');
    }

    final result =
        await ref.watch(toggleVoteUseCaseProvider)(target: comment.voteTarget, value: value);
    return result.match(
      (failure) => CommentFailure(failure.message, errorCode: failure.errorCode),
      (view) {
        final updated = comment.copyWith(
          upvotes: view.upvotes,
          downvotes: view.downvotes,
          myVote: view.myVote,
        );
        state = AsyncData(
          current.copyWith(
            items: [
              for (final c in current.items)
                c.voteTarget.key == updated.voteTarget.key ? updated : c,
            ],
          ),
        );
        return null;
      },
    );
  }

  /// Kirim komentar - langsung published; invalidate list agar sync API.
  Future<CommentFailure?> create(String body) async {
    final current = state.value;
    if (current == null) return null;
    if (current.isSubmitting) return null;
    if (body.trim().isEmpty) {
      return const CommentFailure('Komentar tidak boleh kosong');
    }

    state = AsyncData(current.copyWith(isSubmitting: true, clearSubmitFailure: true));

    final result =
        await ref.watch(createCommentUseCaseProvider)(wordId: wordId, body: body);
    return result.match(
      (failure) {
        final s = state.value ?? current;
        state = AsyncData(s.copyWith(isSubmitting: false, submitFailure: failure));
        return failure;
      },
      (_) {
        // Invalidate container: refetch list (status/body akurat dari server).
        ref.invalidateSelf();
        AnalyticsService.instance.log(
          AnalyticsEvents.commentSubmit,
          params: {'word_id': wordId},
        );
        return null;
      },
    );
  }

  /// Kirim komentar suara; caption teks opsional.
  Future<CommentFailure?> createAudio({
    required File audioFile,
    required int durationMs,
    String? body,
  }) async {
    final current = state.value;
    if (current == null) return null;
    if (current.isSubmitting) return null;

    state = AsyncData(current.copyWith(isSubmitting: true, clearSubmitFailure: true));

    final result = await ref.watch(createCommentAudioUseCaseProvider)(
      wordId: wordId,
      audioFile: audioFile,
      durationMs: durationMs,
      body: body,
    );
    return result.match(
      (failure) {
        final s = state.value ?? current;
        state = AsyncData(s.copyWith(isSubmitting: false, submitFailure: failure));
        return failure;
      },
      (_) {
        ref.invalidateSelf();
        AnalyticsService.instance.log(
          AnalyticsEvents.commentSubmit,
          params: {'word_id': wordId, 'has_audio': '1'},
        );
        return null;
      },
    );
  }

  Future<CommentFailure?> delete(WordComment comment) async {
    final current = state.value;
    if (current == null) return null;

    final result = await ref.watch(deleteCommentUseCaseProvider)(comment.id);
    return result.match(
      (failure) => failure,
      (_) {
        final s = state.value ?? current;
        // Tetap di list: tandai deleted_by_author (placeholder di UI).
        state = AsyncData(
          s.copyWith(
            items: [
              for (final c in s.items)
                c.id == comment.id
                    ? c.copyWith(status: 'deleted_by_author', body: null)
                    : c,
            ],
          ),
        );
        return null;
      },
    );
  }

  Future<CommentFailure?> loadMore() async {
    final current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.nextCursor == null) {
      return null;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final result = await ref.watch(listWordCommentsUseCaseProvider)(
      wordId: wordId,
      limit: _pageSize,
      cursor: current.nextCursor,
    );
    return result.match(
      (failure) {
        final s = state.value ?? current;
        state = AsyncData(s.copyWith(isLoadingMore: false));
        return failure;
      },
      (page) async {
        final s = state.value ?? current;
        final merged = [...s.items, ...await _attachMyVotes(page.items)];
        state = AsyncData(
          s.copyWith(
            isLoadingMore: false,
            items: merged,
            nextCursor: page.nextCursor,
            hasMore: page.hasMore,
          ),
        );
        return null;
      },
    );
  }
}