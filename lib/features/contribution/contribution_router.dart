import 'package:go_router/go_router.dart';

import 'presentation/pages/bulk_contribute_page.dart';
import 'presentation/pages/contribute_page.dart';

/// Router form usul kata baru (`/contribute`). Daftar + detail status
/// milik user ada di `MyContributionsRouter` (`/contributions`).
class ContributionRouter {
  ContributionRouter._();

  static const contribute = GoRouteData._(
    path: '/contribute',
    name: 'ContributionRouter.contribute',
  );

  static const contributeBulk = GoRouteData._(
    path: '/contribute/bulk',
    name: 'ContributionRouter.contributeBulk',
  );

  static List<RouteBase> get routes => [
    GoRoute(
      path: contributeBulk.path,
      name: contributeBulk.name,
      builder: (context, state) {
        final q = state.uri.queryParameters;
        final correction = q['correction'] == '1' || q['correction'] == 'true';
        return BulkContributePage(
          initialLemma: q['lemma'],
          initialSearchIn: q['search_in'],
          initialSearchMissId: q['miss_id'] ?? q['search_miss_id'],
          spellCorrection: correction,
          contributeFrom: q['from'],
        );
      },
    ),
    GoRoute(
      path: contribute.path,
      name: contribute.name,
      builder: (context, state) {
        final q = state.uri.queryParameters;
        final lemma = q['lemma'];
        final searchIn = q['search_in'];
        final missId = q['miss_id'] ?? q['search_miss_id'];
        final correction = q['correction'] == '1' || q['correction'] == 'true';
        return ContributePage(
          initialLemma: lemma,
          initialSearchIn: searchIn,
          initialSearchMissId: missId,
          spellCorrection: correction,
          contributeFrom: q['from'],
        );
      },
    ),
  ];
}

class GoRouteData {
  const GoRouteData._({required this.path, required this.name});
  final String path;
  final String name;
}
