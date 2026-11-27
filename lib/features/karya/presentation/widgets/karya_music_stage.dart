import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../domain/karya.dart';
import 'karya_media_frame.dart';
import 'karya_music_format.dart';

/// Identitas atas detail karya musik - sampul + judul horizontal, play block bawah.
class KaryaMusicStage extends StatelessWidget {
  const KaryaMusicStage({
    super.key,
    required this.item,
    this.listenLabel,
    this.onListen,
  });

  final KaryaEntry item;

  /// Label CTA dengar dari tautan akses primer. Null = belum ada tautan.
  final String? listenLabel;

  /// Buka tautan dengar luar app. Null = tombol play disembunyikan.
  final VoidCallback? onListen;

  static const double _coverSize = 80;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final artist = karyaPrimaryArtistName(item.credits);
    final meta = _metaLine(l10n);
    final canListen = onListen != null && (listenLabel ?? '').trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CoverArt(coverUrl: item.coverUrl, size: _coverSize),
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
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  if (meta.isNotEmpty) ...[
                    const Gap(4),
                    Text(
                      meta,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (artist != null) ...[
          const Gap(10),
          Text(
            artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const Gap(12),
        if (canListen)
          FButton(
            size: .sm,
            onPress: onListen,
            prefix: const Icon(FLucideIcons.play),
            child: Text(listenLabel!.trim()),
          )
        else
          Text(
            l10n.karyaMusicListenEmpty,
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
      ],
    );
  }

  String _metaLine(AppLocalizations l10n) {
    final parts = <String>[
      if (item.year != null) l10n.karyaYearLabel(item.year!),
      ?_releaseTypeLabel(l10n, item.musicReleaseType),
      if (item.musicDurationMs != null)
        formatKaryaMusicDuration(item.musicDurationMs!),
      if (item.musicIsCover) l10n.karyaMusicIsCoverBadge,
    ];
    return parts.join(' · ');
  }

  static String? _releaseTypeLabel(AppLocalizations l10n, String? type) {
    return switch (type) {
      'single' => l10n.karyaMusicReleaseSingle,
      'album_track' => l10n.karyaMusicReleaseAlbumTrack,
      'other' => l10n.karyaMusicReleaseOther,
      _ => null,
    };
  }
}

class _CoverArt extends StatelessWidget {
  const _CoverArt({required this.coverUrl, required this.size});

  final String? coverUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final url = (coverUrl ?? '').trim();
    final art = KaryaMediaFrame(
      width: size,
      height: size,
      child: url.isEmpty
          ? Center(
              child: Icon(
                FLucideIcons.disc3,
                size: 32,
                color: theme.colors.primary,
              ),
            )
          : CachedNetworkImageWithFallback(
              imageUrl: displayImageUrl(url, width: 256) ?? url,
              fallbackUrl: url,
              fit: BoxFit.cover,
              fallback: Center(
                child: Icon(
                  FLucideIcons.disc3,
                  size: 32,
                  color: theme.colors.primary,
                ),
              ),
            ),
    );
    if (url.isEmpty) return art;
    return GestureDetector(
      onTap: () => showImagePreview(context, urls: [url]),
      child: art,
    );
  }
}
