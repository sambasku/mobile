import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../core/widgets/image_preview.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';

const encyclopediaHeroAspect = 16 / 10;

/// Hero sampul artikel: full-bleed 16:10, judul (+ excerpt) di atas gradasi bawah.
class EncyclopediaArticleHero extends StatelessWidget {
  const EncyclopediaArticleHero({
    super.key,
    required this.coverUrl,
    required this.title,
    this.excerpt,
  });

  final String coverUrl;
  final String title;
  final String? excerpt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final trimmedExcerpt = excerpt?.trim();

    return GestureDetector(
      onTap: () => showImagePreview(context, urls: [coverUrl]),
      child: Semantics(
        button: true,
        label: l10n.encyclopediaCoverSemantics,
        child: AspectRatio(
          aspectRatio: encyclopediaHeroAspect,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(
                color: theme.colors.muted,
                child: CachedNetworkImageWithFallback(
                  imageUrl: coverUrl,
                  fallbackUrl: coverUrl,
                  fit: BoxFit.cover,
                ),
              ),
              const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment(0, -0.35),
                      colors: [Color(0x73000000), Colors.transparent],
                    ),
                  ),
                ),
              ),
              const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment(0, 0.35),
                      colors: [Color(0xE6000000), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.typography.display.md.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    if (trimmedExcerpt != null && trimmedExcerpt.isNotEmpty) ...[
                      const Gap(8),
                      Text(
                        trimmedExcerpt,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.body.sm.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}