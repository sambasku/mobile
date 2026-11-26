import 'package:dotlottie_flutter/dotlottie_flutter.dart';
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

/// Overlay aset bingkai: PNG/WebP atau animasi Lottie (.json / .lottie).
class ProfileBorderAssetLayer extends StatelessWidget {
  const ProfileBorderAssetLayer({
    super.key,
    required this.url,
    required this.assetKind,
    this.fit = BoxFit.contain,
    this.resizeWidth,
  });

  final String url;
  final ProfileBorderAssetKind assetKind;
  final BoxFit fit;
  final int? resizeWidth;

  @override
  Widget build(BuildContext context) {
    if (assetKind == ProfileBorderAssetKind.image) {
      final display =
          displayImageUrl(url, width: resizeWidth) ?? url;
      return Image.network(
        display,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
    }

    if (MediaQuery.disableAnimationsOf(context)) {
      return const SizedBox.shrink();
    }

    if (profileBorderUrlIsDotLottie(url)) {
      return DotLottieView(
        source: url,
        sourceType: 'url',
        autoplay: true,
        loop: true,
        onLoadError: () {},
      );
    }

    return Lottie.network(
      url,
      fit: fit,
      repeat: true,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }
}