import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../domain/leaderboard_models.dart';

FTile leaderboardEntryTile({
  required BuildContext context,
  required LeaderboardEntry entry,
  required AppLocalizations l10n,
}) {
    final theme = context.theme;
    final rankStyle = theme.typography.body.sm.copyWith(
      fontWeight: FontWeight.w700,
      color: theme.colors.mutedForeground,
    );
    final nameStyle = theme.typography.body.md.copyWith(
      fontWeight: FontWeight.w600,
    );
    final scoreStyle = theme.typography.body.md.copyWith(
      fontWeight: FontWeight.w700,
      color: theme.colors.primary,
    );
    final breakdownStyle = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
    );

  return FTile(
    onPress: entry.username.isEmpty
        ? null
        : () => UserProfileRouter.open(context, entry.username),
    prefix: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 32,
          child: Text(
            l10n.balehoLeaderboardRank(entry.rank),
            style: rankStyle,
            textAlign: TextAlign.center,
          ),
        ),
        const Gap(8),
        UserAvatar(
          name: entry.username,
          imageUrl: entry.avatarUrl,
          size: 40,
        ),
      ],
    ),
    title: Text(entry.username, style: nameStyle),
    subtitle: Text(
      l10n.balehoLeaderboardScoreBreakdown(
        entry.contributions,
        entry.verifications,
      ),
      style: breakdownStyle,
    ),
    suffix: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          l10n.balehoLeaderboardScoreCombined(entry.combined),
          style: scoreStyle,
        ),
        if (entry.isVerifier)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: FBadge(
              variant: FBadgeVariant.outline,
              child: Text(l10n.balehoLeaderboardVerifierBadge),
            ),
          ),
      ],
    ),
  );
}