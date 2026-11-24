import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'domain/oss_license.dart';
import 'presentation/pages/about_page.dart';
import 'presentation/pages/oss_licenses_page.dart';

class AboutRouter {
  AboutRouter._();

  static const about = RouteDefiner(path: '/about', name: 'AboutRouter.about');

  static const sponsorshipTeam = RouteDefiner(
    path: '/about/sponsorship',
    name: 'AboutRouter.sponsorshipTeam',
  );

  static const ossLicenses = RouteDefiner(
    path: OssLicensesPage.path,
    name: 'AboutRouter.ossLicenses',
  );

  static const ossLicenseDetail = RouteDefiner(
    path: OssLicenseDetailPage.path,
    name: 'AboutRouter.ossLicenseDetail',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: about.path,
      name: about.name,
      builder: (context, state) => const AboutPage(),
    ),
    GoRoute(
      path: ossLicenses.path,
      name: ossLicenses.name,
      builder: (context, state) => const OssLicensesPage(),
    ),
    GoRoute(
      path: ossLicenseDetail.path,
      name: ossLicenseDetail.name,
      builder: (context, state) {
        final extra = state.extra;
        return OssLicenseDetailPage(
          license: extra is OssLicense ? extra : null,
        );
      },
    ),
    GoRoute(
      path: sponsorshipTeam.path,
      name: sponsorshipTeam.name,
      builder: (context, state) {
        final tab = state.uri.queryParameters['tab'];
        return SponsorshipTeamPage(showTeam: tab == 'team');
      },
    ),
  ];
}
