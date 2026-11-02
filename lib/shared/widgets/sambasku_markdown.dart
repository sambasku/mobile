import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:forui/forui.dart';
import '../../core/models/external_link.dart';

import '../../core/widgets/image_preview.dart';
import 'cached_network_image_with_fallback.dart';

/// Renderer markdown bersama: dipakai body pengumuman (#124) dan artikel
/// profil kecamatan (#123) supaya behaviour tap link & preview gambar
/// identik di seluruh app.
///
/// - gambar: lebar penuh, rasio asli, tap -> preview fullscreen pinch-zoom
/// - link: hanya https -> browser eksternal (skema lain diabaikan)
/// - tabel: lebar kolom mengikuti isi, scroll horizontal bila melebihi layar
class SambaskuMarkdown extends StatelessWidget {
  const SambaskuMarkdown({
    super.key,
    required this.data,
    this.selectable = true,
  });

  final String data;

  /// Teks bisa diseleksi (default true, sama dengan body pengumuman).
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    // Jaring pengaman: caller sudah menyaring kosong, tapi renderer tidak
    // boleh menggambar apa pun untuk input kosong.
    if (data.trim().isEmpty) return const SizedBox.shrink();
    return MarkdownBody(
      data: data,
      selectable: selectable,
      imageBuilder: buildSambaskuMarkdownImage,
      onTapLink: (text, href, title) => openSambaskuMarkdownHref(href),
      styleSheet: sambaskuMarkdownStyleSheet(context),
    );
  }
}

/// Style sheet artikel (issue #160). Dipisah supaya ukuran bisa diuji.
///
/// Skala Forui `touch`: xs 14, sm 16, md 18, lg 20, xl 22, xl2 30. Body
/// `sm` (16) sama dengan layar lain; heading turun dari xl2/xl/lg
/// (30/22/20) ke xl/md/sm (22/18/16) supaya tidak mendominasi layar kecil.
/// Korpus artikel memakai h1-h5, tabel, daftar, gambar, link, dan hr.
MarkdownStyleSheet sambaskuMarkdownStyleSheet(BuildContext context) {
  final theme = context.theme;
  final typo = theme.typography.body;
  final colors = theme.colors;
  const bold = FontWeight.w700;
  // ponytail: `MarkdownStyleSheet.fromTheme` butuh ThemeData flutter/material,
  // sedangkan app sudah pakai material_ui (forui 0.27). Semua field yang
  // dipakai diisi eksplisit dari token forui; sisanya default null.
  return MarkdownStyleSheet(
    p: typo.sm.copyWith(height: 1.5),
    h1: typo.xl.copyWith(fontWeight: bold, height: 1.3),
    h2: typo.md.copyWith(fontWeight: bold, height: 1.3),
    h3: typo.sm.copyWith(fontWeight: bold, height: 1.3),
    // fromTheme memberi h4-h6 style yang sama (bodyLarge); bedakan eksplisit.
    h4: typo.sm.copyWith(fontWeight: bold, height: 1.3),
    h5: typo.xs.copyWith(fontWeight: bold, height: 1.3),
    h6: typo.xs.copyWith(
      fontWeight: bold,
      height: 1.3,
      color: colors.mutedForeground,
    ),
    // Jarak di atas heading memisahkan bagian; padding bawah dijaga kecil.
    h1Padding: const EdgeInsets.only(top: 8, bottom: 2),
    h2Padding: const EdgeInsets.only(top: 8, bottom: 2),
    h3Padding: const EdgeInsets.only(top: 4),
    h4Padding: const EdgeInsets.only(top: 4),
    em: typo.sm.copyWith(fontStyle: FontStyle.italic),
    strong: typo.sm.copyWith(fontWeight: bold),
    listBullet: typo.sm,
    // ponytail: default flutter_markdown 8px; 4px lebih rapat, belum diuji
    // visual di device. Naikkan kalau terasa terlalu padat.
    blockSpacing: 4,
    // Tabel: IntrinsicColumnWidth -> lebar kolom ikut isi dan flutter_markdown
    // membungkusnya dengan scroll horizontal. Default FlexColumnWidth memecah
    // tabel 6-7 kolom jadi kolom sempit dengan teks terpotong per huruf.
    tableColumnWidth: const IntrinsicColumnWidth(),
    tableHead: typo.sm.copyWith(fontWeight: bold),
    tableBody: typo.sm,
    tableHeadAlign: TextAlign.left,
    tableCellsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    tableBorder: TableBorder.all(color: colors.border),
    // Default blockquote/hr memakai Colors.blue dan garis 5px yang tidak
    // adaptif dark mode; pakai warna tema.
    blockquote: typo.sm.copyWith(color: colors.mutedForeground),
    blockquotePadding: const EdgeInsets.only(left: 12),
    blockquoteDecoration: BoxDecoration(
      border: Border(left: BorderSide(color: colors.border, width: 3)),
    ),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(top: BorderSide(color: colors.border)),
    ),
  );
}

/// Gambar di body markdown: lebar penuh, tinggi ikut rasio asli (expand:
/// false); tap -> preview fullscreen dengan pinch-zoom.
// ponytail: flutter_markdown_plus membuang fragmen `#WxH` sebelum memanggil
// imageBuilder, jadi ukuran eksplisit di md diabaikan. Tambah lagi bila ada
// konten yang butuh (parse sendiri dari `data`).
Widget buildSambaskuMarkdownImage(Uri uri, String? title, String? alt) {
  final src = uri.toString();
  if (src.isEmpty) return const SizedBox.shrink();
  return Builder(
    builder: (context) => GestureDetector(
      onTap: () => showImagePreview(context, urls: [src]),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Semantics(
          button: true,
          label: alt != null && alt.isNotEmpty ? alt : 'Lihat gambar',
          child: CachedNetworkImageWithFallback(
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
  unawaited(launchExternalUrl(uri));
}
