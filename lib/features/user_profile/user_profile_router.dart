import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/pages/public_profile_page.dart';

class UserProfileRouter {
  UserProfileRouter._();

  static const profile = RouteDefiner(
    path: '/users/:username',
    name: 'UserProfileRouter.profile',
  );

  /// [displayName] opsional - judul app bar instan sebelum GET profil selesai.
  static void open(
    BuildContext context,
    String username, {
    String? displayName,
  }) {
    final handle = username.trim();
    if (handle.isEmpty) return;
    final name = displayName?.trim();
    context.pushNamed(
      profile.name,
      pathParameters: {'username': handle},
      extra: (name != null && name.isNotEmpty) ? name : null,
    );
  }

  static final List<GoRoute> routes = [
    GoRoute(
      path: profile.path,
      name: profile.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) {
        final raw = state.pathParameters['username'] ?? '';
        // go_router biasanya sudah decode; defensive untuk %20 tersisa.
        final username = Uri.decodeComponent(raw);
        final extra = state.extra;
        final initialDisplayName = extra is String && extra.trim().isNotEmpty
            ? extra.trim()
            : null;
        return PublicProfilePage(
          username: username,
          initialDisplayName: initialDisplayName,
        );
      },
    ),
  ];
}
