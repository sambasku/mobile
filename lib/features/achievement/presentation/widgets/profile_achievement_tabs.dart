import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/display_image_url.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/failures/achievement_failure.dart';
import '../../domain/providers/achievement_domain_providers.dart';
import '../providers/achievement_providers.dart';
import 'achievement_badge_grid.dart';
import 'achievement_tile.dart';
import 'border_picker_sheet.dart';

/// Sub-tab Pencapaian di profil sendiri: Badge | Border | Pencapaian.
///
/// Non-expanding [FTabs] supaya aman di dalam ListView profil.
class ProfileAchievementTabs extends ConsumerWidget {
  const ProfileAchievementTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myAchievementsProvider());
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: FCircularProgress()),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          children: [
            FAlert(
              variant: FAlertVariant.destructive,
              title: Text(
                err is AchievementFailure
                    ? err.message
                    : 'Gagal memuat pencapaian',
              ),
            ),
            const Gap(8),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => ref.invalidate(myAchievementsProvider),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
      data: (items) {
        final owned = items.where((e) => e.isOwned).toList(growable: false);
        return FTabs(
          onPress: (index) => AnalyticsService.instance.logAchievementsView(
            tab: const ['badge', 'border', 'pencapaian'][index],
          ),
          children: [
            FTabEntry.entry(
              label: const Text('Badge'),
              child: _BadgeTab(
                badges: AchievementBadgeGrid.topTierPerFamily(
                  owned.where((e) => e.isBadge).toList(growable: false),
                ),
              ),
            ),
            FTabEntry.entry(
              label: const Text('Border'),
              child: _BorderTab(
                borders: owned.where((e) => e.isBorder).toList(growable: false),
              ),
            ),
            FTabEntry.entry(
              label: const Text('Pencapaian'),
              child: _AllTab(items: items),
            ),
          ],
        );
      },
    );
  }
}

class _BadgeTab extends StatelessWidget {
  const _BadgeTab({required this.badges});

  final List<Achievement> badges;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: AchievementBadgeGrid(
        items: badges,
        emptyLabel: 'Belum ada lencana. Terus berkontribusi untuk membukanya.',
      ),
    );
  }
}

class _BorderTab extends StatelessWidget {
  const _BorderTab({required this.borders});

  final List<Achievement> borders;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    if (borders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Belum punya bingkai profil.',
          textAlign: TextAlign.center,
          style: theme.typography.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Gap(8),
        for (final border in borders)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _BorderRow(border: border),
          ),
      ],
    );
  }
}

class _BorderRow extends ConsumerStatefulWidget {
  const _BorderRow({required this.border});

  final Achievement border;

  @override
  ConsumerState<_BorderRow> createState() => _BorderRowState();
}

class _BorderRowState extends ConsumerState<_BorderRow> {
  bool _busy = false;

  Future<void> _toggle() async {
    if (_busy) return;
    setState(() => _busy = true);
    final next = widget.border.isActiveBorder
        ? null
        : widget.border.userAchievementId;
    final result = await ref.read(setActiveBorderUseCaseProvider).call(next);
    if (!mounted) return;
    setState(() => _busy = false);
    result.match(
      (failure) => showFToast(context: context, title: Text(failure.message)),
      (_) {
        ref.invalidate(myAchievementsProvider);
        ref.invalidate(myActiveBorderProvider);
        showFToast(
          context: context,
          title: Text(
            next == null ? 'Bingkai dilepas' : 'Bingkai profil diperbarui',
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final border = widget.border;
    final url = displayImageUrl(border.badgeUrl, width: 128) ?? border.badgeUrl;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: border.isActiveBorder
              ? theme.colors.primary
              : theme.colors.border,
          width: border.isActiveBorder ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: url == null
                ? Icon(
                    FLucideIcons.frame,
                    color: theme.colors.mutedForeground,
                  )
                : Image.network(
                    url,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (_, _, _) => Icon(
                      FLucideIcons.frame,
                      color: theme.colors.mutedForeground,
                    ),
                  ),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  border.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  border.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.xs.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
          if (_busy)
            const SizedBox(
              width: 18,
              height: 18,
              child: FCircularProgress(),
            )
          else
            border.isActiveBorder
                ? FButton(
                    variant: FButtonVariant.outline,
                    size: FButtonSizeVariant.sm,
                    onPress: _toggle,
                    child: const Text('Lepas'),
                  )
                : FButton(
                    size: FButtonSizeVariant.sm,
                    onPress: _toggle,
                    child: const Text('Pakai'),
                  ),
        ],
      ),
    );
  }
}

class _AllTab extends StatelessWidget {
  const _AllTab({required this.items});

  final List<Achievement> items;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final owned = items.where((e) => e.isOwned).toList(growable: false);
    final locked = items.where((e) => !e.isOwned).toList(growable: false);

    void open(Achievement item) {
      AnalyticsService.instance.logAchievementBadgeView(code: item.code);
      showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (sheetContext) {
          final sheetTheme = sheetContext.theme;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: sheetTheme.typography.lg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(6),
                  Text(item.description, style: sheetTheme.typography.sm),
                  const Gap(10),
                  Text(
                    item.isOwned ? 'Sudah kamu miliki' : 'Belum dibuka',
                    style: sheetTheme.typography.sm.copyWith(
                      color: item.isOwned
                          ? sheetTheme.colors.primary
                          : sheetTheme.colors.mutedForeground,
                    ),
                  ),
                  if (item.isBorder && item.isOwned) ...[
                    const Gap(12),
                    FButton(
                      variant: FButtonVariant.outline,
                      onPress: () {
                        Navigator.of(sheetContext).pop();
                        showBorderPickerSheet(context);
                      },
                      child: const Text('Ubah bingkai profil'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    }

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Belum ada pencapaian tersedia.',
          textAlign: TextAlign.center,
          style: theme.typography.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Gap(8),
        if (owned.isNotEmpty) ...[
          Text(
            'Dimiliki',
            style: theme.typography.sm.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(4),
          FTileGroup(
            children: [
              for (final item in owned)
                AchievementTile(item: item, onTap: () => open(item)),
            ],
          ),
        ],
        if (locked.isNotEmpty) ...[
          const Gap(12),
          Text(
            'Belum dibuka',
            style: theme.typography.sm.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(4),
          FTileGroup(
            children: [
              for (final item in locked)
                AchievementTile(item: item, onTap: () => open(item)),
            ],
          ),
        ],
        const Gap(16),
      ],
    );
  }
}
