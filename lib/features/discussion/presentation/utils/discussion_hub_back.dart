import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Back kanonik hub Diskusi (chat + ruang di [StatefulShellRoute]).
///
/// Branch 0 = Chat (default). Dari Ruang Diskusi (branch 1) → ke Chat dulu.
/// Dari Chat: `pop` bila ada stack; selain itu ke Home supaya system back aman.
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