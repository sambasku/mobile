import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/pages/my_achievements_page.dart';

class AchievementRouter {
  AchievementRouter._();

  static const list = RouteDefiner(
    path: '/achievements',
    name: 'AchievementRouter.list',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: list.path,
      name: list.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const MyAchievementsPage(),
    ),
  ];
}
