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
class AchievementTile extends StatelessWidget with FTileMixin {
  const AchievementTile({super.key, required this.item, required this.onTap});

  final Achievement item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final owned = item.isOwned;
    final url = owned
        ? (displayImageUrl(item.badgeUrl, width: 128) ?? item.badgeUrl)
        : null;

    final Widget thumb;
    if (url == null) {
      thumb = Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colors.muted,
          shape: BoxShape.circle,
        ),
        child: Icon(
          item.isSticker ? FLucideIcons.stickyNote : FLucideIcons.award,
          size: 20,
          color: theme.colors.mutedForeground,
        ),
      );
    } else {
      thumb = SizedBox(
        width: 40,
        height: 40,
        child: Image.network(
          url,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colors.muted,
              shape: BoxShape.circle,
            ),
            child: Icon(
              FLucideIcons.award,
              size: 20,
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
      );
    }

    final String subtitle;
    if (owned) {
      subtitle = item.description;
    } else if (item.progress != null) {
      subtitle = l10n.achievementProgress(
        item.progress!.current,
        item.progress!.target,
      );
    } else {
      subtitle = l10n.achievementLocked;
    }

    return FTile(
      prefix: thumb,
      title: Text(
        item.title,
        style: owned ? null : theme.typography.body.sm,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: owned
            ? null
            : theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
                fontStyle: FontStyle.italic,
              ),
      ),
      suffix: owned
          ? const Icon(FLucideIcons.chevronRight, size: 16)
          : const Icon(FLucideIcons.lock, size: 16),
      onPress: onTap,
    );
  }
}
