import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/exploration_proposal.dart';
import '../../review_router.dart';
import '../providers/exploration_review_providers.dart';

/// Submenu usulan eksplorasi. Hub verifikator hanya menampilkan satu baris.
class ExplorationReviewHubPage extends ConsumerWidget {
  const ExplorationReviewHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final usahaPending = _pending(ref, ExplorationReviewDomain.usaha);
    final placePending = _pending(ref, ExplorationReviewDomain.place);
    final culinaryPending = _pending(ref, ExplorationReviewDomain.culinary);
    final eventPending = _pending(ref, ExplorationReviewDomain.event);
    final layananPending = _pending(ref, ExplorationReviewDomain.layanan);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.reviewHomeExploreTitle),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: FTileGroup(
          children: [
            _domainTile(
              icon: FLucideIcons.store,
              title: l10n.reviewHomeUsahaTitle,
              subtitle: usahaPending
                  ? l10n.reviewHomeUsahaWaiting
                  : l10n.reviewHomeUsahaSubtitle,
              pending: usahaPending,
              onPress: () => context.push(ReviewRouter.usaha.path),
            ),
            _domainTile(
              icon: FLucideIcons.mapPin,
              title: l10n.reviewHomePlaceTitle,
              subtitle: placePending
                  ? l10n.reviewHomePlaceWaiting
                  : l10n.reviewHomePlaceSubtitle,
              pending: placePending,
              onPress: () => context.push(ReviewRouter.places.path),
            ),
            _domainTile(
              icon: FLucideIcons.utensilsCrossed,
              title: l10n.reviewHomeCulinaryTitle,
              subtitle: culinaryPending
                  ? l10n.reviewHomeCulinaryWaiting
                  : l10n.reviewHomeCulinarySubtitle,
              pending: culinaryPending,
              onPress: () => context.push(ReviewRouter.culinary.path),
            ),
            _domainTile(
              icon: FLucideIcons.calendar,
              title: l10n.reviewHomeEventTitle,
              subtitle: eventPending
                  ? l10n.reviewHomeEventWaiting
                  : l10n.reviewHomeEventSubtitle,
              pending: eventPending,
              onPress: () => context.push(ReviewRouter.events.path),
            ),
            _domainTile(
              icon: FLucideIcons.phone,
              title: l10n.reviewHomeLayananTitle,
              subtitle: layananPending
                  ? l10n.reviewHomeLayananWaiting
                  : l10n.reviewHomeLayananSubtitle,
              pending: layananPending,
              onPress: () => context.push(ReviewRouter.layanan.path),
            ),
          ],
        ),
      ),
    );
  }

  bool _pending(WidgetRef ref, ExplorationReviewDomain domain) {
    return ref.watch(explorationHasPendingProvider(domain)).value ?? false;
  }
}

FTile _domainTile({
  required IconData icon,
  required String title,
  required String subtitle,
  required bool pending,
  required VoidCallback onPress,
}) {
  return FTile(
    prefix: Icon(icon),
    title: Text(title),
    subtitle: Text(subtitle),
    suffix: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (pending) const _PendingDot(),
        const Icon(FLucideIcons.chevronRight),
      ],
    ),
    onPress: onPress,
  );
}

class _PendingDot extends StatelessWidget {
  const _PendingDot();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(right: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFFF59E0B),
          shape: BoxShape.circle,
        ),
        child: SizedBox(width: 8, height: 8),
      ),
    );
  }
}
