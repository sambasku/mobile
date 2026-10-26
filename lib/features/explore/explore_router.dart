import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'presentation/pages/explore_category_page.dart';
import 'presentation/pages/cuisine_detail_page.dart';
import 'presentation/pages/cuisine_list_page.dart';
import 'presentation/pages/culinary_contribute_page.dart';
import 'presentation/pages/culinary_places_page.dart';
import 'presentation/pages/pins_page.dart';
import 'presentation/pages/place_contribute_page.dart';
import 'presentation/pages/place_detail_page.dart';
import 'presentation/pages/place_photos_page.dart';
import 'presentation/pages/place_proposals_page.dart';
import 'presentation/pages/region_detail_page.dart';

class ExploreRouter {
  ExploreRouter._();

  static const hub = RouteDefiner(path: '/explore', name: 'ExploreRouter.hub');

  static const category = RouteDefiner(
    path: '/explore/:id',
    name: 'ExploreRouter.category',
  );

  /// Route detail Place (push penuh, root navigator). URL pakai slug
  /// readable; identitas data tetap `id`.
  static const place = RouteDefiner(
    path: '/explore/place/:slug',
    name: 'ExploreRouter.place',
  );

  /// Linimasa foto satu tempat.
  static const placePhotos = RouteDefiner(
    path: '/explore/place/:slug/foto',
    name: 'ExploreRouter.placePhotos',
  );

  static String placePhotosPath(String slug) =>
      placePhotos.path.replaceFirst(':slug', slug);

  /// Daftar + detail Cuisine (cuisines.json, bukan places.json).
  static const cuisineList = RouteDefiner(
    path: '/explore/cuisine',
    name: 'ExploreRouter.cuisineList',
  );

  /// Daftar tempat/penjual kuliner (butuh segmen statis SEBELUM detail).
  static const cuisinePlaces = RouteDefiner(
    path: '/explore/cuisine/places',
    name: 'ExploreRouter.cuisinePlaces',
  );

  /// Form usulan kuliner/tempat/relasi. WAJIB sebelum `cuisineDetail` -
  /// `/explore/cuisine/:slug` akan menelan segmen statis ini.
  static const cuisineContribute = RouteDefiner(
    path: '/explore/cuisine/usul',
    name: 'ExploreRouter.cuisineContribute',
  );

  static const cuisinePlaceContribute = RouteDefiner(
    path: '/explore/cuisine/usul-tempat',
    name: 'ExploreRouter.cuisinePlaceContribute',
  );

  static const cuisineLink = RouteDefiner(
    path: '/explore/cuisine/usul-penjual',
    name: 'ExploreRouter.cuisineLink',
  );

  static const cuisineDetail = RouteDefiner(
    path: '/explore/cuisine/:slug',
    name: 'ExploreRouter.cuisineDetail',
  );

  /// Peta semua Place (pin, tap ke detail).
  static const pins = RouteDefiner(
    path: '/explore/place/pins',
    name: 'ExploreRouter.pins',
  );

  /// Usulan wisata milik user. Wajib sebelum `place` supaya "usulan"
  /// tidak tertelan sebagai slug.
  static const placeProposals = RouteDefiner(
    path: '/explore/place/usulan',
    name: 'ExploreRouter.placeProposals',
  );

  static const placeContribute = RouteDefiner(
    path: '/explore/place/kontribusi',
    name: 'ExploreRouter.placeContribute',
  );

  static const placeEdit = RouteDefiner(
    path: '/explore/place/:slug/sunting',
    name: 'ExploreRouter.placeEdit',
  );

  static const placeAddPhoto = RouteDefiner(
    path: '/explore/place/:slug/tambah-foto',
    name: 'ExploreRouter.placeAddPhoto',
  );

  /// Detail kecamatan (slug = id) dan desa (slug = kode BPS).
  static const kecamatan = RouteDefiner(
    path: '/explore/kecamatan/:slug',
    name: 'ExploreRouter.kecamatan',
  );

  static const desa = RouteDefiner(
    path: '/explore/desa/:slug',
    name: 'ExploreRouter.desa',
  );

  /// Route detail di luar shell (push penuh). `pins` wajib sebelum `place`:
  /// GoRouter cocokkan berurutan, `/explore/place/:slug` menelan "pins".
  static final List<GoRoute> routes = [
    GoRoute(
      path: category.path,
      name: category.name,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ExploreCategoryPage(categoryId: id);
      },
    ),
    GoRoute(
      path: pins.path,
      name: pins.name,
      builder: (context, state) {
        return PinsPage(focusSlug: state.uri.queryParameters['slug']);
      },
    ),
    GoRoute(
      path: placeProposals.path,
      name: placeProposals.name,
      builder: (context, state) => const PlaceProposalsPage(),
    ),
    GoRoute(
      path: placeContribute.path,
      name: placeContribute.name,
      builder: (context, state) =>
          const PlaceContributePage(mode: PlaceContributeMode.create),
    ),
    GoRoute(
      path: placeEdit.path,
      name: placeEdit.name,
      builder: (context, state) => PlaceContributePage(
        mode: PlaceContributeMode.edit,
        slug: state.pathParameters['slug'],
      ),
    ),
    GoRoute(
      path: placeAddPhoto.path,
      name: placeAddPhoto.name,
      builder: (context, state) => PlaceContributePage(
        mode: PlaceContributeMode.photo,
        slug: state.pathParameters['slug'],
      ),
    ),
    GoRoute(
      path: kecamatan.path,
      name: kecamatan.name,
      builder: (context, state) =>
          RegionDetailPage.kecamatan(slug: state.pathParameters['slug'] ?? ''),
    ),
    GoRoute(
      path: desa.path,
      name: desa.name,
      builder: (context, state) => RegionDetailPage.desa(
        slug: Uri.decodeComponent(state.pathParameters['slug'] ?? ''),
      ),
    ),
    GoRoute(
      path: cuisineList.path,
      name: cuisineList.name,
      builder: (context, state) => const CuisineListPage(),
    ),
    GoRoute(
      path: cuisinePlaces.path,
      name: cuisinePlaces.name,
      builder: (context, state) => const CulinaryPlacesPage(),
    ),
    GoRoute(
      path: cuisineContribute.path,
      name: cuisineContribute.name,
      builder: (context, state) =>
          const CulinaryContributePage(mode: CulinaryContributeMode.cuisine),
    ),
    GoRoute(
      path: cuisinePlaceContribute.path,
      name: cuisinePlaceContribute.name,
      builder: (context, state) =>
          const CulinaryContributePage(mode: CulinaryContributeMode.place),
    ),
    GoRoute(
      path: cuisineLink.path,
      name: cuisineLink.name,
      builder: (context, state) =>
          const CulinaryContributePage(mode: CulinaryContributeMode.link),
    ),
    GoRoute(
      path: cuisineDetail.path,
      name: cuisineDetail.name,
      builder: (context, state) {
        final slug = state.pathParameters['slug'] ?? '';
        return CuisineDetailPage(slug: slug);
      },
    ),
    GoRoute(
      path: placePhotos.path,
      name: placePhotos.name,
      builder: (context, state) {
        final slug = state.pathParameters['slug'] ?? '';
        return PlacePhotosPage(slug: slug);
      },
    ),
    GoRoute(
      path: place.path,
      name: place.name,
      builder: (context, state) {
        final slug = state.pathParameters['slug'] ?? '';
        final entry =
            state.uri.queryParameters['entry'] ?? (state.extra as String?);
        return PlaceDetailPage(
          slug: slug,
          entry: entry == null || entry.isEmpty ? 'list' : entry,
        );
      },
    ),
  ];
}
