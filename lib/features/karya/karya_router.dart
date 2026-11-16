import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'presentation/pages/karya_contribute_page.dart';
import 'presentation/pages/karya_detail_page.dart';
import 'presentation/pages/karya_proposals_page.dart';

class KaryaRouter {
  KaryaRouter._();

  static const contribute = RouteDefiner(
    path: '/karya/kontribusi',
    name: 'KaryaRouter.contribute',
  );

  static const proposals = RouteDefiner(
    path: '/karya/usulan',
    name: 'KaryaRouter.proposals',
  );

  static const detail = RouteDefiner(
    path: '/karya/:slug',
    name: 'KaryaRouter.detail',
  );

  static String detailPath(String slug) =>
      detail.path.replaceFirst(':slug', Uri.encodeComponent(slug));

  static String contributePath({String? karyaId, String? slug}) {
    final q = <String, String>{
      if (karyaId != null && karyaId.isNotEmpty) 'id': karyaId,
      if (slug != null && slug.isNotEmpty) 'slug': slug,
    };
    if (q.isEmpty) return contribute.path;
    return '${contribute.path}?${Uri(queryParameters: q).query}';
  }

  static final List<GoRoute> routes = [
    GoRoute(
      path: contribute.path,
      name: contribute.name,
      builder: (context, state) => KaryaContributePage(
        karyaId: state.uri.queryParameters['id'],
        slug: state.uri.queryParameters['slug'],
      ),
    ),
    GoRoute(
      path: proposals.path,
      name: proposals.name,
      builder: (context, state) => const KaryaProposalsPage(),
    ),
    GoRoute(
      path: detail.path,
      name: detail.name,
      builder: (context, state) =>
          KaryaDetailPage(slug: state.pathParameters['slug'] ?? ''),
    ),
  ];
}