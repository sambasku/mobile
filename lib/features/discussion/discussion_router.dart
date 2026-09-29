import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/pages/create_discussion_page.dart';
import 'presentation/pages/my_discussions_page.dart';
import 'presentation/pages/discussion_detail_page.dart';
import 'presentation/pages/discussion_feed_page.dart';

class DiscussionRouter {
  DiscussionRouter._();

  static const feed = RouteDefiner(
    path: '/discussions',
    name: 'DiscussionRouter.feed',
  );

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

  static final List<GoRoute> routes = [
    GoRoute(
      path: feed.path,
      name: feed.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const DiscussionFeedPage(),
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
      builder: (context, state) => DiscussionDetailPage(
        id: state.pathParameters['id'] ?? '',
      ),
    ),
  ];
}
