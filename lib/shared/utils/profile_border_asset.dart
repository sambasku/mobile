import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

import '../../core/utils/display_image_url.dart';

/// Kind aset bingkai profil dari API (`badge_asset_kind`).
enum ProfileBorderAssetKind {
  image,
  lottie,
}

ProfileBorderAssetKind profileBorderAssetKindFromWire(String? raw) {
  return switch (raw?.trim().toLowerCase()) {
    'lottie' => ProfileBorderAssetKind.lottie,
    _ => ProfileBorderAssetKind.image,
  };
}

bool profileBorderUrlIsDotLottie(String url) {
  final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
  return path.endsWith('.lottie');
}

bool profileBorderUrlIsLottie(String url) {
  final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
  return path.endsWith('.lottie') || path.endsWith('.json');
}

/// Overlay aset bingkai: PNG/WebP atau animasi Lottie (.json / .lottie).
class ProfileBorderAssetLayer extends StatelessWidget {
  const ProfileBorderAssetLayer({
    super.key,
    required this.url,
    required this.assetKind,
    this.fit = BoxFit.contain,
    this.resizeWidth,
    this.fallback = const SizedBox.shrink(),
  });

  final String url;
  final ProfileBorderAssetKind assetKind;
  final BoxFit fit;
  final int? resizeWidth;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    final isLottie =
        assetKind == ProfileBorderAssetKind.lottie ||
        profileBorderUrlIsLottie(url);

    if (!isLottie) {
      final display = displayImageUrl(url, width: resizeWidth) ?? url;
      return Image.network(
        display,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    // Paket lottie 3.x sudah men-decode .lottie (ZIP berisi animations/*.json)
    // langsung di canvas Flutter (LottieComposition.decodeZip) tanpa PlatformView.
    return Lottie.network(
      url,
      fit: fit,
      animate: !disableAnimations,
      repeat: !disableAnimations,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}