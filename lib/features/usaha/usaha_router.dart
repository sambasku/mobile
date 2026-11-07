import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'presentation/pages/usaha_contribute_page.dart';
import 'presentation/pages/usaha_claims_page.dart';
import 'presentation/pages/usaha_detail_page.dart';
import 'presentation/pages/usaha_list_page.dart';
import 'presentation/pages/usaha_map_page.dart';
import 'presentation/pages/usaha_photos_page.dart';
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

  /// Peta internal satu pin usaha.
  static const map = RouteDefiner(
    path: '/usaha/:slug/peta',
    name: 'UsahaRouter.map',
  );

  /// Galeri foto singgah.
  static const photos = RouteDefiner(
    path: '/usaha/:slug/foto',
    name: 'UsahaRouter.photos',
  );

  /// Form usulan usaha baru (boleh anonim).
  static const contribute = RouteDefiner(
    path: '/usaha/kontribusi',
    name: 'UsahaRouter.contribute',
  );

  /// Form usulan perubahan (prefill dari detail).
  static const edit = RouteDefiner(
    path: '/usaha/:slug/usulkan',
    name: 'UsahaRouter.edit',
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

  static String mapPath(String slug) =>
      map.path.replaceFirst(':slug', Uri.encodeComponent(slug));

  static String photosPath(String slug) =>
      photos.path.replaceFirst(':slug', Uri.encodeComponent(slug));

  static String editPath(String slug) =>
      edit.path.replaceFirst(':slug', Uri.encodeComponent(slug));

  /// Route di luar shell (push penuh). Semua segmen statis WAJIB sebelum
  /// `detail` - GoRouter cocokkan berurutan, `/usaha/:slug` akan menelan
  /// "kontribusi"/"usulan"/"saya"/"klaim".
  static final List<GoRoute> routes = [
    GoRoute(
      path: contribute.path,
      name: contribute.name,
      builder: (context, state) =>
          const UsahaContributePage(mode: UsahaContributeMode.create),
    ),
    GoRoute(
      path: edit.path,
      name: edit.name,
      builder: (context, state) {
        final slug = state.pathParameters['slug'] ?? '';
        return UsahaContributePage(
          mode: UsahaContributeMode.edit,
          slug: slug,
        );
      },
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
      path: map.path,
      name: map.name,
      builder: (context, state) {
        final slug = state.pathParameters['slug'] ?? '';
        return UsahaMapPage(slug: slug);
      },
    ),
    GoRoute(
      path: photos.path,
      name: photos.name,
      builder: (context, state) {
        final slug = state.pathParameters['slug'] ?? '';
        return UsahaPhotosPage(slug: slug);
      },
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
