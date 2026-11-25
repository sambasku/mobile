import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../core/utils/format_number.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../domain/leaderboard_models.dart';

class _PodiumPalette {
  const _PodiumPalette({
    required this.metal,
    required this.metalSoft,
    required this.icon,
  });

  final Color metal;
  final Color metalSoft;
  final IconData icon;
}

_PodiumPalette? _podiumPalette(int rank) {
  return switch (rank) {
    1 => const _PodiumPalette(
        metal: Color(0xFFC9A227),
        metalSoft: Color(0x33C9A227),
        icon: FLucideIcons.crown,
      ),
    2 => const _PodiumPalette(
        metal: Color(0xFF8A8F98),
        metalSoft: Color(0x338A8F98),
        icon: FLucideIcons.medal,
      ),
    3 => const _PodiumPalette(
        metal: Color(0xFFB87333),
        metalSoft: Color(0x33B87333),
        icon: FLucideIcons.award,
      ),
    _ => null,
  };
}

/// Section peringkat 1-3: kartu compact horizontal.
class LeaderboardPodiumSection extends StatelessWidget {
  const LeaderboardPodiumSection({
    super.key,
    required this.entries,
    required this.l10n,
  });

  final List<LeaderboardEntry> entries;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final podium = entries.where((e) => e.rank >= 1 && e.rank <= 3).toList()
      ..sort((a, b) => a.rank.compareTo(b.rank));
    if (podium.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              FLucideIcons.sparkles,
              size: 14,
              color: theme.colors.primary,
            ),
            const Gap(6),
            Text(
              l10n.balehoLeaderboardPodiumTitle,
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Gap(8),
        for (var i = 0; i < podium.length; i++) ...[
          if (i > 0) const Gap(8),
          _PodiumCompactCard(entry: podium[i], l10n: l10n),
        ],
      ],
    );
  }
}

class _PodiumCompactCard extends StatelessWidget {
  const _PodiumCompactCard({required this.entry, required this.l10n});

  final LeaderboardEntry entry;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = _podiumPalette(entry.rank)!;
    final isFirst = entry.rank == 1;
    final onPress = entry.username.isEmpty
        ? null
        : () => UserProfileRouter.open(context, entry.username);

    return FTappable(
      onPress: onPress,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: isFirst ? 10 : 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: palette.metal.withValues(alpha: isFirst ? 0.9 : 0.65),
            width: isFirst ? 1.5 : 1,
          ),
          color: palette.metalSoft,
        ),
        child: Row(
          children: [
            _AvatarRing(
              entry: entry,
              metal: palette.metal,
              size: isFirst ? 40 : 36,
              ringWidth: isFirst ? 2 : 1.5,
            ),
            const Gap(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(palette.icon, size: 12, color: palette.metal),
                      const Gap(4),
                      Flexible(
                        child: Text(
                          l10n.balehoLeaderboardPodiumPlace(entry.rank),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.body.xs.copyWith(
                            fontWeight: FontWeight.w800,
                            color: palette.metal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(2),
                  Text(
                    entry.displayName ?? entry.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(1),
                  Text(
                    l10n.balehoLeaderboardScoreBreakdown(
                      formatRibuan(entry.submittedPoints),
                      formatRibuan(entry.approvedPoints),
                      formatRibuan(entry.verificationPoints),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.xs.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.balehoLeaderboardScoreCombined(
                    formatRibuan(entry.combined),
                  ),
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w800,
                    color: palette.metal,
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarRing extends StatelessWidget {
  const _AvatarRing({
    required this.entry,
    required this.metal,
    required this.size,
    required this.ringWidth,
  });

  final LeaderboardEntry entry;
  final Color metal;
  final double size;
  final double ringWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ringWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: metal, width: ringWidth),
      ),
      child: UserAvatar(
        name: entry.username,
        imageUrl: entry.avatarUrl,
        size: size,
      ),
    );
  }
}

/// Satu baris papan peringkat (peringkat 4+ di dalam [FTileGroup]).
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
  final breakdown = l10n.balehoLeaderboardScoreBreakdown(
    formatRibuan(entry.submittedPoints),
    formatRibuan(entry.approvedPoints),
    formatRibuan(entry.verificationPoints),
  );
  final subtitleText = breakdown;

  return FTile(
    onPress: entry.username.isEmpty
        ? null
        : () => UserProfileRouter.open(context, entry.username),
    prefix: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 36,
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
    title: Text(entry.displayName ?? entry.username, style: nameStyle),
    subtitle: Text(subtitleText, style: breakdownStyle),
    suffix: Text(
      l10n.balehoLeaderboardScoreCombined(formatRibuan(entry.combined)),
      style: scoreStyle,
    ),
  );
}
