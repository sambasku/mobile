import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'presentation/layanan_contribute_page.dart';
import 'presentation/layanan_detail_page.dart';
import 'presentation/layanan_proposals_page.dart';

class LayananRouter {
  LayananRouter._();

  static const contribute = RouteDefiner(
    path: '/layanan/kontribusi',
    name: 'LayananRouter.contribute',
  );

  static const proposals = RouteDefiner(
    path: '/layanan/usulan',
    name: 'LayananRouter.proposals',
  );

  static const detail = RouteDefiner(
    path: '/layanan/:slug',
    name: 'LayananRouter.detail',
  );

  static String detailPath(String slug) =>
      detail.path.replaceFirst(':slug', Uri.encodeComponent(slug));

  static String contributePath({String? regionId, String? layananId, String? category}) {
    final q = <String, String>{
      if (regionId != null && regionId.isNotEmpty) 'region': regionId,
      if (layananId != null && layananId.isNotEmpty) 'id': layananId,
      if (category != null && category.isNotEmpty) 'category': category,
    };
    if (q.isEmpty) return contribute.path;
    return '${contribute.path}?${Uri(queryParameters: q).query}';
  }

  /// Segmen statis sebelum `/:slug`.
  static final List<GoRoute> routes = [
    GoRoute(
      path: contribute.path,
      name: contribute.name,
      builder: (context, state) => LayananContributePage(
        regionId: state.uri.queryParameters['region'],
        layananId: state.uri.queryParameters['id'],
        category: state.uri.queryParameters['category'],
      ),
    ),
    GoRoute(
      path: proposals.path,
      name: proposals.name,
      builder: (context, state) => const LayananProposalsPage(),
    ),
    GoRoute(
      path: detail.path,
      name: detail.name,
      builder: (context, state) =>
          LayananDetailPage(slug: state.pathParameters['slug'] ?? ''),
    ),
  ];
}
