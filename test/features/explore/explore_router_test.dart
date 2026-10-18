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

  test('placeArticlePath menghasilkan path match route artikel (#168)', () {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const SizedBox()),
        ...ExploreRouter.routes,
      ],
    );
    addTearDown(router.dispose);

    // Bug lama: path literal ':slug' + query (?slug=...) tidak match route
    // artikel -> halaman artikel kosong (issue #168).
    expect(ExploreRouter.placeArticlePath('istana'),
        '/explore/place/istana/artikel');
    expect(ExploreRouter.placeArticlePath('istana').contains(':slug'), false);

    final match = router.configuration
        .findMatch(Uri.parse(ExploreRouter.placeArticlePath('istana')))
        .last;
    expect(match.route.name, ExploreRouter.placeArticle.name);
  });
}
