import 'package:flutter/widgets.dart';

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
    this.scale = 1.32,
  });

  final Widget child;
  final double size;
  final String? borderUrl;
  final double scale;

  /// Sisi kotak total (avatar + ruang bingkai). Dipakai pemanggil untuk
  /// memberi jarak layout supaya cincin tidak menutupi teks sebelah.
  static double extent(double avatarSize, {double scale = 1.32}) =>
      avatarSize * scale;

  @override
  Widget build(BuildContext context) {
    final raw = borderUrl?.trim();
    if (raw == null || raw.isEmpty) return child;
    final frame = size * scale;
    return SizedBox(
      width: frame,
      height: frame,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          child,
          Positioned.fill(
            child: IgnorePointer(
              child: Image.network(
                raw,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                // Bingkai gagal load = avatar tetap tampil, bukan kotak rusak.
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
