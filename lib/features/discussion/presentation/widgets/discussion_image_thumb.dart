import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../domain/discussion_models.dart';

/// Thumbnail foto diskusi: blur + CTA jika ber-flag kekerasan dan belum di-reveal.
class DiscussionImageThumb extends StatelessWidget {
  const DiscussionImageThumb({
    super.key,
    required this.image,
    required this.revealed,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.onRequestReveal,
  });

  final DiscussionImage image;
  final bool revealed;
  final BoxFit fit;
  final double? width;
  final double? height;
  final VoidCallback? onRequestReveal;

  @override
  Widget build(BuildContext context) {
    final src = image.displaySource;
    if (src == null || src.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: const ColoredBox(color: Color(0x11000000)),
      );
    }

    final Widget child;
    if (image.hasViolenceWarning && !revealed) {
      child = _BlurredThumb(
        imageUrl: src,
        fit: fit,
        onReveal: onRequestReveal,
      );
    } else {
      child = CachedNetworkImageWithFallback(
        imageUrl: displayImageUrl(src, width: 800) ?? src,
        fallbackUrl: src,
        fit: fit,
      );
    }

    if (width != null || height != null) {
      return SizedBox(width: width, height: height, child: child);
    }
    return child;
  }
}

class _BlurredThumb extends StatelessWidget {
  const _BlurredThumb({
    required this.imageUrl,
    required this.fit,
    this.onReveal,
  });

  final String imageUrl;
  final BoxFit fit;
  final VoidCallback? onReveal;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Semantics(
      button: onReveal != null,
      hint: 'Gambar disensor. Ketuk untuk menampilkan.',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onReveal,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: CachedNetworkImageWithFallback(
                imageUrl: displayImageUrl(imageUrl, width: 400) ?? imageUrl,
                fallbackUrl: imageUrl,
                fit: fit,
              ),
            ),
            const ColoredBox(color: Color(0x66000000)),
            Center(
              child: Text(
                onReveal != null
                    ? 'Kekerasan · ketuk untuk lihat'
                    : 'Konten kekerasan',
                textAlign: TextAlign.center,
                style: theme.typography.sm.copyWith(
                  color: const Color(0xFFFFFFFF),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
