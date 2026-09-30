import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../flavors.dart';
import 'beta_badge.dart';

const kBrandMarkDarkAsset = 'assets/icons/logo_alpha_dark.png';
const kBrandMarkLightAsset = 'assets/icons/logo_alpha_light.png';
const kBrandWordmarkDarkAsset = 'assets/svg/sambasku_header_dark.svg';
const kBrandWordmarkLightAsset = 'assets/svg/sambasku_header_light.svg';

/// Logo stacked (perisai + wordmark) adaptif terang/gelap.
/// Login, onboarding, about. Teks "SambasKu" sudah di aset.
/// Gelap: [kBrandMarkDarkAsset]. Terang: [kBrandMarkLightAsset].
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 168, this.frameBuilder});

  final double size;
  final ImageFrameBuilder? frameBuilder;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      dark ? kBrandMarkDarkAsset : kBrandMarkLightAsset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      frameBuilder: frameBuilder,
      errorBuilder: (context, error, stackTrace) {
        final fallback = Icon(
          Icons.menu_book_rounded,
          size: size * 0.4,
          color: Colors.grey,
        );
        if (frameBuilder != null) {
          return frameBuilder!(context, fallback, 0, true);
        }
        return fallback;
      },
    );
  }
}

/// Logo persegi per flavor (`logo.png` / `logo.staging.png`), radius 15.
/// Splash. Staging: pita STG di aset.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size,
    this.borderRadius = 15,
    this.frameBuilder,
  });

  final double? size;
  final double borderRadius;
  final ImageFrameBuilder? frameBuilder;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        F.logoAsset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        frameBuilder: frameBuilder,
        errorBuilder: (context, error, stackTrace) {
          final fallback = Container(
            width: size ?? 120,
            height: size ?? 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: Colors.grey.shade200,
            ),
            child: Icon(
              Icons.menu_book_rounded,
              size: (size ?? 120) * 0.4,
              color: Colors.grey,
            ),
          );
          // errorBuilder menggantikan frameBuilder; tetap laporkan "sudah
          // selesai" supaya Skeletonizer di login tidak shimmer selamanya.
          if (frameBuilder != null) {
            return frameBuilder!(context, fallback, 0, true);
          }
          return fallback;
        },
      ),
    );
  }
}

/// Wordmark landscape adaptif (putih di gelap / navy-gold di terang).
/// App bar tab Home.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.height = 28});

  final double height;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final wordmark = SvgPicture.asset(
      dark ? kBrandWordmarkDarkAsset : kBrandWordmarkLightAsset,
      height: height,
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
      semanticsLabel: 'SambasKu',
    );
    if (!F.isBeta) return wordmark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [wordmark, const SizedBox(width: 4), const BetaBadge()],
    );
  }
}
