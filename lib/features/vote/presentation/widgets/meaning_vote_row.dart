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
          VoteTrustProgress(
            upvotes: upvotes,
            downvotes: downvotes,
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

/// Bar tug-of-war Voting Warga: kiri hijau (setuju) vs kanan merah (kurang setuju).
class VoteTrustProgress extends StatelessWidget {
  const VoteTrustProgress({
    super.key,
    required this.upvotes,
    required this.downvotes,
    this.barHeight = 6,
  });

  final int upvotes;
  final int downvotes;
  final double barHeight;

  // Tipis / pudar - cukup terbaca, tidak mencolok.
  static const Color _upFill = Color(0x6686EFAC); // green-300 ~40%
  static const Color _downFill = Color(0x66FECACA); // red-200 ~40%
  static const Color _upEmpty = Color(0x4DBBF7D0); // green-200 ~30%
  static const Color _downEmpty = Color(0x4DFEE2E2); // red-100 ~30%
  static const Color _divider = Color(0x44FFFFFF);

  @override
  Widget build(BuildContext context) {
    final total = upvotes + downvotes;
    final upRatio = total == 0
        ? 0.5
        : (upvotes <= 0 ? 0.0 : (downvotes <= 0 ? 1.0 : upvotes / total));
    final upColor = total == 0 ? _upEmpty : _upFill;
    final downColor = total == 0 ? _downEmpty : _downFill;

    return Semantics(
      label: AppLocalizations.of(context).voteTrustProgressLabel,
      value: '$upvotes / $downvotes',
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: upRatio),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        builder: (context, animatedRatio, _) {
          return SizedBox(
            height: barHeight,
            width: double.infinity,
            child: CustomPaint(
              painter: _VoteFightBarPainter(
                upRatio: animatedRatio,
                upColor: upColor,
                downColor: downColor,
                dividerColor: _divider,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VoteFightBarPainter extends CustomPainter {
  const _VoteFightBarPainter({
    required this.upRatio,
    required this.upColor,
    required this.downColor,
    required this.dividerColor,
  });

  final double upRatio;
  final Color upColor;
  final Color downColor;
  final Color dividerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, radius);

    canvas.save();
    canvas.clipRRect(rrect);

    final split = (size.width * upRatio.clamp(0.0, 1.0)).clamp(0.0, size.width);
    if (split > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, split, size.height),
        Paint()..color = upColor,
      );
    }
    if (split < size.width) {
      canvas.drawRect(
        Rect.fromLTWH(split, 0, size.width - split, size.height),
        Paint()..color = downColor,
      );
    }
    if (split > 1 && split < size.width - 1) {
      canvas.drawRect(
        Rect.fromLTWH(split - 0.75, 0, 1.5, size.height),
        Paint()..color = dividerColor,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VoteFightBarPainter oldDelegate) {
    return oldDelegate.upRatio != upRatio ||
        oldDelegate.upColor != upColor ||
        oldDelegate.downColor != downColor;
  }
}
