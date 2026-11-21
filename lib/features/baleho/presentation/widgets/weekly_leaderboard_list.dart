import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/leaderboard_models.dart';
import 'weekly_leaderboard_entry_tile.dart';

/// Kartu meta minggu / countdown - pakai [FTile] supaya icon+teks sejajar seragam.
class WeeklyLeaderboardMetaCard extends StatelessWidget {
  const WeeklyLeaderboardMetaCard({
    super.key,
    required this.theme,
    required this.icon,
    this.weekLabel,
    this.subtitle,
    this.onPress,
  });

  final FThemeData theme;
  final IconData icon;
  final String? weekLabel;
  final String? subtitle;
  final VoidCallback? onPress;

  @override
  Widget build(BuildContext context) {
    if (weekLabel == null && subtitle == null) {
      return const SizedBox.shrink();
    }
    return FTileGroup(
      children: [
        FTile(
          onPress: onPress,
          prefix: Icon(icon, size: 18, color: theme.colors.primary),
          title: Text(
            weekLabel ?? '',
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: subtitle == null
              ? null
              : Text(
                  subtitle!,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
        ),
      ],
    );
  }
}

/// Blok entri (podium + tile 4+) tanpa ListView luar - untuk disusun di parent.
List<Widget> weeklyLeaderboardEntryChildren({
  required BuildContext context,
  required List<LeaderboardEntry> entries,
  required AppLocalizations l10n,
  required FThemeData theme,
  required String emptyMessage,
}) {
  if (entries.isEmpty) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        child: Column(
          children: [
            Icon(
              FLucideIcons.trophy,
              size: 32,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  return [
    LeaderboardPodiumSection(entries: entries, l10n: l10n),
    if (entries.any((e) => e.rank > 3)) ...[
      const Gap(16),
      FTileGroup(
        children: [
          for (final entry in entries.where((e) => e.rank > 3))
            leaderboardEntryTile(
              context: context,
              entry: entry,
              l10n: l10n,
            ),
        ],
      ),
    ],
  ];
}

/// Daftar entri + podium juara 1-3.
class WeeklyLeaderboardEntryList extends StatelessWidget {
  const WeeklyLeaderboardEntryList({
    super.key,
    required this.entries,
    required this.l10n,
    required this.theme,
    this.header,
    required this.emptyMessage,
    this.trailing,
  });

  final List<LeaderboardEntry> entries;
  final AppLocalizations l10n;
  final FThemeData theme;
  final Widget? header;
  final String emptyMessage;
  final List<Widget>? trailing;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
      children: [
        if (header != null) ...[
          header!,
          const Gap(12),
        ],
        ...weeklyLeaderboardEntryChildren(
          context: context,
          entries: entries,
          l10n: l10n,
          theme: theme,
          emptyMessage: emptyMessage,
        ),
        ...?trailing,
      ],
    );
  }
}
