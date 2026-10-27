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
      if (current == null || (item.level ?? 0) > (current.level ?? 0)) {
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          emptyLabel,
          textAlign: TextAlign.center,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // 3 kolom; gap 12 antar sel. Lebar sel dihitung manual karena Wrap
        // (bukan GridView) supaya tinggi sel ikut isi - GridView dengan
        // childAspectRatio memaksa tinggi tetap dan menyisakan celah kosong
        // di bawah judul.
        final cellWidth = (constraints.maxWidth - 24) / 3;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [for (final item in items) _cell(context, item, cellWidth)],
        );
      },
    );
  }

  /// Tinggi 2 baris judul pada style `body.xs` (height 1.2).
  double _labelHeight(BuildContext context) {
    final style = context.theme.typography.body.xs;
    final fontSize = style.fontSize ?? 12;
    return fontSize * 1.2 * 2;
  }

  Widget _cell(BuildContext context, Achievement item, double width) {
    final theme = context.theme;
    final url = displayImageUrl(item.badgeUrl, width: 256) ?? item.badgeUrl;
    final cell = SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colors.border),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Kotak lencana persegi mengikuti lebar sel.
            AspectRatio(
              aspectRatio: 1,
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
            // Tinggi 2 baris dipesan tetap: judul 1 baris tidak membuat
            // sel lebih pendek dari tetangganya (baris jadi bergerigi).
            SizedBox(
              height: _labelHeight(context),
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.typography.body.xs.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (onItemTap == null) return cell;
    return Semantics(
      button: true,
      label: item.title,
      // GestureDetector, bukan InkWell: InkWell butuh ancestor Material yang
      // tidak ada di pohon Forui (crash "No Material widget found").
      child: GestureDetector(
        onTap: () => onItemTap!(item),
        behavior: HitTestBehavior.opaque,
        child: cell,
      ),
    );
  }
}
