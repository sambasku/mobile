import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../core/theme/f_colors_x.dart';
import '../../core/widgets/verified_badge_icon.dart';

/// Baris "angka label" stat profil ala feed: count bold + label muted,
/// dipisah titik tengah. Dipakai tab Profil + profil publik.
class ProfileStatInline extends StatelessWidget {
  const ProfileStatInline({
    super.key,
    required this.count,
    required this.label,
  });

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$count',
            style: theme.typography.sm.copyWith(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: ' $label',
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Titik pemisah antar item stat.
class ProfileStatDot extends StatelessWidget {
  const ProfileStatDot({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 3),
    child: Text(
      '·',
      style: context.theme.typography.sm.copyWith(
        color: context.theme.colors.mutedForeground,
      ),
    ),
  );
}

/// Baris lengkap 3 stat profil: kontribusi · verifikasi · komentar.
class ProfileStatRow extends StatelessWidget {
  const ProfileStatRow({
    super.key,
    required this.contributions,
    required this.verifications,
    required this.comments,
  });

  final int contributions;
  final int verifications;
  final int comments;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 0,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ProfileStatInline(count: contributions, label: 'kontribusi'),
        const ProfileStatDot(),
        ProfileStatInline(count: verifications, label: 'verifikasi'),
        const ProfileStatDot(),
        ProfileStatInline(count: comments, label: 'komentar'),
      ],
    );
  }
}

/// Meta profil: Bergabung, lalu badge Verifikator di baris sendiri.
class ProfileMetaRow extends StatelessWidget {
  const ProfileMetaRow({
    super.key,
    required this.joinedLabel,
    required this.isVerifier,
  });

  final String joinedLabel;
  final bool isVerifier;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final hasJoined = joinedLabel.trim().isNotEmpty;
    if (!hasJoined && !isVerifier) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 2,
      children: [
        if (hasJoined)
          Text(
            'Bergabung $joinedLabel',
            style: theme.typography.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        if (isVerifier)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              const VerifiedBadgeIcon(size: 12),
              Text(
                'Verifikator',
                style: theme.typography.xs.copyWith(
                  color: theme.colors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
