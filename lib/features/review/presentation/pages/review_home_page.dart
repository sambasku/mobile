import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/review_access.dart';
import '../../review_router.dart';
import '../providers/discussion_review_providers.dart';
import '../providers/review_providers.dart';
import '../providers/review_suggestions_providers.dart';
import '../utils/leave_review.dart';

/// Hub Area Verifikator: Mulai tinjau | Usulan edit | Tinjauan Diskusi | Riwayat.
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
          title: const Text('Area Verifikator'),
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
                  prefix: const Icon(FLucideIcons.play),
                  title: const Text('Mulai tinjau'),
                  subtitle: contribPending
                      ? const Text('Ada usulan yang menunggu')
                      : const Text('Antrean kontribusi untuk ditinjau'),
                  suffix: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (contribPending) const _PendingDot(),
                      const Icon(FLucideIcons.chevronRight),
                    ],
                  ),
                  onPress: () => context.push(ReviewRouter.queue.path),
                ),
              if (showContribution)
                FTile(
                  prefix: const Icon(FLucideIcons.pencilLine),
                  title: const Text('Usulan edit'),
                  subtitle: suggestionsPending
                      ? const Text('Ada usulan edit yang menunggu')
                      : const Text('Antrean usulan perubahan kata'),
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
                  prefix: const Icon(FLucideIcons.messagesSquare),
                  title: const Text('Tinjauan Diskusi'),
                  subtitle: discussionPending
                      ? const Text('Ada diskusi yang menunggu')
                      : const Text('Antrean Ruang Diskusi untuk ditinjau'),
                  suffix: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (discussionPending) const _PendingDot(),
                      const Icon(FLucideIcons.chevronRight),
                    ],
                  ),
                  onPress: () => context.push(ReviewRouter.discussions.path),
                ),
              if (showContribution)
                FTile(
                  prefix: const Icon(FLucideIcons.history),
                  title: const Text('Riwayat tinjauan'),
                  subtitle: const Text('Keputusan yang sudah Anda berikan'),
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
