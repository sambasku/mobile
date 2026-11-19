import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/pages/periksa_kata_page.dart';

class PeriksaKataRouter {
  PeriksaKataRouter._();

  static const check = RouteDefiner(
    path: '/periksa-kata',
    name: 'PeriksaKataRouter.check',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: check.path,
      name: check.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const PeriksaKataPage(),
    ),
  ];
}
