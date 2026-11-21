import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'domain/baleho_models.dart';
import 'presentation/pages/baleho_book_page.dart';
import 'presentation/pages/baleho_history_detail_page.dart';
import 'presentation/pages/baleho_history_page.dart';
import 'presentation/pages/baleho_weekly_leaderboard_history_page.dart';
import 'presentation/pages/baleho_weekly_leaderboard_page.dart';

class BalehoRouter {
  BalehoRouter._();

  static const book = RouteDefiner(
    path: '/baleho/pesan',
    name: 'BalehoRouter.book',
  );

  static const history = RouteDefiner(
    path: '/baleho/riwayat',
    name: 'BalehoRouter.history',
  );

  static const historyDetail = RouteDefiner(
    path: '/baleho/riwayat/:id',
    name: 'BalehoRouter.historyDetail',
  );

  static const weeklyLeaderboard = RouteDefiner(
    path: BalehoBoard.weeklyLeaderboardPath,
    name: 'BalehoRouter.weeklyLeaderboard',
  );

  static const weeklyLeaderboardHistoryWeek = RouteDefiner(
    path: '${BalehoBoard.weeklyLeaderboardPath}/riwayat/:weekId',
    name: 'BalehoRouter.weeklyLeaderboardHistoryWeek',
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
        return BalehoBookPage(selection: sel, referralUsername: q['ref']);
      },
    ),
    GoRoute(
      path: history.path,
      name: history.name,
      builder: (context, state) => const BalehoHistoryPage(),
      routes: [
        GoRoute(
          path: ':id',
          name: historyDetail.name,
          builder: (context, state) => BalehoHistoryDetailPage(
            placementId: state.pathParameters['id'] ?? '',
          ),
        ),
      ],
    ),
    GoRoute(
      path: weeklyLeaderboard.path,
      name: weeklyLeaderboard.name,
      builder: (context, state) => const BalehoWeeklyLeaderboardPage(),
      routes: [
        GoRoute(
          path: 'riwayat/:weekId',
          name: weeklyLeaderboardHistoryWeek.name,
          builder: (context, state) {
            final weekId = state.pathParameters['weekId'] ?? '';
            return BalehoWeeklyLeaderboardHistoryPage(weekId: weekId);
          },
        ),
      ],
    ),
  ];
}
