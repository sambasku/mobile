import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/pages/admin_analytics_page.dart';
import 'presentation/widgets/admin_analytics_gate.dart';

class AdminAnalyticsRouter {
  AdminAnalyticsRouter._();

  static const home = RouteDefiner(
    path: '/admin/analytics',
    name: 'AdminAnalyticsRouter.home',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: home.path,
      name: home.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const AdminAnalyticsGate(
        child: AdminAnalyticsPage(),
      ),
    ),
  ];
}
