import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/pages/create_jinye_page.dart';
import 'presentation/pages/jinye_archived_page.dart';
import 'presentation/pages/jinye_detail_page.dart';

class JinyeRouter {
  JinyeRouter._();

  static const create = RouteDefiner(
    path: '/jinye/create',
    name: 'JinyeRouter.create',
  );

  static const archived = RouteDefiner(
    path: '/jinye/archived',
    name: 'JinyeRouter.archived',
  );

  static const detail = RouteDefiner(
    path: '/jinye/:id',
    name: 'JinyeRouter.detail',
  );

  static String detailPath(String id) => '/jinye/$id';

  static final List<GoRoute> routes = [
    GoRoute(
      path: create.path,
      name: create.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const CreateJinyePage(),
    ),
    GoRoute(
      path: archived.path,
      name: archived.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const JinyeArchivedPage(),
    ),
    GoRoute(
      path: detail.path,
      name: detail.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => JinyeDetailPage(
        id: state.pathParameters['id'] ?? '',
      ),
    ),
  ];
}
