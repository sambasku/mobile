import 'package:sambasku_mobile/l10n/app_localizations.dart';

import 'entities/exploration_proposal.dart';

/// Alasan penolakan berkode (mirror API / console).
class ExplorationRejectReason {
  const ExplorationRejectReason({required this.code, required this.label});

  final String code;
  final String label;
}

List<ExplorationRejectReason> explorationRejectReasons(
  ExplorationReviewDomain domain,
  AppLocalizations l10n,
) {
  return switch (domain) {
    .usaha => [
      ExplorationRejectReason(
        code: 'duplicate',
        label: l10n.reviewExploreRejectUsahaDuplicate,
      ),
      ExplorationRejectReason(
        code: 'incomplete',
        label: l10n.reviewExploreRejectUsahaIncomplete,
      ),
      ExplorationRejectReason(
        code: 'invalid',
        label: l10n.reviewExploreRejectUsahaInvalid,
      ),
      ExplorationRejectReason(
        code: 'not_owner',
        label: l10n.reviewExploreRejectUsahaNotOwner,
      ),
      ExplorationRejectReason(
        code: 'stale',
        label: l10n.reviewExploreRejectUsahaStale,
      ),
      ExplorationRejectReason(
        code: 'violation',
        label: l10n.reviewExploreRejectUsahaViolation,
      ),
      ExplorationRejectReason(
        code: 'other',
        label: l10n.reviewExploreRejectOther,
      ),
    ],
    .place => [
      ExplorationRejectReason(
        code: 'not_suitable',
        label: l10n.reviewExploreRejectPlaceNotSuitable,
      ),
      ExplorationRejectReason(
        code: 'duplicate',
        label: l10n.reviewExploreRejectPlaceDuplicate,
      ),
      ExplorationRejectReason(
        code: 'inaccurate',
        label: l10n.reviewExploreRejectPlaceInaccurate,
      ),
      ExplorationRejectReason(
        code: 'other',
        label: l10n.reviewExploreRejectOther,
      ),
    ],
    .event => [
      ExplorationRejectReason(
        code: 'not_suitable',
        label: l10n.reviewExploreRejectEventNotSuitable,
      ),
      ExplorationRejectReason(
        code: 'duplicate',
        label: l10n.reviewExploreRejectEventDuplicate,
      ),
      ExplorationRejectReason(
        code: 'inaccurate',
        label: l10n.reviewExploreRejectEventInaccurate,
      ),
      ExplorationRejectReason(
        code: 'past_event',
        label: l10n.reviewExploreRejectEventPast,
      ),
      ExplorationRejectReason(
        code: 'other',
        label: l10n.reviewExploreRejectOther,
      ),
    ],
    .culinary => [
      ExplorationRejectReason(
        code: 'duplicate',
        label: l10n.reviewExploreRejectCulinaryDuplicate,
      ),
      ExplorationRejectReason(
        code: 'incomplete',
        label: l10n.reviewExploreRejectCulinaryIncomplete,
      ),
      ExplorationRejectReason(
        code: 'invalid',
        label: l10n.reviewExploreRejectCulinaryInvalid,
      ),
      ExplorationRejectReason(
        code: 'unverifiable',
        label: l10n.reviewExploreRejectCulinaryUnverifiable,
      ),
      ExplorationRejectReason(
        code: 'attribution',
        label: l10n.reviewExploreRejectCulinaryAttribution,
      ),
      ExplorationRejectReason(
        code: 'stale',
        label: l10n.reviewExploreRejectCulinaryStale,
      ),
      ExplorationRejectReason(
        code: 'violation',
        label: l10n.reviewExploreRejectCulinaryViolation,
      ),
      ExplorationRejectReason(
        code: 'other',
        label: l10n.reviewExploreRejectOther,
      ),
    ],
  };
}

String explorationKindLabel(
  ExplorationReviewDomain domain,
  String? kind,
  AppLocalizations l10n,
) {
  if (kind == null || kind.isEmpty) return l10n.reviewExploreKindGeneric;
  return switch (domain) {
    .usaha => switch (kind) {
      'new' => l10n.reviewExploreUsahaKindNew,
      'profile' => l10n.reviewExploreUsahaKindProfile,
      'item_add' => l10n.reviewExploreUsahaKindItemAdd,
      'item_edit' => l10n.reviewExploreUsahaKindItemEdit,
      'item_delete' => l10n.reviewExploreUsahaKindItemDelete,
      'operational' => l10n.reviewExploreUsahaKindOperational,
      'archive' => l10n.reviewExploreUsahaKindArchive,
      'restore' => l10n.reviewExploreUsahaKindRestore,
      _ => kind,
    },
    .culinary => switch (kind) {
      'new_cuisine' => l10n.reviewExploreCulinaryKindNewCuisine,
      'new_place' => l10n.reviewExploreCulinaryKindNewPlace,
      'link' => l10n.reviewExploreCulinaryKindLink,
      'cuisine_edit' => l10n.reviewExploreCulinaryKindCuisineEdit,
      'place_edit' => l10n.reviewExploreCulinaryKindPlaceEdit,
      'link_edit' => l10n.reviewExploreCulinaryKindLinkEdit,
      'place_operational' => l10n.reviewExploreCulinaryKindPlaceOperational,
      'archive' => l10n.reviewExploreCulinaryKindArchive,
      'restore' => l10n.reviewExploreCulinaryKindRestore,
      _ => kind,
    },
    .place => l10n.reviewExplorePlaceKindNew,
    .event => l10n.reviewExploreEventKindNew,
  };
}
