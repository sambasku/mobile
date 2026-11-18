import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/network/network_providers.dart';
import '../../features/comment/domain/entities/comment_image.dart';
import 'entity_comment.dart';
import 'entity_comment_api.dart';

final entityCommentApiProvider = Provider<EntityCommentApi>(
  (ref) => EntityCommentApi(ref.watch(dioProvider)),
);

class EntityCommentListKey {
  const EntityCommentListKey(this.target, this.entityId);

  final EntityCommentTarget target;
  final String entityId;

  @override
  bool operator ==(Object other) =>
      other is EntityCommentListKey &&
      other.target == target &&
      other.entityId == entityId;

  @override
  int get hashCode => Object.hash(target, entityId);
}

class EntityCommentListState {
  const EntityCommentListState({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isSubmitting = false,
  });

  final List<EntityComment> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isSubmitting;

  EntityCommentListState copyWith({
    List<EntityComment>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isSubmitting,
    bool clearNextCursor = false,
  }) {
    return EntityCommentListState(
      items: items ?? this.items,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

final entityCommentListControllerProvider = AsyncNotifierProvider.autoDispose
    .family<EntityCommentListController, EntityCommentListState,
        EntityCommentListKey>(
  EntityCommentListController.new,
);

class EntityCommentListController
    extends AsyncNotifier<EntityCommentListState> {
  EntityCommentListController(this.key);

  final EntityCommentListKey key;
  static const _pageSize = 20;

  @override
  Future<EntityCommentListState> build() async {
    final page = await ref.watch(entityCommentApiProvider).list(
          key.target,
          key.entityId,
          limit: _pageSize,
        );
    if (!ref.mounted) {
      return const EntityCommentListState(items: []);
    }
    return EntityCommentListState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
  }

  Future<String?> create(
    String body, {
    CommentImageStaging? image,
    String? stickerId,
  }) async {
    final current = state.value;
    if (current == null || current.isSubmitting) return null;
    final trimmed = body.trim();
    final sticker = stickerId?.trim();
    final hasSticker = sticker != null && sticker.isNotEmpty;
    if (trimmed.isEmpty && image == null && !hasSticker) return 'empty';

    state = AsyncData(current.copyWith(isSubmitting: true));
    try {
      await ref.read(entityCommentApiProvider).create(
            key.target,
            key.entityId,
            body: trimmed,
            image: image,
            stickerId: hasSticker ? sticker : null,
          );
      if (!ref.mounted) return null;
      ref.invalidateSelf();
      return null;
    } catch (_) {
      if (!ref.mounted) return null;
      state = AsyncData(current.copyWith(isSubmitting: false));
      return 'failed';
    }
  }

  Future<String?> createAudio({
    required File audioFile,
    required int durationMs,
    String? body,
  }) async {
    final current = state.value;
    if (current == null || current.isSubmitting) return null;
    state = AsyncData(current.copyWith(isSubmitting: true));
    try {
      await ref.read(entityCommentApiProvider).createAudio(
            key.target,
            key.entityId,
            audioFile: audioFile,
            durationMs: durationMs,
            body: body,
          );
      if (!ref.mounted) return null;
      ref.invalidateSelf();
      return null;
    } catch (_) {
      if (!ref.mounted) return null;
      state = AsyncData(current.copyWith(isSubmitting: false));
      return 'failed';
    }
  }

  Future<String?> updateComment(EntityComment comment, String body) async {
    final current = state.value;
    if (current == null) return 'failed';
    final trimmed = body.trim();
    if (trimmed.isEmpty) return 'empty';
    try {
      final updated = await ref.read(entityCommentApiProvider).update(
            key.target,
            comment.id,
            trimmed,
          );
      if (!ref.mounted) return null;
      final items = [
        for (final item in current.items)
          if (item.id == comment.id) updated else item,
      ];
      state = AsyncData(current.copyWith(items: items));
      return null;
    } catch (_) {
      return 'failed';
    }
  }

  Future<String?> deleteComment(EntityComment comment) async {
    final current = state.value;
    if (current == null) return 'failed';
    try {
      await ref.read(entityCommentApiProvider).delete(key.target, comment.id);
      if (!ref.mounted) return null;
      ref.invalidateSelf();
      return null;
    } catch (_) {
      return 'failed';
    }
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.nextCursor == null) {
      return;
    }
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final page = await ref.read(entityCommentApiProvider).list(
            key.target,
            key.entityId,
            cursor: current.nextCursor,
            limit: _pageSize,
          );
      if (!ref.mounted) return;
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...page.items],
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
