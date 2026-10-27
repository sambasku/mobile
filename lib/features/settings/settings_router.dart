import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'presentation/pages/language_settings_page.dart';
import 'presentation/pages/settings_page.dart';

class SettingsRouter {
  SettingsRouter._();

  static const root = RouteDefiner(path: '/settings', name: 'SettingsRouter.root');
  static const language = RouteDefiner(
    path: '/settings/language',
    name: 'SettingsRouter.language',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: root.path,
      name: root.name,
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: language.path,
      name: language.name,
      builder: (context, state) => const LanguageSettingsPage(),
    ),
  ];
}
