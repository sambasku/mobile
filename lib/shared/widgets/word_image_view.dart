import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../core/utils/display_image_url.dart';
import '../../features/dictionary/domain/entities/word_detail.dart';
import 'cached_network_image_with_fallback.dart';

/// Host yang dikenal sebagai placeholder gambar staging (sementara).
/// Deteksi interim sampai flag `is_verified` stabil di produksi.
const _kPendingPlaceholderHosts = {'placehold.co', 'via.placeholder.com'};

/// Apakah URL ini adalah placeholder staging yang dikenal.
bool isKnownPendingPlaceholderUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  return _kPendingPlaceholderHosts.contains(uri.host.toLowerCase());
}

/// Widget gambar kata dengan dua lapisan proteksi tampilan:
///
/// 1. Belum terverifikasi (`image.isPendingReview` atau URL placeholder
///    staging) - tampil asset lokal, tidak bisa dibuka di gallery.
/// 2. Kekerasan (`image.hasViolenceWarning`) + belum di-reveal -
///    foto diblur + overlay CTA. Setelah user konfirmasi, [revealed]
///    di-set true oleh parent; widget ini tidak menyimpan state reveal.
///
/// State reveal kekerasan hidup di halaman detail (reset saat ganti kata,
/// tidak dipersist).
class WordImageView extends StatelessWidget {
  const WordImageView({
    super.key,
    required this.image,
    required this.revealed,
    this.fit = BoxFit.cover,
    this.width,
    this.height,

    /// Dipanggil ketika user mengetuk CTA blur (thumb). Null = tap diabaikan.
    this.onRequestReveal,
  });

  final WordImage image;

  /// true = gambar kekerasan sudah di-unlock untuk sesi ini.
  final bool revealed;
  final BoxFit fit;
  final double? width;
  final double? height;
  final VoidCallback? onRequestReveal;

  bool get _isPending =>
      image.isPendingReview || isKnownPendingPlaceholderUrl(image.url);

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_isPending) {
      child = _PendingPlaceholder(fit: fit);
    } else if (image.hasViolenceWarning && !revealed) {
      child = _BlurredViolenceThumb(
        imageUrl: image.url,
        fit: fit,
        onReveal: onRequestReveal,
      );
    } else {
      child = CachedNetworkImageWithFallback(
        imageUrl: displayImageUrl(image.url, width: 800) ?? image.url,
        fallbackUrl: image.url,
        fit: fit,
      );
    }

    if (width != null || height != null) {
      return SizedBox(width: width, height: height, child: child);
    }
    return child;
  }
}

// ---------------------------------------------------------------------------
// Internal widgets
// ---------------------------------------------------------------------------

class _PendingPlaceholder extends StatelessWidget {
  const _PendingPlaceholder({required this.fit});

  final BoxFit fit;

  static const _darkGif = 'assets/gif/pending_review_dark.gif';
  static const _lightGif = 'assets/gif/pending_review_light.gif';

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: 'Menunggu tinjauan',
      child: Image.asset(
        dark ? _darkGif : _lightGif,
        fit: fit,
        gaplessPlayback: true,
      ),
    );
  }
}

/// Gambar diblur + overlay label kekerasan + aksi "Lihat foto".
class _BlurredViolenceThumb extends StatelessWidget {
  const _BlurredViolenceThumb({
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
      button: true,
      hint: 'Gambar disensor. Ketuk untuk menampilkan.',
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gambar diblur - konten tidak terbaca sekilas.
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: CachedNetworkImageWithFallback(
              imageUrl: displayImageUrl(imageUrl, width: 800) ?? imageUrl,
              fallbackUrl: imageUrl,
              fit: fit,
            ),
          ),
          // Overlay gelap tipis.
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),
          // Label + aksi reveal.
          Center(
            child: GestureDetector(
              onTap: onReveal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FLucideIcons.eyeOff,
                      size: 22,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Foto berisi kekerasan',
                      style: theme.typography.xs.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lihat foto',
                      style: theme.typography.xs.copyWith(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog konfirmasi sebelum menampilkan foto kekerasan.
Future<bool> confirmRevealViolenceImage(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final theme = sheetContext.theme;
      return Material(
        color: Theme.of(sheetContext).colorScheme.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Lihat foto ini?',
                  style: theme.typography.lg.copyWith(fontWeight: FontWeight.w600),
                ),
                const Gap(8),
                Text(
                  'Foto ini memperlihatkan kekerasan. Kalau ada orang di dekatmu, mereka juga bisa melihat.',
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                const Gap(16),
                Row(
                  children: [
                    Expanded(
                      child: FButton(
                        variant: FButtonVariant.outline,
                        onPress: () => Navigator.of(sheetContext).pop(false),
                        child: const Text('Jangan dulu'),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: FButton(
                        onPress: () => Navigator.of(sheetContext).pop(true),
                        child: const Text('Lihat'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return result == true;
}
