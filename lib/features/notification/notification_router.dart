import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'domain/entities/inbox_notification.dart';
import 'presentation/pages/notification_detail_page.dart';
import 'presentation/pages/notification_inbox_page.dart';

class NotificationRouter {
  NotificationRouter._();

  static const list = RouteDefiner(
    path: '/notifications',
    name: 'NotificationRouter.list',
  );

  static const detail = RouteDefiner(
    path: '/notifications/:id',
    name: 'NotificationRouter.detail',
  );

  static String detailPath(String id) => '/notifications/$id';

  static final List<GoRoute> routes = [
    GoRoute(
      path: list.path,
      name: list.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const NotificationInboxPage(),
    ),
    GoRoute(
      path: detail.path,
      name: detail.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra;
        return NotificationDetailPage(
          item: extra is InboxNotification ? extra : null,
        );
      },
    ),
  ];
}
