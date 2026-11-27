import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';

import '../../../core/utils/display_image_url.dart';
import '../../../shared/widgets/cached_network_image_with_fallback.dart';

/// Thumb logo layanan di daftar. Sudut 8, sama dengan thumb karya.
class LayananLogo extends StatelessWidget {
  const LayananLogo({
    super.key,
    required this.logoUrl,
    required this.isAmbulance,
    this.onTap,
    this.size = 40,
  });

  final String? logoUrl;
  final bool isAmbulance;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final url = (logoUrl ?? '').trim();
    final fallback = ColoredBox(
      color: theme.colors.secondary,
      child: Center(
        child: Icon(
          isAmbulance ? FLucideIcons.ambulance : FLucideIcons.flame,
          size: size * 0.45,
          color: theme.colors.primary,
        ),
      ),
    );
    final child = SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.secondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: url.isEmpty
              ? fallback
              : CachedNetworkImageWithFallback(
                  imageUrl: displayImageUrl(url, width: 96) ?? url,
                  fallbackUrl: url,
                  fit: BoxFit.cover,
                  expand: true,
                  fallback: fallback,
                ),
        ),
      ),
    );
    if (onTap == null) return child;
    return GestureDetector(onTap: onTap, child: child);
  }
}
