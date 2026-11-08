import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';

import '../../../shared/widgets/cached_network_image_with_fallback.dart';

/// Avatar logo layanan; tap opsional (biasanya ke detail).
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
    final fallback = ColoredBox(
      color: theme.colors.secondary,
      child: Center(
        child: Icon(
          isAmbulance ? FLucideIcons.ambulance : FLucideIcons.flame,
          size: size * 0.45,
          color: theme.colors.mutedForeground,
        ),
      ),
    );
    final url = (logoUrl ?? '').trim();
    final child = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: size,
        height: size,
        child: url.isEmpty
            ? fallback
            : CachedNetworkImageWithFallback(
                imageUrl: url,
                expand: true,
                fallback: fallback,
              ),
      ),
    );
    if (onTap == null) return child;
    return GestureDetector(onTap: onTap, child: child);
  }
}
