import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/review/domain/entities/exploration_proposal.dart';
import 'package:sambasku_mobile/features/review/domain/exploration_reject_reasons.dart';
import 'package:sambasku_mobile/l10n/app_localizations_id.dart';

void main() {
  final l10n = AppLocalizationsId();

  test('usaha reject reasons include coded options + other', () {
    final reasons = explorationRejectReasons(
      ExplorationReviewDomain.usaha,
      l10n,
    );
    expect(reasons.map((r) => r.code), containsAll([
      'duplicate',
      'incomplete',
      'invalid',
      'not_owner',
      'stale',
      'violation',
      'other',
    ]));
  });

  test('place has no revision support; others do', () {
    expect(ExplorationReviewDomain.place.supportsRevision, isFalse);
    expect(ExplorationReviewDomain.usaha.supportsRevision, isTrue);
    expect(ExplorationReviewDomain.event.supportsRevision, isTrue);
    expect(ExplorationReviewDomain.culinary.supportsRevision, isTrue);
    expect(ExplorationReviewDomain.layanan.supportsRevision, isTrue);
  });

  test('api path segments match admin mounts', () {
    expect(
      ExplorationReviewDomain.usaha.apiPathSegment,
      'usaha-contributions',
    );
    expect(
      ExplorationReviewDomain.place.apiPathSegment,
      'place-contributions',
    );
    expect(
      ExplorationReviewDomain.event.apiPathSegment,
      'event-contributions',
    );
    expect(
      ExplorationReviewDomain.culinary.apiPathSegment,
      'culinary-contributions',
    );
    expect(
      ExplorationReviewDomain.layanan.apiPathSegment,
      'layanan-contributions',
    );
  });

  test('layanan reject reasons match API codes', () {
    final reasons = explorationRejectReasons(
      ExplorationReviewDomain.layanan,
      l10n,
    );
    expect(reasons.map((r) => r.code), [
      'invalid_phone',
      'wrong_region',
      'duplicate',
      'other',
    ]);
  });

  test('kind labels cover usaha new + culinary new_cuisine + layanan', () {
    expect(
      explorationKindLabel(ExplorationReviewDomain.usaha, 'new', l10n),
      l10n.reviewExploreUsahaKindNew,
    );
    expect(
      explorationKindLabel(
        ExplorationReviewDomain.culinary,
        'new_cuisine',
        l10n,
      ),
      l10n.reviewExploreCulinaryKindNewCuisine,
    );
    expect(
      explorationKindLabel(ExplorationReviewDomain.layanan, 'new', l10n),
      l10n.reviewExploreLayananKindNew,
    );
    expect(
      explorationKindLabel(ExplorationReviewDomain.layanan, 'edit', l10n),
      l10n.reviewExploreLayananKindEdit,
    );
  });
}
