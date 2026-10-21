import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'presentation/pages/set_password_page.dart';

class SetPasswordRouter {
  SetPasswordRouter._();

  static const setPassword = RouteDefiner(
    path: '/set-password',
    name: 'SetPasswordRouter.setPassword',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: setPassword.path,
      name: setPassword.name,
      builder: (context, state) => const SetPasswordPage(),
    ),
  ];
}
