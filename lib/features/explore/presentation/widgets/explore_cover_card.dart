import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';

/// Kartu grid Eksplorasi / Permainan: foto di atas, judul di bawah.
///
/// [coverAsset] null → area secondary + [placeholderIcon] (kartu segera /
/// tanpa ilustrasi). Teks di luar foto supaya tidak menutupi cover.
class ExploreCoverCard extends StatelessWidget {
  const ExploreCoverCard({
    super.key,
    required this.title,
    required this.onTap,
    this.coverAsset,
    this.placeholderIcon,
    this.badge,
  });

  final String title;
  final VoidCallback? onTap;
  final String? coverAsset;

  /// Ikon tengah bila [coverAsset] kosong (mis. kategori "Segera").
  final IconData? placeholderIcon;

  /// Chip kanan atas di atas foto (mis. "Segera"). Null = tidak ditampilkan.
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final hasCover = coverAsset != null;

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
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasCover)
                    Image.asset(
                      coverAsset!,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      gaplessPlayback: true,
                      errorBuilder: (_, _, _) => _PlaceholderArt(
                        icon: placeholderIcon,
                      ),
                    )
                  else
                    _PlaceholderArt(icon: placeholderIcon),
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.body.sm.copyWith(
                  fontSize: 12,
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
