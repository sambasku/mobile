import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/pages/periksa_kata_history_page.dart';
import 'presentation/pages/periksa_kata_page.dart';

class PeriksaKataRouter {
  PeriksaKataRouter._();

  static const check = RouteDefiner(
    path: '/periksa-kata',
    name: 'PeriksaKataRouter.check',
  );

  static const history = RouteDefiner(
    path: '/periksa-kata/riwayat',
    name: 'PeriksaKataRouter.history',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: check.path,
      name: check.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const PeriksaKataPage(),
    ),
    GoRoute(
      path: history.path,
      name: history.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const PeriksaKataHistoryPage(),
    ),
  ];
}
