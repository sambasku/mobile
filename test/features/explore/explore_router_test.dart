import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sambasku_mobile/features/explore/explore_router.dart';

void main() {
  test('/explore/place/pins opens map, not detail with slug "pins"', () {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const SizedBox()),
        ...ExploreRouter.routes,
      ],
    );
    addTearDown(router.dispose);

    String? nameOf(String location) =>
        router.configuration.findMatch(Uri.parse(location)).last.route.name;

    expect(nameOf('/explore/place/pins?slug=istana'), ExploreRouter.pins.name);
    expect(nameOf('/explore/place/istana'), ExploreRouter.place.name);
  });

test('placePhotosPath membuka linimasa foto, bukan detail slug foto', () {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const SizedBox()),
        ...ExploreRouter.routes,
      ],
    );
    addTearDown(router.dispose);

    expect(
      ExploreRouter.placePhotosPath('istana'),
      '/explore/place/istana/foto',
    );
    final match = router.configuration
        .findMatch(Uri.parse(ExploreRouter.placePhotosPath('istana')))
        .last;
    expect(match.route.name, ExploreRouter.placePhotos.name);
  });
}
