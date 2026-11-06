import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../features/user_profile/user_profile_router.dart';
import '../utils/public_account_name.dart';

/// Satu kontributor yang bisa diapresiasi (pengusul / fotografer).
@immutable
class ContributorCredit {
  const ContributorCredit({
    required this.username,
    required this.displayName,
  });

  final String username;
  final String displayName;
}

/// Container apresiasi kontributor di detail eksplorasi
/// (usaha / wisata / kuliner / acara).
///
/// Sembunyi total jika tidak ada username yang bisa dibuka ke profil.
class ContributorAppreciationSection extends StatelessWidget {
  const ContributorAppreciationSection({
    super.key,
    required this.label,
    required this.contributors,
  });

  /// Label baris, mis. "Diusulkan oleh".
  final String label;

  final List<ContributorCredit> contributors;

  @override
  Widget build(BuildContext context) {
    final linkable = [
      for (final c in contributors)
        if (isLinkablePublicUsername(c.username)) c,
    ];
    if (linkable.isEmpty) return const SizedBox.shrink();

    final theme = context.theme;
    final muted = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: muted),
          const Gap(6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final c in linkable)
                _ContributorChip(
                  username: c.username,
                  displayName: c.displayName,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContributorChip extends StatelessWidget {
  const _ContributorChip({
    required this.username,
    required this.displayName,
  });

  final String username;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    final label = displayPublicAccountLabel(
      displayName: displayName,
      username: username,
    );
    return Semantics(
      button: true,
      label: label,
      child: FTappable(
        onPress: () =>
            UserProfileRouter.open(context, username, displayName: label),
        child: FBadge(
          variant: FBadgeVariant.secondary,
          child: Text('@$username'),
        ),
      ),
    );
  }
}
