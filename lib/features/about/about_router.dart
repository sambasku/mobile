import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'presentation/pages/about_page.dart';

class AboutRouter {
  AboutRouter._();

  static const about = RouteDefiner(path: '/about', name: 'AboutRouter.about');

  static const sponsorshipTeam = RouteDefiner(
    path: '/about/sponsorship',
    name: 'AboutRouter.sponsorshipTeam',
  );

  static const contributors = RouteDefiner(
    path: '/about/contributors',
    name: 'AboutRouter.contributors',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: about.path,
      name: about.name,
      builder: (context, state) => const AboutPage(),
    ),
    GoRoute(
      path: sponsorshipTeam.path,
      name: sponsorshipTeam.name,
      builder: (context, state) => const SponsorshipTeamPage(),
    ),
    GoRoute(
      path: contributors.path,
      name: contributors.name,
      builder: (context, state) => const ContributorsListPage(),
    ),
  ];
}
