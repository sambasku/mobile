import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import '../chat/presentation/pages/chat_page.dart';
import 'presentation/pages/create_discussion_page.dart';
import 'presentation/pages/discussion_feed_page.dart';
import 'presentation/pages/discussion_hub_shell.dart';
import 'presentation/pages/discussion_detail_page.dart';
import 'presentation/pages/my_discussions_page.dart';

class DiscussionRouter {
  DiscussionRouter._();

  /// Tab Chat (default masuk hub Diskusi).
  static const chat = RouteDefiner(
    path: '/discussions',
    name: 'DiscussionRouter.chat',
  );

  /// Tab Ruang Diskusi (daftar thread).
  static const rooms = RouteDefiner(
    path: '/discussions/rooms',
    name: 'DiscussionRouter.rooms',
  );

  /// Alias lama - arahkan ke tab Ruang Diskusi.
  static const feed = rooms;

  static const create = RouteDefiner(
    path: '/discussions/create',
    name: 'DiscussionRouter.create',
  );

  static const mine = RouteDefiner(
    path: '/discussions/my',
    name: 'DiscussionRouter.mine',
  );

  static const detail = RouteDefiner(
    path: '/discussions/:id',
    name: 'DiscussionRouter.detail',
  );

  static String detailPath(String id) => '/discussions/$id';

  static const _legacyChatPath = '/discussions/chat';

  static const Set<String> _reservedDetailSlugs = {
    'rooms',
    'chat',
    'create',
    'my',
  };

  /// Hub (chat + ruang) = StatefulShell; create/mine/detail = overlay root.
  static final List<RouteBase> routes = [
    GoRoute(
      path: _legacyChatPath,
      redirect: (context, state) => chat.path,
    ),
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state, navigationShell) =>
          DiscussionHubShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: chat.path,
              name: chat.name,
              builder: (context, state) => const ChatPage(embeddedInHub: true),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: rooms.path,
              name: rooms.name,
              builder: (context, state) => const DiscussionRoomsPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: create.path,
      name: create.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => CreateDiscussionPage(
        autofocus: state.uri.queryParameters['focus'] == '1',
      ),
    ),
    GoRoute(
      path: mine.path,
      name: mine.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const MyDiscussionsPage(),
    ),
    GoRoute(
      path: detail.path,
      name: detail.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      redirect: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        if (id == 'rooms') return rooms.path;
        if (id == 'chat') return chat.path;
        if (_reservedDetailSlugs.contains(id)) return chat.path;
        return null;
      },
      builder: (context, state) => DiscussionDetailPage(
        id: state.pathParameters['id'] ?? '',
      ),
    ),
  ];
}