import 'package:flutter/widgets.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../dictionary/dictionary_router.dart';
import '../../domain/review_access.dart';
import '../../review_router.dart';
import '../providers/discussion_review_providers.dart';
import '../providers/review_providers.dart';
import '../providers/review_suggestions_providers.dart';
import '../utils/leave_review.dart';

/// Hub Area Verifikator: Mulai tinjau | Lengkapi kata | Usulan edit | Diskusi | Riwayat.
class ReviewHomePage extends ConsumerWidget {
  const ReviewHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authStatusProvider).value?.role;
    final showContribution = canReviewQueue(role);
    final showDiscussion = canModerateDiscussions(role);
    final contribPending = showContribution
        ? (ref.watch(reviewQueueHasPendingProvider).value ?? false)
        : false;
    final suggestionsPending = showContribution
        ? (ref.watch(reviewSuggestionsHasPendingProvider).value ?? false)
        : false;
    final discussionPending = showDiscussion
        ? (ref.watch(discussionReviewHasPendingProvider).value ?? false)
        : false;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) leaveReview(context);
      },
      child: FScaffold(
        childPad: true,
        header: FHeader.nested(
          title: Text(AppLocalizations.of(context).commonVerifierArea),
          prefixes: [FHeaderAction.back(onPress: () => leaveReview(context))],
        ),
        // Align mengendurkan tinggi. Tanpa ini FScaffold memaksa FTileGroup
        // mengisi layar, kartu memanjang, dan border bawah tidak ketat di item.
        child: Align(
          alignment: Alignment.topCenter,
          child: FTileGroup(
            children: [
              if (showContribution)
                FTile(
                  prefix: Icon(FLucideIcons.play),
                  title: Text(AppLocalizations.of(context).reviewHomeStart),
                  subtitle: contribPending
                      ? Text(AppLocalizations.of(context).reviewHomeContributionTitle)
                      : Text(AppLocalizations.of(context).reviewHomeContributionSubtitle),
                  suffix: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (contribPending) const _PendingDot(),
                      const Icon(FLucideIcons.chevronRight),
                    ],
                  ),
                  onPress: () => context.push(ReviewRouter.queue.path),
                ),
              // Diletakkan tepat setelah CTA utama: kemampuan enriching
              // adalah bagian dari pekerjaan verifikator, tapi bukan
              // antrean, jadi tidak boleh mendominasi posisi pertama.
              if (showContribution)
                FTile(
                  prefix: Icon(FLucideIcons.sparkles),
                  title: Text(AppLocalizations.of(context).reviewHomeCompleteWordTitle),
                  subtitle: Text(
                    AppLocalizations.of(context).reviewHomeCompleteWordSubtitle,
                  ),
                  suffix: const Icon(FLucideIcons.chevronRight),
                  onPress: () => context.push(DictionaryRouter.complete.path),
                ),
              if (showContribution)
                FTile(
                  prefix: Icon(FLucideIcons.pencilLine),
                  title: Text(AppLocalizations.of(context).reviewHomeSuggestionTitle),
                  subtitle: suggestionsPending
                      ? Text(AppLocalizations.of(context).reviewHomeSuggestionWaiting)
                      : Text(AppLocalizations.of(context).reviewHomeSuggestionSubtitle),
                  suffix: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (suggestionsPending) const _PendingDot(),
                      const Icon(FLucideIcons.chevronRight),
                    ],
                  ),
                  onPress: () => context.push(ReviewRouter.suggestions.path),
                ),
              if (showDiscussion)
                FTile(
                  prefix: Icon(FLucideIcons.messagesSquare),
                  title: Text(AppLocalizations.of(context).reviewHomeDiscussionTitle),
                  subtitle: discussionPending
                      ? Text(AppLocalizations.of(context).reviewHomeDiscussionWaiting)
                      : Text(AppLocalizations.of(context).reviewHomeDiscussionSubtitle),
                  suffix: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (discussionPending) const _PendingDot(),
                      const Icon(FLucideIcons.chevronRight),
                    ],
                  ),
                  onPress: () => context.push(ReviewRouter.discussions.path),
                ),
              // #88: gerbang tayang pencarian kosong + peluang usul langsung.
              if (showContribution)
                FTile(
                  prefix: Icon(FLucideIcons.search),
                  title: Text(AppLocalizations.of(context).reviewHomeSearchMissTitle),
                  subtitle: Text(
                    AppLocalizations.of(context).reviewHomeSearchMissSubtitle,
                  ),
                  suffix: const Icon(FLucideIcons.chevronRight),
                  onPress: () => context.push(ReviewRouter.searchMisses.path),
                ),
              if (showContribution)
                FTile(
                  prefix: Icon(FLucideIcons.history),
                  title: Text(AppLocalizations.of(context).reviewHomeHistoryTitle),
                  subtitle: Text(AppLocalizations.of(context).reviewHomeHistorySubtitle),
                  suffix: const Icon(FLucideIcons.chevronRight),
                  onPress: () => context.push(ReviewRouter.history.path),
                ),
            ],
          ),
        ),
      ),
    );
  }
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
