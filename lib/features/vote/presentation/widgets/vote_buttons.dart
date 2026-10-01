import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
    final enabled = theme.colors.primary;
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
              count: widget.downvotes,
              active: widget.myVote == -1,
              activeColor: enabled,
              idleColor: idle,
              compact: widget.compact,
              disabled: _disabled,
              label: 'Downvote',
              onTap: () => _vote(-1),
            ),
            Gap(widget.compact ? 8 : 12),
          ],
          _SideButton(
            icon: FLucideIcons.arrowBigUp,
            count: widget.upvotes,
            active: widget.myVote == 1,
            activeColor: enabled,
            idleColor: idle,
            compact: widget.compact,
            disabled: _disabled,
            label: 'Upvote',
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

class _SideButton extends StatelessWidget {
  const _SideButton({
    required this.icon,
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
  final int count;
  final bool active;
  final Color activeColor;
  final Color idleColor;
  final bool compact;
  final bool disabled;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final color = active ? activeColor : idleColor;

    return Semantics(
      button: true,
      label: label,
      value: '$count',
      // FScaffold/FCard forui tidak menyediakan ancestor Material - bungkus
      // sendiri supaya InkWell (dan ripple-nya) jalan di host mana pun.
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: disabled ? null : onTap,
          child: Opacity(
            opacity: disabled ? 0.5 : 1,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 10 : 12,
                vertical: compact ? 6 : 8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: compact ? 14 : 16, color: color),
                  const Gap(6),
                  Text(
                    '$count',
                    style: theme.typography.sm.copyWith(
                      color: color,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
