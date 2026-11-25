import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/leaderboard_models.dart';
import 'weekly_leaderboard_entry_tile.dart';

/// Tab internal papan peringkat (ganti [FTabs]).
enum WeeklyLeaderboardSection { current, history }

/// Chip pemilih Minggu ini / Riwayat - pola sama feed beranda ([_FeedCategoryChips]).
class WeeklyLeaderboardSectionChips extends StatelessWidget {
  const WeeklyLeaderboardSectionChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final WeeklyLeaderboardSection selected;
  final ValueChanged<WeeklyLeaderboardSection> onChanged;

  static const height = 32.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <(WeeklyLeaderboardSection, String)>[
      (WeeklyLeaderboardSection.current, l10n.balehoLeaderboardTabCurrent),
      (WeeklyLeaderboardSection.history, l10n.balehoLeaderboardTabHistory),
    ];
    return ColoredBox(
      color: context.theme.colors.background,
      child: SizedBox(
        height: height,
        child: ListView.separated(
          key: const ValueKey('leaderboard_section_chips'),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(0, 2, 0, 8),
          itemCount: items.length,
          separatorBuilder: (_, _) => const Gap(6),
          itemBuilder: (context, i) {
            final (section, label) = items[i];
            final isSelected = section == selected;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(section),
              child: FBadge(
                variant: isSelected
                    ? FBadgeVariant.primary
                    : FBadgeVariant.secondary,
                child: Text(label),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Minggu berjalan + pintu ke halaman poin dalam satu kartu ringkas.
class WeeklyLeaderboardStatusCard extends StatelessWidget {
  const WeeklyLeaderboardStatusCard({
    super.key,
    required this.theme,
    required this.l10n,
    this.weekLabel,
    this.statusLine,
    this.onOpenPointsGuide,
  });

  final FThemeData theme;
  final AppLocalizations l10n;
  final String? weekLabel;
  final String? statusLine;
  final VoidCallback? onOpenPointsGuide;

  @override
  Widget build(BuildContext context) {
    if ((weekLabel == null || weekLabel!.isEmpty) &&
        (statusLine == null || statusLine!.isEmpty) &&
        onOpenPointsGuide == null) {
      return const SizedBox.shrink();
    }

    final border = theme.colors.border;
    final divider = Container(height: 0.5, color: border);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
        color: theme.colors.secondary.withValues(alpha: 0.35),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (weekLabel != null && weekLabel!.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(FLucideIcons.timer, size: 16, color: theme.colors.primary),
                  const Gap(8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weekLabel!,
                          style: theme.typography.body.sm.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (statusLine != null && statusLine!.isNotEmpty) ...[
                          const Gap(2),
                          Text(
                            statusLine!,
                            style: theme.typography.body.xs.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
            if (onOpenPointsGuide != null &&
                weekLabel != null &&
                weekLabel!.isNotEmpty) ...[
              const Gap(8),
              divider,
            ],
            if (onOpenPointsGuide != null)
              FTappable(
                onPress: onOpenPointsGuide,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        FLucideIcons.circleHelp,
                        size: 16,
                        color: theme.colors.primary,
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          l10n.balehoPointsGuideTitle,
                          style: theme.typography.body.sm.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        FLucideIcons.chevronRight,
                        size: 14,
                        color: theme.colors.mutedForeground,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

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
