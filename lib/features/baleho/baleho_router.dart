import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'domain/baleho_models.dart';
import 'presentation/pages/baleho_book_page.dart';
import 'presentation/pages/baleho_weekly_leaderboard_page.dart';

class BalehoRouter {
  BalehoRouter._();

  static const book = RouteDefiner(
    path: '/baleho/pesan',
    name: 'BalehoRouter.book',
  );

  static const weeklyLeaderboard = RouteDefiner(
    path: BalehoBoard.weeklyLeaderboardPath,
    name: 'BalehoRouter.weeklyLeaderboard',
  );

  static List<RouteBase> get routes => [
        GoRoute(
          path: book.path,
          name: book.name,
          builder: (context, state) {
            final q = state.uri.queryParameters;
            final sel = BalehoSelection(
              col: int.tryParse(q['col'] ?? '') ?? 0,
              row: int.tryParse(q['row'] ?? '') ?? 0,
              w: int.tryParse(q['w'] ?? '') ?? 1,
              h: int.tryParse(q['h'] ?? '') ?? 1,
            );
            return BalehoBookPage(
              selection: sel,
              referralUsername: q['ref'],
            );
          },
        ),
        GoRoute(
          path: weeklyLeaderboard.path,
          name: weeklyLeaderboard.name,
          builder: (context, state) => const BalehoWeeklyLeaderboardPage(),
        ),
      ];
}
