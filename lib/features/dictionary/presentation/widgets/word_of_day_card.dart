import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../dictionary_router.dart';
import '../../domain/entities/word_of_day.dart';
import '../providers/card_images_providers.dart';
import '../providers/word_of_day_providers.dart';

/// Kartu Kata Hari Ini. Soft-fail: loading = shimmer; null/error = hilang.
class WordOfDayCard extends ConsumerWidget {
  const WordOfDayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(wordOfDayProvider);

    return async.when(
      loading: () => const _WordOfDaySkeleton(),
      error: (_, _) => const SizedBox.shrink(),
      data: (item) {
        if (item == null) return const SizedBox.shrink();
        return _WordOfDayBody(item: item);
      },
    );
  }
}

class _WordOfDayBody extends ConsumerWidget {
  const _WordOfDayBody({required this.item});

  final WordOfDay item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final sense = item.firstSense;
    final dateLabel = formatDateYmd(item.date);

    // Scrim lebih pekat di dark mode (kontras teks + ketenangan malam).
    final scrimAlpha = Theme.of(context).brightness == Brightness.dark
        ? 0.45
        : 0.30;

    // Background dinamis dari CDN (home.json). Null → asset bundled.
    final config = ref.watch(cardImagesProvider).value;
    final wotdImage = config?.entryOf('wotd');
    final bgAlignment = wotdImage?.alignmentValue ?? Alignment.bottomCenter;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            // 1. Background image (CDN config, fallback asset bundled)
            Positioned.fill(
              child: wotdImage == null
                  ? Image.asset(
                      'assets/images/wotd_cover.webp',
                      fit: BoxFit.cover,
                      alignment: bgAlignment,
                    )
                  : Image.network(
                      wotdImage.imageUrl,
                      fit: BoxFit.cover,
                      alignment: bgAlignment,
                      errorBuilder: (_, _, _) => Image.asset(
                        'assets/images/wotd_cover.webp',
                        fit: BoxFit.cover,
                        alignment: bgAlignment,
                      ),
                    ),
            ),
            // 2. Overlay gradient: atas terang, bawah gelap (area teks utama)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.10),
                      Colors.black.withValues(alpha: scrimAlpha),
                    ],
                    stops: const [0.0, 0.35, 1.0],
                  ),
                ),
              ),
            ),
            // 3. Konten
            InkWell(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                AnalyticsService.instance.log(
                  AnalyticsEvents.wotdTap,
                  params: {'word_id': item.word.id},
                );
                context.push(
                  DictionaryRouter.detail.path.replaceFirst(':id', item.word.id),
                );
              },
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Icon(
                                      FLucideIcons.sun,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const Gap(8),
                                Expanded(
                                  child: Text(
                                    'Kata hari ini',
                                    style: theme.typography.xs.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(alpha: 0.4),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (dateLabel.isNotEmpty)
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      child: Text(
                                        dateLabel,
                                        style: theme.typography.xs.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const Gap(6),
                            Text(
                              item.word.lemma,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.typography.lg.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                            if (sense.isNotEmpty) ...[
                              const Gap(2),
                              Text(
                                sense,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.typography.sm.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const Gap(4),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                child: Text(
                                  item.isNewThisWeek
                                      ? 'Ditampilkan hari ini · baru minggu ini'
                                      : 'Ditampilkan hari ini, berganti setiap hari',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.typography.xs.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordOfDaySkeleton extends StatelessWidget {
  const _WordOfDaySkeleton();

  @override
  Widget build(BuildContext context) {
    final materialBrightness = Theme.of(context).brightness;
    final isDark = materialBrightness == Brightness.dark;
    final muted = context.theme.colors.muted;
    final shimmer = ShimmerEffect(
      baseColor: isDark
          ? muted.withValues(alpha: 0.35)
          : const Color(0xFFE7E7EA),
      highlightColor: isDark
          ? muted.withValues(alpha: 0.55)
          : const Color(0xFFF4F4F5),
      duration: const Duration(milliseconds: 1500),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SkeletonizerConfig(
        data: SkeletonizerConfigData(effect: shimmer),
        child: IgnorePointer(
          child: Material(
            color: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                // Background image
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: const AssetImage('assets/images/wotd_cover.webp'),
                        fit: BoxFit.cover,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.10),
                          Colors.black.withValues(alpha: 0.30),
                        ],
                        stops: const [0.0, 0.35, 1.0],
                      ),
                    ),
                  ),
                ),
                // Skeleton content
                const Padding(
                  padding: EdgeInsets.fromLTRB(14, 8, 10, 8),
                  child: Skeletonizer(
                    enabled: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kata hari ini'),
                        Gap(6),
                        Text('lemma contoh'),
                        Gap(2),
                        Text('arti pertama satu baris'),
                        Gap(4),
                        Text('Ditampilkan hari ini, berganti setiap hari'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}