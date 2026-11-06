import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/achievement.dart';

/// Grid lencana (badge) yang dimiliki user.
///
/// Tier: kalau ada `family`, hanya level tertinggi per family yang tampil
/// (cermin aturan backend `listOwnedByUser`).
///
/// Ringkasan profil memakai [compact] + [maxRows] 1 + [columns] 4.
/// Halaman pencapaian membiarkan default (3 kolom, semua baris).
class AchievementBadgeGrid extends StatelessWidget {
  const AchievementBadgeGrid({
    super.key,
    required this.items,
    this.onItemTap,
    this.onOverflow,
    this.emptyLabel = 'Belum ada lencana.',
    this.maxRows,
    this.columns = 3,
    this.compact = false,
  });

  final List<Achievement> items;
  final void Function(Achievement item)? onItemTap;

  /// Dipanggil saat sel ujung (overlay "Lihat lainnya") diketuk.
  final VoidCallback? onOverflow;
  final String emptyLabel;

  /// Null = tampilkan semua baris.
  final int? maxRows;
  final int columns;

  /// Satu baris profil: gambar 48, judul 1 baris, jarak rapat.
  final bool compact;

  static const double compactImageSize = 48;
  static const double compactSpacing = 4;
  static const double compactPadding = 4;
  static const double compactImageGap = 2;
  static const double compactRadius = 8;

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

    final spacing = compact ? compactSpacing : 12.0;
    final capacity = maxRows == null ? items.length : maxRows! * columns;
    final overflow = items.length > capacity;
    final visible = overflow ? items.sublist(0, capacity) : items;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Lebar sel dihitung manual karena Wrap (bukan GridView) supaya
        // tinggi sel ikut isi - GridView dengan childAspectRatio memaksa
        // tinggi tetap dan menyisakan celah kosong di bawah judul.
        final gaps = spacing * (columns - 1);
        final cellWidth = (constraints.maxWidth - gaps) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (var i = 0; i < visible.length; i++)
              _cell(
                context,
                visible[i],
                cellWidth,
                showOverflow: overflow && i == visible.length - 1,
              ),
          ],
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

  Widget _cell(
    BuildContext context,
    Achievement item,
    double width, {
    required bool showOverflow,
  }) {
    final theme = context.theme;
    final imageWidth = compact ? 96 : 256;
    final url =
        displayImageUrl(item.badgeUrl, width: imageWidth) ?? item.badgeUrl;
    final padding = compact ? compactPadding : 8.0;
    final radius = compact ? compactRadius : 12.0;
    final imageGap = compact ? compactImageGap : 4.0;
    final art = url == null
        ? Icon(
            FLucideIcons.award,
            size: compact ? 22 : 32,
            color: theme.colors.mutedForeground,
          )
        : Image.network(
            url,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => Icon(
              FLucideIcons.award,
              size: compact ? 22 : 32,
              color: theme.colors.mutedForeground,
            ),
          );
    final cell = SizedBox(
      width: width,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: theme.colors.border),
            ),
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (compact)
                  SizedBox(
                    width: compactImageSize,
                    height: compactImageSize,
                    child: art,
                  )
                else
                  AspectRatio(aspectRatio: 1, child: art),
                Gap(imageGap),
                if (compact)
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.typography.body.xs.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  )
                else
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
          if (showOverflow)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xB3000000),
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context).achievementSeeMore,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.xs.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFFFFF),
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    final VoidCallback? onTap = showOverflow
        ? onOverflow
        : (onItemTap == null ? null : () => onItemTap!(item));
    if (onTap == null) return cell;
    final label = showOverflow
        ? AppLocalizations.of(context).achievementSeeMore
        : item.title;
    return Semantics(
      button: true,
      label: label,
      // GestureDetector, bukan InkWell: InkWell butuh ancestor Material yang
      // tidak ada di pohon Forui (crash "No Material widget found").
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: cell,
      ),
    );
  }
}
