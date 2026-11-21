import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/f_colors_x.dart';

/// Latar idle / aktif setengah kolom vote (tanpa border tengah).
/// Sudut setengah vote: rail kartu (kanan), footer detail (kiri+kanan bawah), atau flat.
enum PeriksaVoteSplitCornerMode { rail, footer, embedded }

abstract final class PeriksaVoteHalfColors {
  static const idleFillAlpha = 0.05;
  static const activeFillAlpha = 0.26;

  static Color fill(Color accent, {required bool active}) =>
      accent.withValues(alpha: active ? activeFillAlpha : idleFillAlpha);

  static Color foreground(Color accent, {required bool active}) =>
      active ? accent : accent.withValues(alpha: 0.72);
}

/// Dua tombol ghost memenuhi kolom vote (50% kiri / 50% kanan, full bleed).
class PeriksaVoteSplitPanel extends StatefulWidget {
  const PeriksaVoteSplitPanel({
    super.key,
    required this.upvotes,
    required this.downvotes,
    required this.myVote,
    required this.disagreeSemantics,
    required this.agreeSemantics,
    required this.onVote,
    this.cornerRadius = 10,
    this.cornerMode = PeriksaVoteSplitCornerMode.rail,
    this.dense = false,
  });

  final int upvotes;
  final int downvotes;
  final int? myVote;
  final String disagreeSemantics;
  final String agreeSemantics;
  final Future<void> Function(int value) onVote;
  final double cornerRadius;
  final PeriksaVoteSplitCornerMode cornerMode;

  /// Padat (footer detail): ikon lebih kecil; pakai [SizedBox] dengan tinggi
  /// tetap di parent supaya [CrossAxisAlignment.stretch] aman.
  final bool dense;

  @override
  State<PeriksaVoteSplitPanel> createState() => _PeriksaVoteSplitPanelState();
}

class _PeriksaVoteSplitPanelState extends State<PeriksaVoteSplitPanel> {
  bool _inFlight = false;

  Future<void> _tap(int value) async {
    if (_inFlight) return;
    unawaited(HapticFeedback.mediumImpact());
    setState(() => _inFlight = true);
    try {
      await widget.onVote(value);
    } finally {
      if (mounted) setState(() => _inFlight = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final enabled = !_inFlight;
    final r = Radius.circular(widget.cornerRadius);
    final downRadius = switch (widget.cornerMode) {
      PeriksaVoteSplitCornerMode.rail => BorderRadius.zero,
      PeriksaVoteSplitCornerMode.footer =>
        BorderRadius.only(bottomLeft: r),
      PeriksaVoteSplitCornerMode.embedded => BorderRadius.zero,
    };
    final upRadius = switch (widget.cornerMode) {
      PeriksaVoteSplitCornerMode.rail =>
        BorderRadius.only(topRight: r, bottomRight: r),
      PeriksaVoteSplitCornerMode.footer =>
        BorderRadius.only(bottomRight: r),
      PeriksaVoteSplitCornerMode.embedded => BorderRadius.zero,
    };
  // stretch di rail (IntrinsicHeight) atau dense + tinggi terikat di parent.
  final stretch =
      widget.cornerMode == PeriksaVoteSplitCornerMode.rail || widget.dense;
  return Row(
    crossAxisAlignment:
        stretch ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
    children: [
      Expanded(
        child: _PeriksaGhostVoteHalf(
          icon: FLucideIcons.arrowBigDown,
          count: widget.downvotes,
          active: widget.myVote == -1,
          accent: theme.colors.destructive,
          enabled: enabled,
          semanticsLabel: widget.disagreeSemantics,
          backgroundRadius: downRadius,
          dense: widget.dense,
          onPress: () => _tap(-1),
        ),
      ),
      Expanded(
        child: _PeriksaGhostVoteHalf(
          icon: FLucideIcons.arrowBigUp,
          count: widget.upvotes,
          active: widget.myVote == 1,
          accent: theme.colors.success,
          enabled: enabled,
          semanticsLabel: widget.agreeSemantics,
          backgroundRadius: upRadius,
          dense: widget.dense,
          onPress: () => _tap(1),
        ),
      ),
    ],
  );
  }
}

class _PeriksaGhostVoteHalf extends StatelessWidget {
  const _PeriksaGhostVoteHalf({
    required this.icon,
    required this.count,
    required this.active,
    required this.accent,
    required this.enabled,
    required this.semanticsLabel,
    required this.backgroundRadius,
    required this.onPress,
    this.dense = false,
  });

  final IconData icon;
  final int count;
  final bool active;
  final Color accent;
  final bool enabled;
  final String semanticsLabel;
  final BorderRadius backgroundRadius;
  final VoidCallback onPress;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final fg = PeriksaVoteHalfColors.foreground(accent, active: active);
    final bg = PeriksaVoteHalfColors.fill(accent, active: active);
    final iconSize = dense ? 18.0 : 22.0;
    final countBase = theme.typography.body.xs;
    final countStyle =
        dense ? countBase.copyWith(fontSize: 11) : countBase;

    final label = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: fg),
        Gap(dense ? 0 : 2),
        Text(
          '$count',
          style: countStyle.copyWith(
            color: fg,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      label: semanticsLabel,
      value: '$count',
      child: Opacity(
        opacity: enabled || active ? 1 : 0.55,
        child: ClipRRect(
          borderRadius: backgroundRadius,
          child: DecoratedBox(
            decoration: BoxDecoration(color: bg),
            child: FTappable(
              onPress: enabled ? onPress : null,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: dense ? 4 : 14,
                  horizontal: 4,
                ),
                child: Center(child: label),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
