import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../domain/entities/achievement.dart';

/// Grid lencana (badge) yang dimiliki user.
///
/// Tier: kalau ada `family`, hanya level tertinggi per family yang tampil
/// (cermin aturan backend `listOwnedByUser`).
class AchievementBadgeGrid extends StatelessWidget {
  const AchievementBadgeGrid({
    super.key,
    required this.items,
    this.onItemTap,
    this.emptyLabel = 'Belum ada lencana.',
  });

  final List<Achievement> items;
  final void Function(Achievement item)? onItemTap;
  final String emptyLabel;

  /// Lencana milik user: level tertinggi per family, lalu badge tanpa family.
  static List<Achievement> topTierPerFamily(List<Achievement> items) {
    final best = <String, Achievement>{};
    final others = <Achievement>[];
    for (final item in items) {
      final family = item.family;
      if (family == null || family.isEmpty) {
        others.add(item);
        continue;
      }
      final current = best[family];
      if (current == null ||
          (item.level ?? 0) > (current.level ?? 0)) {
        best[family] = item;
      }
    }
    return [...best.values, ...others];
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          emptyLabel,
          textAlign: TextAlign.center,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final url = displayImageUrl(item.badgeUrl, width: 256) ?? item.badgeUrl;
        final cell = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colors.border),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: url == null
                    ? Icon(
                        FLucideIcons.award,
                        size: 32,
                        color: theme.colors.mutedForeground,
                      )
                    : Image.network(
                        url,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                        errorBuilder: (_, _, _) => Icon(
                          FLucideIcons.award,
                          size: 32,
                          color: theme.colors.mutedForeground,
                        ),
                      ),
              ),
              const Gap(4),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.typography.body.xs.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        );
        if (onItemTap == null) return cell;
        return Semantics(
          button: true,
          label: item.title,
          child: InkWell(
            onTap: () => onItemTap!(item),
            borderRadius: BorderRadius.circular(12),
            child: cell,
          ),
        );
      },
    );
  }
}
