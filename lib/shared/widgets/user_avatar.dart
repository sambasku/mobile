import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../core/utils/display_image_url.dart';

/// Avatar lingkaran kanonik (foto jaringan atau ikon user).
///
/// Diameter diseragamkan lewat [SizedBox] + [ClipOval].
/// Foto: URL asli dulu, lalu URL display (wsrv) sebagai fallback.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.name, this.imageUrl, this.size = 36});

  /// Dipakai untuk semantics / aksesibilitas; tidak ditampilkan sebagai inisial.
  final String? name;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final placeholder = ColoredBox(
      color: theme.colors.muted,
      child: Center(
        child: Icon(
          FLucideIcons.userRound,
          size: size * 0.42,
          color: theme.colors.mutedForeground,
        ),
      ),
    );

    final raw = imageUrl?.trim();
    final hasPhoto = raw != null && raw.isNotEmpty;
    final display = hasPhoto ? (displayImageUrl(raw, width: 256) ?? raw) : null;

    // Decode di ukuran layar, bukan resolusi asli: feed berisi banyak avatar
    // 40px, decode gambar 512px+ per baris = jank saat scroll.
    final cacheWidth = (size * MediaQuery.devicePixelRatioOf(context)).round();

    final Widget child;
    if (hasPhoto) {
      child = Image.network(
        raw,
        width: size,
        height: size,
        cacheWidth: cacheWidth,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) {
          if (display != null && display.isNotEmpty && display != raw) {
            return Image.network(
              display,
              width: size,
              height: size,
              cacheWidth: cacheWidth,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => placeholder,
            );
          }
          return placeholder;
        },
      );
    } else {
      child = placeholder;
    }

    return Semantics(
      label: name,
      child: SizedBox(
        width: size,
        height: size,
        child: ClipOval(child: child),
      ),
    );
  }
}
