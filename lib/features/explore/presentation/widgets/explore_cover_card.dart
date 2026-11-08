import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';

/// Kartu grid Eksplorasi / Permainan: foto di atas, judul di bawah.
///
/// [coverAsset] null → area secondary + [placeholderIcon] (kartu segera /
/// tanpa ilustrasi). Teks di luar foto supaya tidak menutupi cover.
///
/// Area foto memakai [AspectRatio] ([coverAspectRatio], default 1:1) supaya
/// kontainer mengikuti rasio aset, bukan dipaksa [Expanded] di sel grid.
class ExploreCoverCard extends StatelessWidget {
  const ExploreCoverCard({
    super.key,
    required this.title,
    required this.onTap,
    this.coverAsset,
    this.placeholderIcon,
    this.badge,
    this.coverAspectRatio = 1,
  });

  final String title;
  final VoidCallback? onTap;
  final String? coverAsset;

  /// Ikon tengah bila [coverAsset] kosong (mis. kategori "Segera").
  final IconData? placeholderIcon;

  /// Chip kanan atas di atas foto (mis. "Segera"). Null = tidak ditampilkan.
  final Widget? badge;

  /// Rasio lebar:tinggi area cover. Aset `explore_covers/*.webp` = 1:1.
  final double coverAspectRatio;

  /// Estimasi tinggi blok judul di bawah cover (padding + 1 baris 12sp).
  /// Dipakai menghitung [childAspectRatio] grid supaya sel tidak clip.
  /// 4+4 padding + 12×1.2 line ≈ 22; +buffer metrik font → 26.
  static const double titleBlockExtent = 26;

  /// [childAspectRatio] untuk grid  yang selnya berisi [ExploreCoverCard].
  static double gridChildAspectRatio({
    required double maxWidth,
    int crossAxisCount = 3,
    double crossAxisSpacing = 8,
    double coverAspectRatio = 1,
    double titleBlockExtent = ExploreCoverCard.titleBlockExtent,
  }) {
    final cellW =
        (maxWidth - crossAxisSpacing * (crossAxisCount - 1)) / crossAxisCount;
    final cellH = cellW / coverAspectRatio + titleBlockExtent;
    return cellW / cellH;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final hasCover = coverAsset != null;

    final cover = AspectRatio(
      aspectRatio: coverAspectRatio,
      child: hasCover
          ? Image.asset(
              coverAsset!,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => _PlaceholderArt(
                icon: placeholderIcon,
              ),
            )
          : _PlaceholderArt(icon: placeholderIcon),
    );

    return Material(
      color: theme.colors.background,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                cover,
                if (badge != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: badge,
                    ),
                  ),
              ],
            ),
            Padding(
              // Ketat: space bawah kartu dulu kebesaran (titleBlock 40 + pad 8).
              padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.body.sm.copyWith(
                  fontSize: 12,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: theme.colors.foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderArt extends StatelessWidget {
  const _PlaceholderArt({this.icon});

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ColoredBox(
      color: theme.colors.secondary,
      child: Center(
        child: Icon(
          icon ?? FLucideIcons.image,
          size: 36,
          color: theme.colors.mutedForeground.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}
