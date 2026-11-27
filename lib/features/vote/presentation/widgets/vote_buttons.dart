import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/theme/f_colors_x.dart';
import '../../../../core/utils/format_number.dart';
import '../../../../l10n/app_localizations.dart';

/// Pasangan tombol upvote/downvote + count (state-icon murni, tanpa fetch).
///
/// Caller bertanggung jawab menyediakan counts/my_vote (mis. dari
/// VoteController atau controller komentar) dan guard login sebelum
/// memanggil [onVote]. Widget hanya: (1) menahan tap saat [busy], dan
/// (2) menanti future [onVote] selesai supaya tombol tidak double-tap.
class VoteButtons extends StatefulWidget {
  const VoteButtons({
    super.key,
    required this.upvotes,
    required this.downvotes,
    required this.myVote,
    required this.onVote,
    this.busy = false,
    this.compact = false,
    this.upvoteOnly = false,
  });

  final int upvotes;
  final int downvotes;

  /// 1 = upvote aktif, -1 = downvote aktif, null = belum memilih.
  final int? myVote;

  /// Dipanggil dengan arah pilihan user (1 | -1). Future selesai = toggle
  /// selesai (widget menahan tap selama dijalankan).
  final Future<void> Function(int value) onVote;

  final bool busy;
  final bool compact;

  /// Hanya tombol upvote (mis. pertanyaan ruang diskusi).
  final bool upvoteOnly;

  @override
  State<VoteButtons> createState() => _VoteButtonsState();
}

class _VoteButtonsState extends State<VoteButtons> {
  bool _inFlight = false;

  bool get _disabled => widget.busy || _inFlight;

  Future<void> _vote(int value) async {
    if (_disabled) return;
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
    final l10n = AppLocalizations.of(context);
    // Hijau = upvote, merah = downvote; idle abu. Dipakai di semua permukaan
    // vote (pantun, makna, komentar, diskusi, jinye) supaya arah beda jelas.
    final idle = theme.colors.mutedForeground;

    // ponytail: FittedBox scaleDown = kebal overflow apa pun penyebabnya
    // (data gila/constraint gila): muat → ukuran asli, kebesaran → menyusut.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        // Reddit-style: panah tebal atas/bawah (bukan thumbs).
        // Urutan wajib (mobile-base-stack 5f): turun kiri, naik kanan.
        children: [
          if (!widget.upvoteOnly) ...[
            _SideButton(
              icon: FLucideIcons.arrowBigDown,
              direction: -1,
              count: widget.downvotes,
              active: widget.myVote == -1,
              activeColor: theme.colors.destructive,
              idleColor: idle,
              compact: widget.compact,
              disabled: _disabled,
              label: l10n.voteSemanticsDownvote,
              onTap: () => _vote(-1),
            ),
            Gap(widget.compact ? 8 : 12),
          ],
          _SideButton(
            icon: FLucideIcons.arrowBigUp,
            direction: 1,
            count: widget.upvotes,
            active: widget.myVote == 1,
            activeColor: theme.colors.success,
            idleColor: idle,
            compact: widget.compact,
            disabled: _disabled,
            label: l10n.voteSemanticsUpvote,
            onTap: () => _vote(1),
          ),
        ],
      ),
    );
  }
}

/// Loading placeholder: dua pill (bentuk tombol vote).
/// Bungkus dengan [Skeletonizer] di caller bila belum ada.
class VoteButtonsSkeleton extends StatelessWidget {
  const VoteButtonsSkeleton({super.key, this.compact = true});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final h = compact ? 24.0 : 28.0;
    final w = compact ? 52.0 : 64.0;
    final gap = compact ? 8.0 : 12.0;
    final radius = BorderRadius.circular(8);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Bone(width: w, height: h, borderRadius: radius),
        Gap(gap),
        Bone(width: w, height: h, borderRadius: radius),
      ],
    );
  }
}

class _SideButton extends StatefulWidget {
  const _SideButton({
    required this.icon,
    required this.direction,
    required this.count,
    required this.active,
    required this.activeColor,
    required this.idleColor,
    required this.compact,
    required this.disabled,
    required this.label,
    required this.onTap,
  });

  final IconData icon;

  /// 1 = upvote (nudge atas), -1 = downvote (nudge bawah).
  final int direction;
  final int count;
  final bool active;
  final Color activeColor;
  final Color idleColor;
  final bool compact;
  final bool disabled;
  final String label;
  final VoidCallback onTap;

  @override
  State<_SideButton> createState() => _SideButtonState();
}

class _SideButtonState extends State<_SideButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _punch = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
    value: 1.0,
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.24,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.24,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOutBack)),
      weight: 65,
    ),
  ]).animate(_punch);

  late final Animation<double> _nudgeY = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 0.0,
        end: widget.direction > 0 ? -3.0 : 3.0,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 38,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: widget.direction > 0 ? -3.0 : 3.0,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.easeInOutCubic)),
      weight: 62,
    ),
  ]).animate(_punch);

  /// Arah perubahan count: +1 naik, -1 turun.
  int _countDelta = 1;

  @override
  void didUpdateWidget(covariant _SideButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count) {
      _countDelta = widget.count >= oldWidget.count ? 1 : -1;
    }
    // Punch hanya saat jadi aktif (vote), bukan un-vote atau build pertama.
    if (widget.active && !oldWidget.active) {
      if (!MediaQuery.disableAnimationsOf(context)) _punch.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _punch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final w = widget;
    final disableAnim = MediaQuery.disableAnimationsOf(context);
    final color = w.active ? w.activeColor : w.idleColor;
    final animDur = disableAnim
        ? Duration.zero
        : const Duration(milliseconds: 180);

    return Semantics(
      button: true,
      label: w.label,
      value: formatRibuan(w.count),
      // FScaffold/FCard forui tidak menyediakan ancestor Material - bungkus
      // sendiri supaya InkWell (dan ripple-nya) jalan di host mana pun.
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: w.disabled ? null : w.onTap,
          child: AnimatedContainer(
            duration: animDur,
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: w.active
                  ? w.activeColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Opacity(
              opacity: w.disabled ? 0.5 : 1,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: w.compact ? 10 : 12,
                  vertical: w.compact ? 6 : 8,
                ),
                child: ScaleTransition(
                  scale: _scale,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _nudgeY,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(0, _nudgeY.value),
                          child: child,
                        ),
                        child: Icon(
                          w.icon,
                          size: w.compact ? 14 : 16,
                          color: color,
                        ),
                      ),
                      const Gap(6),
                      AnimatedSwitcher(
                        duration: animDur,
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          if (disableAnim) return child;
                          final incoming = child.key == ValueKey(w.count);
                          final beginY = incoming
                              ? (_countDelta >= 0 ? 0.45 : -0.45)
                              : (_countDelta >= 0 ? -0.45 : 0.45);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(0, beginY),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          formatRibuan(w.count),
                          key: ValueKey(w.count),
                          style: theme.typography.body.sm.copyWith(
                            color: color,
                            fontWeight: w.active
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
