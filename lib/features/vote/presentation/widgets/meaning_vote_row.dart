import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../providers/meaning_vote_providers.dart';
import '../../../../l10n/app_localizations.dart';
import 'vote_buttons.dart';

/// Ambang Voting Warga (selaras api voting-warga.ts).
const int kVotingWargaNetThreshold = 5;

/// Tombol vote untuk satu baris makna (upvote/downvote + jumlah).
///
/// State diambil dari [MeaningVotesController] (batch per kata, bukan
/// per makna) supaya N makna = 2 request, bukan 2×N.
///
/// Bila [isVerified] false: progress bar menuju ambang auto-verif (G2).
class MeaningVoteRow extends ConsumerWidget {
  const MeaningVoteRow({
    super.key,
    required this.meaningId,
    this.isVerified = false,
  });

  final String meaningId;

  /// Makna sudah terverifikasi → progress bar disembunyikan.
  final bool isVerified;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(meaningVotesControllerProvider);
    final upvotes = state.upvotesOf(meaningId);
    final downvotes = state.downvotesOf(meaningId);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VoteButtons(
          upvotes: upvotes,
          downvotes: downvotes,
          myVote: state.myVoteOf(meaningId),
          compact: true,
          onVote: (value) => _vote(context, ref, value),
        ),
        if (!isVerified) ...[
          const Gap(6),
          _VoteTrustProgress(
            upvotes: upvotes,
            downvotes: downvotes,
            label: l10n.voteTrustProgressLabel,
          ),
        ],
      ],
    );
  }

  Future<void> _vote(BuildContext context, WidgetRef ref, int value) async {
    final auth = ref.read(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) {
      showFToast(
        context: context,
        title: Text(AppLocalizations.of(context).voteLoginPrompt),
        variant: FToastVariant.primary,
      );
      context.push('/login');
      return;
    }
    final failure = await ref
        .read(meaningVotesControllerProvider.notifier)
        .toggle(meaningId, value);
    if (failure != null && context.mounted) {
      showFToast(
        context: context,
        title: Text(failure.message),
        variant: FToastVariant.destructive,
      );
    }
  }
}

class _VoteTrustProgress extends StatelessWidget {
  const _VoteTrustProgress({
    required this.upvotes,
    required this.downvotes,
    required this.label,
  });

  final int upvotes;
  final int downvotes;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final net = upvotes - downvotes;
    final unique = upvotes + downvotes;
    final netProgress = (net <= 0)
        ? 0.0
        : math.min(1.0, net / kVotingWargaNetThreshold);
    final uniqueProgress = math.min(
      1.0,
      unique / kVotingWargaNetThreshold,
    );
    // Binding constraint: keduanya harus mencapai ambang.
    final value = math.min(netProgress, uniqueProgress);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FDeterminateProgress(
          value: value,
          style: const FDeterminateProgressStyleDelta.delta(
            constraints: BoxConstraints.tightFor(height: 4),
          ),
          semanticsLabel: label,
        ),
        const Gap(4),
        Text(
          label,
          style: theme.typography.body.xs.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      ],
    );
  }
}
