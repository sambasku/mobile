import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/analytics_service.dart';
import '../../domain/sambas_map_config.dart';
import '../../explore_router.dart';
import 'sambas_map_view.dart';

/// Living-poster MapLibre di atas grid kategori Eksplorasi.
///
/// Gesture dimatikan; tap membuka layar Peta & Akses agar tidak bentrok
/// dengan scroll kategori di bawah.
class ExploreMapHero extends StatelessWidget {
  const ExploreMapHero({super.key, this.height = 248});

  final double height;

  void _openPetaAkses(BuildContext context, {required String mode}) {
    unawaited(AnalyticsService.instance.logMapOpen(entry: 'hero', mode: mode));
    context.push(ExploreRouter.pins.path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    // Gradient/overlay mengecil ikut tinggi hero (landscape pendek).
    final gradientHeight = (height * 0.45).clamp(64.0, 112.0);

    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            SambasMapView(
              initialCameraPosition: SambasMapConfig.heroCamera,
              interactive: false,
              analyticsEntry: 'hero',
              onFallbackTap: () => _openPetaAkses(context, mode: 'poster'),
            ),
            // Gradient agar teks overlay terbaca di atas tiles.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: gradientHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colors.background.withValues(alpha: 0),
                      theme.colors.background.withValues(alpha: 0.88),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Jelajahi Sambas',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.lg.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: height < 160 ? 16 : null,
                    ),
                  ),
                  if (height >= 130) ...[
                    const Gap(4),
                    Text(
                      'Peta hidup Kabupaten Sambas - ketuk untuk membuka.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Tangkap tap di seluruh hero (termasuk area map).
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openPetaAkses(context, mode: 'live'),
                  splashColor: theme.colors.primary.withValues(alpha: 0.08),
                  highlightColor: theme.colors.primary.withValues(alpha: 0.04),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
