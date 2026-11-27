import 'dart:ui';

import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import 'profile_identity_header.dart';

/// Cover hero full-bleed: gambar + scrim ringan + kartu kaca melayang di
/// dasar (judul & subjudul). Sengaja beda komposisi dari hero Komunitas
/// (band penuh lebar): kartu inset, sudut membulat, aksen vertikal.
///
/// Kartu gelap translusen di KEDUA tema (teks putih) supaya tidak ada
/// pembatas putih di tema light.
class CoverHero extends StatelessWidget {
  const CoverHero({
    super.key,
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.semanticLabel,
  });

  final String asset;
  final String title;
  final String subtitle;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final coverHeight = ProfileIdentityHeader.coverHeightOf(
      ProfileHeaderVariant.compact,
      MediaQuery.sizeOf(context).width,
    );

    return SizedBox(
      height: coverHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(asset, fit: BoxFit.cover, semanticLabel: semanticLabel),
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.4, 1.0],
                  colors: [
                    Color(0x40000000),
                    Color(0x14000000),
                    Color(0x33000000),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: Color(0x6B0B1517)),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ColoredBox(
                          color: theme.colors.primary,
                          child: const SizedBox(width: 4),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.typography.body.lg.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                const Gap(3),
                                Text(
                                  subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.typography.body.xs.copyWith(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
