import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/event_comment.dart';
import 'event_providers.dart';

class EventCommentListState {
  const EventCommentListState({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isSubmitting = false,
  });

  final List<EventComment> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isSubmitting;

  EventCommentListState copyWith({
    List<EventComment>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isSubmitting,
    bool clearNextCursor = false,
  }) {
    return EventCommentListState(
      items: items ?? this.items,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// List + mutasi komentar acara (flow sama komentar ensiklopedia).
final eventCommentListControllerProvider = AsyncNotifierProvider.autoDispose
    .family<EventCommentListController, EventCommentListState, String>(
  EventCommentListController.new,
);

class EventCommentListController
    extends AsyncNotifier<EventCommentListState> {
  EventCommentListController(this.eventId);

  final String eventId;
  static const _pageSize = 20;

  @override
  Future<EventCommentListState> build() async {
    final page = await ref
        .watch(eventRepositoryProvider)
        .getComments(eventId, limit: _pageSize);
    if (!ref.mounted) {
      return const EventCommentListState(items: []);
    }
    return EventCommentListState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
  }

  Future<String?> create(String body) async {
    final current = state.value;
    if (current == null || current.isSubmitting) return null;
    final trimmed = body.trim();
    if (trimmed.isEmpty) return 'empty';

    state = AsyncData(current.copyWith(isSubmitting: true));
    try {
      final comment = await ref
          .read(eventRepositoryProvider)
          .postComment(eventId, trimmed);
      if (!ref.mounted) return null;
      if (comment == null) {
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

  Future<String?> updateComment(EventComment comment, String body) async {
    final current = state.value;
    if (current == null) return 'failed';
    final trimmed = body.trim();
    if (trimmed.isEmpty) return 'empty';

    try {
      final updated = await ref
          .read(eventRepositoryProvider)
          .updateComment(comment.id, trimmed);
      if (!ref.mounted) return null;
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

  Future<String?> delete(EventComment comment) async {
    final current = state.value;
    if (current == null) return 'failed';
    try {
      await ref.read(eventRepositoryProvider).deleteComment(comment.id);
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
      final page = await ref.read(eventRepositoryProvider).getComments(
            eventId,
            limit: _pageSize,
            cursor: current.nextCursor,
          );
      if (!ref.mounted) return;
      final more = page.items;
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
                nextCursor: page.nextCursor,
                hasMore: page.hasMore,
                isLoadingMore: false,
                clearNextCursor: page.nextCursor == null,
              ),
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}
