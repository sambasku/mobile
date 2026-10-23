import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

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
            style: theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: ' $label',
            style: theme.typography.body.sm.copyWith(
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
      style: context.theme.typography.body.sm.copyWith(
        color: context.theme.colors.mutedForeground,
      ),
    ),
  );
}

/// Baris lengkap 2 stat profil: usul kata · perbaikan.
class ProfileStatRow extends StatelessWidget {
  const ProfileStatRow({
    super.key,
    required this.words,
    required this.corrections,
  });

  final int words;
  final int corrections;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 0,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ProfileStatInline(count: words, label: 'usul kata'),
        const ProfileStatDot(),
        ProfileStatInline(count: corrections, label: 'perbaikan'),
      ],
    );
  }
}

/// Meta profil: Bergabung + centang hijau verifikator. Label teks
/// "Verifikator" dihapus - ikon mewakilinya, tap ikon membuka penjelasan.
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 3,
      children: [
        if (hasJoined)
          Text(
            'Bergabung $joinedLabel',
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        if (isVerifier)
          VerifiedBadgeIcon(
            size: 12,
            onTap: () => showVerifierBadgeInfo(context),
          ),
      ],
    );
  }
}
