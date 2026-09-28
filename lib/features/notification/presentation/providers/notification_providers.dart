import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/entities/inbox_notification.dart';
import '../../domain/failures/notification_failure.dart';
import '../../domain/providers/notification_domain_providers.dart';
import '../models/notification_inbox_state.dart';

part 'notification_providers.g.dart';

@Riverpod(keepAlive: true)
class NotificationInboxListController extends _$NotificationInboxListController {
  static const _pageSize = 20;

  @override
  Future<NotificationInboxState> build() async {
    final auth = ref.watch(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) return const NotificationInboxState();

    final result = await ref.watch(listMyNotificationsUseCaseProvider)(
      limit: _pageSize,
    );
    final page = result.match((failure) => throw failure, (page) => page);
    return NotificationInboxState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
  }

  Future<NotificationFailure?> loadMore() async {
    final current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.nextCursor == null) {
      return null;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final result = await ref.watch(listMyNotificationsUseCaseProvider)(
      limit: _pageSize,
      cursor: current.nextCursor,
    );
    return result.match(
      (failure) {
        final s = state.value ?? current;
        state = AsyncData(s.copyWith(isLoadingMore: false));
        return failure;
      },
      (page) {
        final s = state.value ?? current;
        state = AsyncData(
          s.copyWith(
            isLoadingMore: false,
            items: [...s.items, ...page.items],
            nextCursor: page.nextCursor,
            hasMore: page.hasMore,
          ),
        );
        return null;
      },
    );
  }

  void markLocalRead(String id) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: [
          for (final item in current.items)
            if (item.id == id)
              InboxNotification(
                id: item.id,
                type: item.type,
                title: item.title,
                body: item.body,
                targetKind: item.targetKind,
                targetId: item.targetId,
                createdAt: item.createdAt,
                readAt: DateTime.now().toUtc().toIso8601String(),
                actionKind: item.actionKind,
                actionValue: item.actionValue,
              )
            else
              item,
        ],
      ),
    );
  }

  void markAllLocalRead() {
    final current = state.value;
    if (current == null) return;
    final now = DateTime.now().toUtc().toIso8601String();
    state = AsyncData(
      current.copyWith(
        items: [
          for (final item in current.items)
            if (item.isUnread)
              InboxNotification(
                id: item.id,
                type: item.type,
                title: item.title,
                body: item.body,
                targetKind: item.targetKind,
                targetId: item.targetId,
                createdAt: item.createdAt,
                readAt: now,
                actionKind: item.actionKind,
                actionValue: item.actionValue,
              )
            else
              item,
        ],
      ),
    );
  }
}

@Riverpod(keepAlive: true)
class UnreadNotificationCountController extends _$UnreadNotificationCountController {
  @override
  Future<int> build() async {
    final auth = ref.watch(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) return 0;

    final result = await ref.watch(getUnreadNotificationCountUseCaseProvider)();
    return result.match((_) => 0, (count) => count);
  }

  void decrement() {
    final current = state.value ?? 0;
    if (current <= 0) return;
    state = AsyncData(current - 1);
  }

  void clear() {
    state = const AsyncData(0);
  }
}
