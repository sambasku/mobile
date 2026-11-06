import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'domain/pantun_compose_args.dart';
import 'presentation/pages/pantun_compose_page.dart';
import 'presentation/pages/pantun_detail_page.dart';
import 'presentation/pages/pantun_feed_page.dart';
import 'presentation/pages/permainan_list_page.dart';

class EntertainmentRouter {
  EntertainmentRouter._();

  /// Hub semua permainan (grid 3 kolom). Pantun salah satu isinya.
  static const hub = RouteDefiner(
    path: '/entertainment',
    name: 'EntertainmentRouter.hub',
  );

  static const pantunHub = RouteDefiner(
    path: '/entertainment/pantun',
    name: 'EntertainmentRouter.pantunHub',
  );

  static const pantunCreate = RouteDefiner(
    path: '/entertainment/pantun/create',
    name: 'EntertainmentRouter.pantunCreate',
  );

  static const pantunDetail = RouteDefiner(
    path: '/entertainment/pantun/:id',
    name: 'EntertainmentRouter.pantunDetail',
  );

  static String pantunDetailPath(String id) => '/entertainment/pantun/$id';

  static final List<GoRoute> routes = [
    GoRoute(
      path: hub.path,
      name: hub.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const PermainanListPage(),
    ),
    GoRoute(
      path: pantunHub.path,
      name: pantunHub.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const PantunFeedPage(),
    ),
    GoRoute(
      path: pantunCreate.path,
      name: pantunCreate.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) {
        final parent = state.uri.queryParameters['parent'];
        final quote = state.uri.queryParameters['quote'];
        final extra = state.extra;
        final args = extra is PantunComposeArgs
            ? extra
            : PantunComposeArgs(
                parentId: parent,
                quoteId: quote ?? PantunComposeArgs.quoteRoot,
              );
        return PantunComposePage(
          parentId: parent ?? args.parentId,
          quoteId: quote ?? args.normalizedQuoteId,
          args: args,
        );
      },
    ),
    GoRoute(
      path: pantunDetail.path,
      name: pantunDetail.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => PantunDetailPage(
        id: state.pathParameters['id']!,
        // Deep-link hasil pencarian balasan: sorot + scroll ke balasan itu.
        highlightReplyId: state.uri.queryParameters['reply'],
      ),
    ),
  ];
}
