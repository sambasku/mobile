import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Back kanonik hub Diskusi (feed + chat di [StatefulShellRoute]).
///
/// Chat (branch 1) → kembali ke Ruang Diskusi (branch 0) dulu.
/// Di feed: `pop` bila ada stack; selain itu (deep link / `go`) ke Home
/// supaya system back tidak menutup app.
void leaveDiscussionHub(
  BuildContext context,
  StatefulNavigationShell navigationShell,
) {
  if (navigationShell.currentIndex != 0) {
    navigationShell.goBranch(0);
    return;
  }
  if (discussionHubCanPop(context)) {
    context.pop();
    return;
  }
  context.go('/');
}

/// `canPop` aman untuk `build` / [PopScope] (tanpa throw di widget test).
bool discussionHubCanPop(BuildContext context) {
  final router = GoRouter.maybeOf(context);
  if (router != null) return router.canPop();
  return Navigator.maybeOf(context)?.canPop() ?? false;
}
