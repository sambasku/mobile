import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/encyclopedia_providers.dart';
import '../../domain/encyclopedia.entity.dart';

class ArticleCommentListState {
  const ArticleCommentListState({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isSubmitting = false,
  });

  final List<ArticleComment> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isSubmitting;

  ArticleCommentListState copyWith({
    List<ArticleComment>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isSubmitting,
    bool clearNextCursor = false,
  }) {
    return ArticleCommentListState(
      items: items ?? this.items,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// List + mutasi komentar artikel (flow sama komentar lemma).
final articleCommentListControllerProvider = AsyncNotifierProvider.autoDispose
    .family<ArticleCommentListController, ArticleCommentListState, String>(
      ArticleCommentListController.new,
    );

class ArticleCommentListController
    extends AsyncNotifier<ArticleCommentListState> {
  ArticleCommentListController(this.articleId);

  final String articleId;
  static const _pageSize = 20;

  @override
  Future<ArticleCommentListState> build() async {
    final resp = await ref
        .watch(encyclopediaRepositoryProvider)
        .getComments(articleId, {'limit': _pageSize});
    if (!ref.mounted) {
      return const ArticleCommentListState(items: []);
    }
    final page = resp.data;
    return ArticleCommentListState(
      items: page?.items ?? const [],
      nextCursor: page?.nextCursor,
      hasMore: page?.hasMore ?? false,
    );
  }

  Future<String?> create(String body) async {
    final current = state.value;
    if (current == null || current.isSubmitting) return null;
    final trimmed = body.trim();
    if (trimmed.isEmpty) return 'empty';

    state = AsyncData(current.copyWith(isSubmitting: true));
    try {
      final resp = await ref
          .read(encyclopediaRepositoryProvider)
          .postComment(articleId, {'body': trimmed});
      if (!ref.mounted) return null;
      if (resp.data == null) {
        state = AsyncData(current.copyWith(isSubmitting: false));
        return 'failed';
      }
      ref.invalidateSelf();
      return null;
    } catch (_) {
      if (!ref.mounted) return null;
      state = AsyncData(current.copyWith(isSubmitting: false));
      return 'failed';
    }
  }

  Future<String?> updateComment(ArticleComment comment, String body) async {
    final current = state.value;
    if (current == null) return 'failed';
    final trimmed = body.trim();
    if (trimmed.isEmpty) return 'empty';

    try {
      final resp = await ref
          .read(encyclopediaRepositoryProvider)
          .updateComment(comment.id, {'body': trimmed});
      if (!ref.mounted) return null;
      final updated = resp.data;
      if (updated == null) return 'failed';
      state = AsyncData(
        current.copyWith(
          items: [
            for (final c in current.items)
              if (c.id == updated.id) updated else c,
          ],
        ),
      );
      return null;
    } catch (_) {
      return 'failed';
    }
  }

  Future<String?> delete(ArticleComment comment) async {
    final current = state.value;
    if (current == null) return 'failed';
    try {
      await ref.read(encyclopediaRepositoryProvider).deleteComment(comment.id);
      if (!ref.mounted) return null;
      state = AsyncData(
        current.copyWith(
          items: [
            for (final c in current.items)
              if (c.id != comment.id) c,
          ],
        ),
      );
      return null;
    } catch (_) {
      return 'failed';
    }
  }

  Future<void> loadMore() async {
    if (!ref.mounted) return;
    final current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.nextCursor == null) {
      return;
    }
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final resp = await ref
          .read(encyclopediaRepositoryProvider)
          .getComments(articleId, {
            'limit': _pageSize,
            'cursor': current.nextCursor,
          });
      if (!ref.mounted) return;
      final page = resp.data;
      final more = page?.items ?? const <ArticleComment>[];
      final s = state.value ?? current;
      state = AsyncData(
        more.isEmpty
            ? s.copyWith(
                isLoadingMore: false,
                hasMore: false,
                clearNextCursor: true,
              )
            : s.copyWith(
                items: [...s.items, ...more],
                nextCursor: page?.nextCursor,
                hasMore: page?.hasMore ?? false,
                isLoadingMore: false,
                clearNextCursor: page?.nextCursor == null,
              ),
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}
