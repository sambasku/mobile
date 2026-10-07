import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/theme/f_colors_x.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../domain/entities/feed_activity_item.dart';

/// Avatar baris feed: foto profil (atau ikon user) plus badge jenis di kanan bawah.
///
/// Foto dan fallback ikon user diurus [UserAvatar]. Badge memakai ikon
/// aksi per [kind] dengan latar solid supaya tetap terbaca di atas foto.
class ActivityKindAvatar extends StatelessWidget {
  const ActivityKindAvatar({
    super.key,
    required this.kind,
    this.imageUrl,
    this.name,
    this.voteUp,
    this.size = 36,
  });

  final FeedActivityKind kind;
  final String? imageUrl;

  /// Diteruskan ke [UserAvatar] sebagai label semantics.
  final String? name;

  /// Arah vote. `true` panah naik, `false` panah turun. Diabaikan selain vote.
  final bool? voteUp;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final style = _styleFor(kind, theme, voteUp: voteUp);
    final badge = size * 0.4;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          UserAvatar(name: name, imageUrl: imageUrl, size: size),
          Positioned(
            right: -1,
            bottom: -1,
            // Icon digambar sebagai glyph. Skeletonizer menggantinya dengan
            // tulang dari baseline font, bukan dari kotak ikon, jadi di badge
            // ~16px tulang itu geser dari pusat lingkaran. Leaf memaksa satu
            // tulang lingkaran dan tidak menggambar glyph-nya.
            child: Skeleton.leaf(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: style.foreground,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colors.background,
                    width: 1.5,
                  ),
                ),
                child: SizedBox(
                  width: badge,
                  height: badge,
                  child: Icon(
                    style.icon,
                    size: badge * 0.55,
                    color: theme.colors.background,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static _KindAvatarStyle _styleFor(
    FeedActivityKind kind,
    FThemeData theme, {
    bool? voteUp,
  }) {
    final primary = theme.colors.primary;
    final secondary = theme.colors.secondaryForeground;
    final mutedFg = theme.colors.mutedForeground;

    switch (kind) {
      case FeedActivityKind.word:
        return _KindAvatarStyle(
          icon: FLucideIcons.bookOpen,
          foreground: primary,
        );
      case FeedActivityKind.comment:
        return _KindAvatarStyle(
          icon: FLucideIcons.messageCircle,
          foreground: secondary,
        );
      case FeedActivityKind.vote:
        final up = voteUp ?? true;
        return _KindAvatarStyle(
          icon: up ? FLucideIcons.arrowBigUp : FLucideIcons.arrowBigDown,
          foreground: up ? theme.colors.success : theme.colors.destructive,
        );
      case FeedActivityKind.discussion:
        return _KindAvatarStyle(
          icon: FLucideIcons.messagesSquare,
          foreground: secondary,
        );
      case FeedActivityKind.wordImage:
        return _KindAvatarStyle(icon: FLucideIcons.image, foreground: primary);
      case FeedActivityKind.wordAudio:
        return _KindAvatarStyle(icon: FLucideIcons.mic, foreground: secondary);
      case FeedActivityKind.pronunciation:
        return _KindAvatarStyle(
          icon: FLucideIcons.audioLines,
          foreground: primary,
        );
      case FeedActivityKind.example:
        return _KindAvatarStyle(
          icon: FLucideIcons.textQuote,
          foreground: secondary,
        );
      case FeedActivityKind.searchMiss:
        return _KindAvatarStyle(
          icon: FLucideIcons.searchX,
          foreground: mutedFg,
        );
      case FeedActivityKind.welcome:
        return _KindAvatarStyle(
          icon: FLucideIcons.sparkles,
          foreground: primary,
        );
      case FeedActivityKind.cardShare:
        return _KindAvatarStyle(
          icon: FLucideIcons.share2,
          foreground: secondary,
        );
      case FeedActivityKind.suggestion:
        return _KindAvatarStyle(
          icon: FLucideIcons.pencilLine,
          foreground: primary,
        );
      case FeedActivityKind.contribution:
        return _KindAvatarStyle(
          icon: FLucideIcons.filePlus2,
          foreground: primary,
        );
      case FeedActivityKind.verification:
        // #99: verifikasi reviewer = check, BUKAN panah vote.
        return _KindAvatarStyle(
          icon: FLucideIcons.check,
          foreground: theme.colors.success,
        );
    }
  }
}

class _KindAvatarStyle {
  const _KindAvatarStyle({required this.icon, required this.foreground});

  final IconData icon;
  final Color foreground;
}
