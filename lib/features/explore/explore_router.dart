import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'presentation/pages/explore_category_page.dart';
import 'presentation/pages/cuisine_detail_page.dart';
import 'presentation/pages/cuisine_list_page.dart';
import 'presentation/pages/pins_page.dart';
import 'presentation/pages/place_detail_page.dart';

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

  /// Daftar + detail Cuisine (cuisines.json, bukan places.json).
  static const cuisineList = RouteDefiner(
    path: '/explore/cuisine',
    name: 'ExploreRouter.cuisineList',
  );

  static const cuisineDetail = RouteDefiner(
    path: '/explore/cuisine/:slug',
    name: 'ExploreRouter.cuisineDetail',
  );

  /// Peta semua Place (pin, tap → detail).
  static const pins = RouteDefiner(
    path: '/explore/place/pins',
    name: 'ExploreRouter.pins',
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
      path: cuisineList.path,
      name: cuisineList.name,
      builder: (context, state) => const CuisineListPage(),
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
