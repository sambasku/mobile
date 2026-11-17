import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'presentation/pages/karya_contribute_page.dart';
import 'presentation/pages/karya_detail_page.dart';
import 'presentation/pages/karya_excerpt_page.dart';
import 'presentation/pages/karya_proposals_page.dart';
import 'presentation/pages/kreator_profile_page.dart';

class KaryaRouter {
  KaryaRouter._();

  static const contribute = RouteDefiner(
    path: '/karya/kontribusi',
    name: 'KaryaRouter.contribute',
  );

  static const excerpt = RouteDefiner(
    path: '/karya/cuplikan',
    name: 'KaryaRouter.excerpt',
  );

  static const proposals = RouteDefiner(
    path: '/karya/usulan',
    name: 'KaryaRouter.proposals',
  );

  static const detail = RouteDefiner(
    path: '/karya/:slug',
    name: 'KaryaRouter.detail',
  );

  static const kreator = RouteDefiner(
    path: '/kreator/:slug',
    name: 'KaryaRouter.kreator',
  );

  static String detailPath(String slug) =>
      detail.path.replaceFirst(':slug', Uri.encodeComponent(slug));

  static String kreatorPath(String slug) =>
      kreator.path.replaceFirst(':slug', Uri.encodeComponent(slug));

  static String contributePath({
    String? karyaId,
    String? slug,
    String? creditName,
    String? kind,
  }) {
    final q = <String, String>{
      if (karyaId != null && karyaId.isNotEmpty) 'id': karyaId,
      if (slug != null && slug.isNotEmpty) 'slug': slug,
      if (creditName != null && creditName.isNotEmpty) 'credit': creditName,
      if (kind != null && kind.isNotEmpty) 'kind': kind,
    };
    if (q.isEmpty) return contribute.path;
    return '${contribute.path}?${Uri(queryParameters: q).query}';
  }

  static String excerptPath({
    required String karyaId,
    String? slug,
    String? karyaKind,
  }) {
    final q = <String, String>{
      'id': karyaId,
      if (slug != null && slug.isNotEmpty) 'slug': slug,
      if (karyaKind != null && karyaKind.isNotEmpty) 'kind': karyaKind,
    };
    return '${excerpt.path}?${Uri(queryParameters: q).query}';
  }

  static final List<GoRoute> routes = [
    GoRoute(
      path: contribute.path,
      name: contribute.name,
      builder: (context, state) => KaryaContributePage(
        karyaId: state.uri.queryParameters['id'],
        slug: state.uri.queryParameters['slug'],
        prefillCreditName: state.uri.queryParameters['credit'],
        prefillKind: state.uri.queryParameters['kind'],
      ),
    ),
    GoRoute(
      path: excerpt.path,
      name: excerpt.name,
      builder: (context, state) => KaryaExcerptPage(
        karyaId: state.uri.queryParameters['id'] ?? '',
        slug: state.uri.queryParameters['slug'],
        karyaKind: state.uri.queryParameters['kind'],
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
    GoRoute(
      path: kreator.path,
      name: kreator.name,
      builder: (context, state) =>
          KreatorProfilePage(slug: state.pathParameters['slug'] ?? ''),
    ),
  ];
}
