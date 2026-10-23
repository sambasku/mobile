import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'presentation/pages/event_contribute_page.dart';
import 'presentation/pages/event_detail_page.dart';
import 'presentation/pages/event_list_page.dart';
import 'presentation/pages/event_proposals_page.dart';

class EventRouter {
  EventRouter._();

  /// Daftar acara.
  static const list = RouteDefiner(path: '/acara', name: 'EventRouter.list');

  /// Detail acara by slug.
  static const detail = RouteDefiner(
    path: '/acara/:slug',
    name: 'EventRouter.detail',
  );

  /// Form usulan acara.
  static const contribute = RouteDefiner(
    path: '/acara/kontribusi',
    name: 'EventRouter.contribute',
  );

  /// Status usulan milik user.
  static const proposals = RouteDefiner(
    path: '/acara/usulan',
    name: 'EventRouter.proposals',
  );

  static String detailPath(String slug) =>
      detail.path.replaceFirst(':slug', Uri.encodeComponent(slug));

  /// Route detail di luar shell (push penuh).
  ///
  /// `contribute` dan `proposals` WAJIB sebelum `detail` - GoRouter
  /// cocokkan berurutan, `/acara/:slug` akan menelan "kontribusi".
  static final List<GoRoute> routes = [
    GoRoute(
      path: contribute.path,
      name: contribute.name,
      builder: (context, state) => const EventContributePage(),
    ),
    GoRoute(
      path: proposals.path,
      name: proposals.name,
      builder: (context, state) => const EventProposalsPage(),
    ),
    GoRoute(
      path: list.path,
      name: list.name,
      builder: (context, state) => const EventListPage(),
    ),
    GoRoute(
      path: detail.path,
      name: detail.name,
      builder: (context, state) {
        final slug = state.pathParameters['slug'] ?? '';
        return EventDetailPage(slug: slug);
      },
    ),
  ];
}
