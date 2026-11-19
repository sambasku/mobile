import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../providers/meaning_vote_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/info_bottom_sheet.dart';
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

    // stretch: FDeterminateProgress hanya height-tight; tanpa stretch
    // Column(start) biarkan track menyusut ke lebar isi (bukan full width).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: VoteButtons(
            upvotes: upvotes,
            downvotes: downvotes,
            myVote: state.myVoteOf(meaningId),
            compact: true,
            onVote: (value) => _vote(context, ref, value),
          ),
        ),
        if (!isVerified) ...[
          const Gap(6),
          _VoteTrustProgress(
            upvotes: upvotes,
            downvotes: downvotes,
            label: l10n.voteTrustProgressLabel,
            info: l10n.voteTrustProgressInfo,
            infoSemantics: l10n.voteTrustProgressInfoSemantics,
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
    required this.info,
    required this.infoSemantics,
  });

  final int upvotes;
  final int downvotes;
  final String label;
  final String info;
  final String infoSemantics;

  static const double _infoIconSize = 14;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final muted = theme.colors.mutedForeground;
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FDeterminateProgress(
          value: value,
          style: const FDeterminateProgressStyleDelta.delta(
            // minWidth infinity = paksa track ambil lebar parent (Forui
            // default hanya height-tight, maxWidth unbounded → bisa menyusut).
            constraints: BoxConstraints(
              minWidth: double.infinity,
              minHeight: 4,
              maxHeight: 4,
            ),
          ),
          semanticsLabel: label,
        ),
        const Gap(4),
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                style: theme.typography.body.xs.copyWith(color: muted),
              ),
            ),
            const Gap(2),
            Semantics(
              button: true,
              label: infoSemantics,
              hint: info,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => showAppInfoSheet(
                  context,
                  title: label,
                  message: info,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    FLucideIcons.info,
                    size: _infoIconSize,
                    color: muted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
