import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../domain/entities/feed_activity_item.dart';

/// Avatar baris feed: foto profil aktor bila ada, else ikon aksi per [kind].
///
/// Diameter diseragamkan lewat [SizedBox] + [ClipOval].
/// Foto: coba URL asli dulu, lalu URL display (wsrv) - supaya jsDelivr
/// tidak tergantung proxy yang sering gagal.
class ActivityKindAvatar extends StatelessWidget {
  const ActivityKindAvatar({
    super.key,
    required this.kind,
    this.imageUrl,
    this.size = 36,
  });

  final FeedActivityKind kind;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(kind, context.theme);
    final kindIcon = Icon(
      style.icon,
      size: size * 0.44,
      color: style.foreground,
    );
    final placeholder = ColoredBox(
      color: style.background,
      child: Center(child: kindIcon),
    );

    final raw = imageUrl?.trim();
    final hasPhoto = raw != null && raw.isNotEmpty;
    final display = hasPhoto
        ? (displayImageUrl(raw, width: 256) ?? raw)
        : null;

    final Widget child;
    if (hasPhoto) {
      // URL asli dulu (lebih andal); display/wsrv hanya fallback.
      child = Image.network(
        raw,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) {
          if (display != null && display.isNotEmpty && display != raw) {
            return Image.network(
              display,
              width: size,
              height: size,
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

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(child: child),
    );
  }

  static _KindAvatarStyle _styleFor(FeedActivityKind kind, FThemeData theme) {
    final primary = theme.colors.primary;
    final secondary = theme.colors.secondaryForeground;
    final mutedFg = theme.colors.mutedForeground;

    switch (kind) {
      case FeedActivityKind.word:
        return _KindAvatarStyle(
          icon: FLucideIcons.bookOpen,
          background: primary.withValues(alpha: 0.14),
          foreground: primary,
        );
      case FeedActivityKind.comment:
        return _KindAvatarStyle(
          icon: FLucideIcons.messageCircle,
          background: secondary.withValues(alpha: 0.14),
          foreground: secondary,
        );
      case FeedActivityKind.vote:
        return _KindAvatarStyle(
          icon: FLucideIcons.thumbsUp,
          background: primary.withValues(alpha: 0.14),
          foreground: primary,
        );
      case FeedActivityKind.discussion:
        return _KindAvatarStyle(
          icon: FLucideIcons.messagesSquare,
          background: secondary.withValues(alpha: 0.14),
          foreground: secondary,
        );
      case FeedActivityKind.wordImage:
        return _KindAvatarStyle(
          icon: FLucideIcons.image,
          background: primary.withValues(alpha: 0.12),
          foreground: primary,
        );
      case FeedActivityKind.wordAudio:
        return _KindAvatarStyle(
          icon: FLucideIcons.mic,
          background: secondary.withValues(alpha: 0.12),
          foreground: secondary,
        );
      case FeedActivityKind.pronunciation:
        return _KindAvatarStyle(
          icon: FLucideIcons.audioLines,
          background: primary.withValues(alpha: 0.12),
          foreground: primary,
        );
      case FeedActivityKind.example:
        return _KindAvatarStyle(
          icon: FLucideIcons.textQuote,
          background: secondary.withValues(alpha: 0.12),
          foreground: secondary,
        );
      case FeedActivityKind.searchMiss:
        return _KindAvatarStyle(
          icon: FLucideIcons.searchX,
          background: mutedFg.withValues(alpha: 0.14),
          foreground: mutedFg,
        );
      case FeedActivityKind.welcome:
        return _KindAvatarStyle(
          icon: FLucideIcons.sparkles,
          background: primary.withValues(alpha: 0.14),
          foreground: primary,
        );
    }
  }
}

class _KindAvatarStyle {
  const _KindAvatarStyle({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
}
