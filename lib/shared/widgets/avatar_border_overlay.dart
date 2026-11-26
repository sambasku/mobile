import 'package:flutter/widgets.dart';

import '../utils/profile_border_asset.dart';

/// Avatar + bingkai profil (aset achievement `profile_border`).
///
/// Bingkai digambar di atas avatar dengan skala lebih besar supaya cincin
/// aset tetap terlihat walau fotonya menutup area tengah. [borderUrl] null =
/// tampil apa adanya tanpa bingkai.
class AvatarBorderOverlay extends StatelessWidget {
  const AvatarBorderOverlay({
    super.key,
    required this.child,
    required this.size,
    this.borderUrl,
    this.borderAssetKind = ProfileBorderAssetKind.image,
    this.scale = 1.32,
    this.lottieScale = 1.48,
    this.lottieAvatarInset = 0.86,
  });

  final Widget child;
  final double size;
  final String? borderUrl;
  final ProfileBorderAssetKind borderAssetKind;
  /// Skala frame untuk border PNG statis.
  final double scale;
  /// Frame Lottie biasanya butuh kotak lebih besar + foto sedikit mengecil.
  final double lottieScale;
  final double lottieAvatarInset;

  /// Sisi kotak total (avatar + ruang bingkai). Dipakai pemanggil untuk
  /// memberi jarak layout supaya cincin tidak menutupi teks sebelah.
  static double extent(
    double avatarSize, {
    double scale = 1.32,
    double lottieScale = 1.48,
    String? borderUrl,
    ProfileBorderAssetKind borderAssetKind = ProfileBorderAssetKind.image,
  }) {
    final raw = borderUrl?.trim();
    final isLottie = borderAssetKind == ProfileBorderAssetKind.lottie ||
        (raw != null && raw.isNotEmpty && profileBorderUrlIsLottie(raw));
    return avatarSize * (isLottie ? lottieScale : scale);
  }

  bool _isLottieBorder(String url) {
    return borderAssetKind == ProfileBorderAssetKind.lottie ||
        profileBorderUrlIsLottie(url);
  }

  @override
  Widget build(BuildContext context) {
    final raw = borderUrl?.trim();
    if (raw == null || raw.isEmpty) return child;
    final isLottie = _isLottieBorder(raw);
    final frameScale = isLottie ? lottieScale : scale;
    final frame = size * frameScale;
    final avatarChild = isLottie
        ? Transform.scale(scale: lottieAvatarInset, child: child)
        : child;
    return SizedBox(
      width: frame,
      height: frame,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          avatarChild,
          Positioned.fill(
            child: IgnorePointer(
              child: ProfileBorderAssetLayer(
                url: raw,
                assetKind: borderAssetKind,
                fit: isLottie ? BoxFit.cover : BoxFit.contain,
                resizeWidth: isLottie ? null : (size <= 72 ? 256 : null),
              ),
            ),
          ),
        ],
      ),
    );
  }
}