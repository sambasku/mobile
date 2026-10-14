import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:forui/forui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/widgets/image_preview.dart';
import 'cached_network_image_with_fallback.dart';

/// Renderer markdown bersama: dipakai body pengumuman (#124) dan artikel
/// profil kecamatan (#123) supaya behaviour tap link & preview gambar
/// identik di seluruh app.
///
/// - gambar: lebar penuh, rasio asli, tap -> preview fullscreen pinch-zoom
/// - link: hanya https -> browser eksternal (skema lain diabaikan)
class SambaskuMarkdown extends StatelessWidget {
  const SambaskuMarkdown({super.key, required this.data, this.selectable = true});

  final String data;

  /// Teks bisa diseleksi (default true, sama dengan body pengumuman).
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return MarkdownBody(
      data: data,
      selectable: selectable,
      sizedImageBuilder: buildSambaskuMarkdownImage,
      onTapLink: (text, href, title) => openSambaskuMarkdownHref(href),
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: theme.typography.sm.copyWith(height: 1.5),
        h1: theme.typography.xl2.copyWith(fontWeight: FontWeight.w700, height: 1.3),
        h2: theme.typography.xl.copyWith(fontWeight: FontWeight.w700, height: 1.3),
        h3: theme.typography.lg.copyWith(fontWeight: FontWeight.w700, height: 1.3),
        listBullet: theme.typography.sm,
      ),
    );
  }
}

/// Gambar di body markdown: lebar penuh, tinggi ikut rasio asli (expand:
/// false) kecuali md menyebut ukuran eksplisit; tap -> preview fullscreen
/// dengan pinch-zoom.
Widget buildSambaskuMarkdownImage(MarkdownImageConfig config) {
  final src = config.uri.toString();
  if (src.isEmpty) return const SizedBox.shrink();
  final alt = config.alt;
  final sized = config.width != null || config.height != null;
  return Builder(
    builder: (context) => GestureDetector(
      onTap: () => showImagePreview(context, urls: [src]),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Semantics(
          button: true,
          label: alt != null && alt.isNotEmpty ? alt : 'Lihat gambar',
          child: sized
              ? SizedBox(
                  width: config.width,
                  height: config.height,
                  child: CachedNetworkImageWithFallback(
                    imageUrl: src,
                    fallbackUrl: src,
                    fit: BoxFit.contain,
                  ),
                )
              : CachedNetworkImageWithFallback(
                  imageUrl: src,
                  fallbackUrl: src,
                  fit: BoxFit.contain,
                  expand: false,
                ),
        ),
      ),
    ),
  );
}

/// Buka link markdown lewat browser. Hanya https (aturan keamanan sama
/// dengan tombol aksi pengumuman); skema lain diabaikan.
void openSambaskuMarkdownHref(String? href) {
  if (href == null || href.isEmpty) return;
  final uri = Uri.tryParse(href);
  if (uri == null || !uri.isScheme('https')) return;
  unawaited(
    launchUrl(uri, mode: LaunchMode.externalApplication).catchError((_) => false),
  );
}
