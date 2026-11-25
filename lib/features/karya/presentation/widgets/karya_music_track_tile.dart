import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../domain/karya.dart';
import '../../karya_router.dart';
import 'karya_media_frame.dart';
import 'karya_music_format.dart';

/// Baris trek untuk daftar filter Musik.
class KaryaMusicTrackTile extends StatelessWidget {
  const KaryaMusicTrackTile({super.key, required this.item});

  final KaryaEntry item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final artist = karyaPrimaryArtistName(item.credits);
    final yearLabel =
        item.year == null ? null : l10n.karyaYearLabel(item.year!);
    final subtitle = [
      ?artist,
      ?yearLabel,
    ].join(' · ');
    final duration = item.musicDurationMs == null
        ? null
        : formatKaryaMusicDuration(item.musicDurationMs!);

    return FTappable(
      onPress: () => context.push(KaryaRouter.detailPath(item.slug)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Thumb(coverUrl: item.coverUrl),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const Gap(4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (duration != null) ...[
              const Gap(8),
              Text(
                duration,
                style: theme.typography.body.xs.copyWith(
                  color: theme.colors.mutedForeground,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.coverUrl});

  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final url = (coverUrl ?? '').trim();
    return KaryaMediaFrame(
      width: 40,
      height: 40,
      borderRadius: 8,
      child: url.isEmpty
          ? Center(
              child: Icon(
                FLucideIcons.disc3,
                size: 18,
                color: theme.colors.primary,
              ),
            )
          : CachedNetworkImageWithFallback(
              imageUrl: displayImageUrl(url, width: 96) ?? url,
              fallbackUrl: url,
              fit: BoxFit.cover,
              fallback: Center(
                child: Icon(
                  FLucideIcons.disc3,
                  size: 18,
                  color: theme.colors.primary,
                ),
              ),
            ),
    );
  }
}
