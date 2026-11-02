import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'presentation/pages/usaha_contribute_page.dart';
import 'presentation/pages/usaha_claims_page.dart';
import 'presentation/pages/usaha_detail_page.dart';
import 'presentation/pages/usaha_list_page.dart';
import 'presentation/pages/usaha_proposals_page.dart';
import 'presentation/pages/usaha_saya_page.dart';

class UsahaRouter {
  UsahaRouter._();

  /// Daftar usaha.
  static const list = RouteDefiner(path: '/usaha', name: 'UsahaRouter.list');

  /// Detail usaha by slug.
  static const detail = RouteDefiner(
    path: '/usaha/:slug',
    name: 'UsahaRouter.detail',
  );

  /// Form usulan usaha baru (boleh anonim).
  static const contribute = RouteDefiner(
    path: '/usaha/kontribusi',
    name: 'UsahaRouter.contribute',
  );

  /// Status usulan milik user.
  static const proposals = RouteDefiner(
    path: '/usaha/usulan',
    name: 'UsahaRouter.proposals',
  );

  /// Usaha yang saya kelola (pengelola terverifikasi).
  static const saya = RouteDefiner(path: '/usaha/saya', name: 'UsahaRouter.saya');

  /// Klaim pengelolaan milik user.
  static const claims = RouteDefiner(
    path: '/usaha/klaim',
    name: 'UsahaRouter.claims',
  );

  static String detailPath(String slug) =>
      detail.path.replaceFirst(':slug', Uri.encodeComponent(slug));

  /// Route di luar shell (push penuh). Semua segmen statis WAJIB sebelum
  /// `detail` - GoRouter cocokkan berurutan, `/usaha/:slug` akan menelan
  /// "kontribusi"/"usulan"/"saya"/"klaim".
  static final List<GoRoute> routes = [
    GoRoute(
      path: contribute.path,
      name: contribute.name,
      builder: (context, state) => const UsahaContributePage(),
    ),
    GoRoute(
      path: proposals.path,
      name: proposals.name,
      builder: (context, state) => const UsahaProposalsPage(),
    ),
    GoRoute(
      path: saya.path,
      name: saya.name,
      builder: (context, state) => const UsahaSayaPage(),
    ),
    GoRoute(
      path: claims.path,
      name: claims.name,
      builder: (context, state) => const UsahaClaimsPage(),
    ),
    GoRoute(
      path: list.path,
      name: list.name,
      builder: (context, state) => const UsahaListPage(),
    ),
    GoRoute(
      path: detail.path,
      name: detail.name,
      builder: (context, state) {
        final slug = state.pathParameters['slug'] ?? '';
        return UsahaDetailPage(slug: slug);
      },
    ),
  ];
}
