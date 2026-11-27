import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../domain/karya.dart';
import 'karya_film_format.dart';
import 'karya_media_frame.dart';

/// Identitas atas detail karya film - poster + judul horizontal, tonton block bawah.
class KaryaFilmStage extends StatelessWidget {
  const KaryaFilmStage({
    super.key,
    required this.item,
    this.watchLabel,
    this.onWatch,
    this.trailerLabel,
    this.onTrailer,
  });

  final KaryaEntry item;

  /// Label CTA tonton (bukan trailer). Null = belum ada tautan tonton.
  final String? watchLabel;

  /// Buka tautan tonton luar app. Null = tombol tonton disembunyikan.
  final VoidCallback? onWatch;

  /// Label CTA trailer terpisah. Null = tidak ada trailer.
  final String? trailerLabel;

  /// Buka tautan trailer. Null = tombol trailer disembunyikan.
  final VoidCallback? onTrailer;

  static const double _posterWidth = 110;
  static const double _posterHeight = 165;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final director = karyaPrimaryDirectorName(item.credits);
    final meta = _metaLine(l10n);
    final canWatch = onWatch != null && (watchLabel ?? '').trim().isNotEmpty;
    final canTrailer =
        onTrailer != null && (trailerLabel ?? '').trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PosterArt(
              coverUrl: item.coverUrl,
              width: _posterWidth,
              height: _posterHeight,
            ),
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
        if (director != null) ...[
          const Gap(10),
          Text(
            director,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const Gap(12),
        if (canWatch || canTrailer)
          Row(
            children: [
              if (canWatch)
                Expanded(
                  child: FButton(
                    size: .sm,
                    onPress: onWatch,
                    prefix: const Icon(FLucideIcons.play),
                    child: Text(watchLabel!.trim()),
                  ),
                ),
              if (canWatch && canTrailer) const Gap(8),
              if (canTrailer)
                Expanded(
                  child: FButton(
                    size: .sm,
                    variant: FButtonVariant.outline,
                    onPress: onTrailer,
                    prefix: const Icon(FLucideIcons.clapperboard),
                    child: Text(trailerLabel!.trim()),
                  ),
                ),
            ],
          )
        else
          Text(
            l10n.karyaFilmWatchEmpty,
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
      ],
    );
  }

  String _metaLine(AppLocalizations l10n) {
    final runtime = karyaFilmRuntimeMinutes(item.filmRuntimeMin);
    final parts = <String>[
      if (item.year != null) l10n.karyaYearLabel(item.year!),
      ?_filmTypeLabel(l10n, item.filmType),
      if (runtime != null) l10n.karyaFilmRuntimeMinutes(runtime),
    ];
    return parts.join(' · ');
  }

  static String? _filmTypeLabel(AppLocalizations l10n, String? type) {
    return switch (type) {
      'feature' => l10n.karyaFilmTypeFeature,
      'short' => l10n.karyaFilmTypeShort,
      'documentary' => l10n.karyaFilmTypeDocumentary,
      'other' => l10n.karyaFilmTypeOther,
      _ => null,
    };
  }
}

class _PosterArt extends StatelessWidget {
  const _PosterArt({
    required this.coverUrl,
    required this.width,
    required this.height,
  });

  final String? coverUrl;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final url = (coverUrl ?? '').trim();
    final art = KaryaMediaFrame(
      width: width,
      height: height,
      child: url.isEmpty
          ? Center(
              child: Icon(
                FLucideIcons.clapperboard,
                size: 36,
                color: theme.colors.primary,
              ),
            )
          : CachedNetworkImageWithFallback(
              imageUrl: displayImageUrl(url, width: 256) ?? url,
              fallbackUrl: url,
              fit: BoxFit.cover,
              fallback: Center(
                child: Icon(
                  FLucideIcons.clapperboard,
                  size: 36,
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
