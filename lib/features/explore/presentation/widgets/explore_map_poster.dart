import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Poster statis peta Sambas.
///
/// - [loading] true: placeholder selama MapLibre memuat style/tiles
///   (shimmer tipis di atas gradient + grid, tanpa copy error).
/// - [loading] false: pengganti MapLibre saat tiles gagal / offline.
class ExploreMapPoster extends StatelessWidget {
  const ExploreMapPoster({
    super.key,
    this.onTap,
    this.compact = true,
    this.loading = false,
  });

  final VoidCallback? onTap;
  final bool compact;
  final bool loading;

  /// Warna dasar gradient, dipakai juga sebagai warna load native MapLibre
  /// supaya frame pertama platform view tidak kedip beda warna.
  static Color baseColor(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xFF1C1917)
      : const Color(0xFFE0F2FE);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final child = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  baseColor(brightness),
                  const Color(0xFF292524),
                  const Color(0xFF0C4A6E),
                ]
              : [
                  baseColor(brightness),
                  const Color(0xFFF0FDF4),
                  const Color(0xFFFEF3C7),
                ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _GridPainter(isDark: isDark)),
          if (loading) _ShimmerSweep(isDark: isDark),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: loading
                  ? _LoadingContent(compact: compact)
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FLucideIcons.map,
                          size: compact ? 36 : 48,
                          color: theme.colors.primary,
                        ),
                        const Gap(10),
                        Text(
                          'Peta Sambas',
                          style: theme.typography.md.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Gap(4),
                        Text(
                          compact
                              ? 'Ketuk untuk membuka peta interaktif.'
                              : 'Peta tidak bisa dimuat. Periksa jaringan lalu coba lagi.',
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );

    if (loading) return child;

    if (onTap == null) return child;

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: child),
    );
  }
}

/// Hero sudah punya judul "Jelajahi Sambas" di bawah, jadi compact cukup ikon.
class _LoadingContent extends StatelessWidget {
  const _LoadingContent({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final icon = Icon(
      FLucideIcons.map,
      size: compact ? 32 : 44,
      color: theme.colors.primary.withValues(alpha: 0.7),
    );

    return Semantics(
      label: 'Memuat peta',
      liveRegion: true,
      excludeSemantics: true,
      child: compact
          ? icon
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const Gap(10),
                Text(
                  'Memuat peta...',
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }
}

/// Sapuan cahaya tipis yang bergerak, memakai shimmer Skeletonizer.
/// Base transparan supaya gradient + grid di bawahnya tetap terlihat.
class _ShimmerSweep extends StatelessWidget {
  const _ShimmerSweep({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final highlight = Colors.white.withValues(alpha: isDark ? 0.08 : 0.55);

    return ExcludeSemantics(
      child: SkeletonizerConfig(
        data: SkeletonizerConfigData(
          effect: ShimmerEffect(
            baseColor: highlight.withValues(alpha: 0),
            highlightColor: highlight,
            duration: const Duration(milliseconds: 1500),
          ),
        ),
        child: const Skeletonizer.zone(enabled: true, child: Bone()),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)
      ..strokeWidth = 1;
    const step = 28.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
