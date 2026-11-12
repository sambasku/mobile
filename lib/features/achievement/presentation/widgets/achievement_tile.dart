import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/achievement.dart';

/// Baris satu pencapaian (semua kategori) untuk sub-tab Pencapaian.
///
/// Locked = siluet abu + progres (bila agregat) / "Belum dibuka";
/// owned = thumbnail aset + deskripsi. FTileMixin supaya bisa jadi anak
/// FTileGroup.
///
/// [dense] = ringkasan profil: ikon lebih kecil, hanya judul (tanpa
/// subtitle) supaya baris tidak mepet.
class AchievementTile extends StatelessWidget with FTileMixin {
  const AchievementTile({
    super.key,
    required this.item,
    required this.onTap,
    this.dense = false,
  });

  final Achievement item;
  final VoidCallback onTap;

  /// true → ikon 28 + title saja (preview profil).
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final owned = item.isOwned;
    final thumbSize = dense ? 28.0 : 40.0;
    final iconSize = dense ? 14.0 : 20.0;
    final url = owned
        ? (displayImageUrl(item.badgeUrl, width: dense ? 64 : 128) ??
              item.badgeUrl)
        : null;

    Widget fallbackThumb() => Container(
      width: thumbSize,
      height: thumbSize,
      decoration: BoxDecoration(
        color: theme.colors.muted,
        shape: BoxShape.circle,
      ),
      child: Icon(
        item.isSticker ? FLucideIcons.stickyNote : FLucideIcons.award,
        size: iconSize,
        color: theme.colors.mutedForeground,
      ),
    );

    final Widget thumb;
    if (url == null) {
      thumb = fallbackThumb();
    } else {
      thumb = SizedBox(
        width: thumbSize,
        height: thumbSize,
        child: Image.network(
          url,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => fallbackThumb(),
        ),
      );
    }

    final Widget? subtitle;
    if (dense) {
      subtitle = null;
    } else {
      final String text;
      if (owned) {
        text = item.description;
      } else if (item.progress != null) {
        text = l10n.achievementProgress(
          item.progress!.current,
          item.progress!.target,
        );
      } else {
        text = l10n.achievementLocked;
      }
      subtitle = Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: owned
            ? null
            : theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
                fontStyle: FontStyle.italic,
              ),
      );
    }

    return FTile(
      prefix: thumb,
      title: Text(
        item.title,
        style: owned ? null : theme.typography.body.sm,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle,
      suffix: owned
          ? Icon(FLucideIcons.chevronRight, size: dense ? 14 : 16)
          : Icon(FLucideIcons.lock, size: dense ? 14 : 16),
      onPress: onTap,
    );
  }
}

/// Gambar lencana besar untuk bottom sheet detail.
class AchievementBadgeArt extends StatelessWidget {
  const AchievementBadgeArt({
    super.key,
    required this.item,
    this.size = 72,
  });

  final Achievement item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final url = item.isOwned
        ? (displayImageUrl(item.badgeUrl, width: 256) ?? item.badgeUrl)
        : null;
    if (url == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.colors.muted,
          shape: BoxShape.circle,
        ),
        child: Icon(
          item.isSticker ? FLucideIcons.stickyNote : FLucideIcons.award,
          size: size * 0.45,
          color: theme.colors.mutedForeground,
        ),
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: Image.network(
        url,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: theme.colors.muted,
            shape: BoxShape.circle,
          ),
          child: Icon(
            FLucideIcons.award,
            size: size * 0.45,
            color: theme.colors.mutedForeground,
          ),
        ),
      ),
    );
  }
}
