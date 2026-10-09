import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../activity_router.dart';
import '../providers/announcement_detail_provider.dart';
import 'announcement_body.dart';

/// Carousel pengumuman prioritas (pinned) di beranda (#134): banner swipable
/// ringan (judul + preview 1 baris); tap halaman -> LANGSUNG detail dengan
/// payload beku (pola #102), bukan halaman /pinned. Loading/error/kosong =
/// shrink total supaya feed tak bergeser.
class PinnedHomeBanner extends ConsumerStatefulWidget {
  const PinnedHomeBanner({super.key});

  @override
  ConsumerState<PinnedHomeBanner> createState() => _PinnedHomeBannerState();
}

class _PinnedHomeBannerState extends ConsumerState<PinnedHomeBanner> {
  // viewportFraction < 1.0 = satu-satunya cara PageView memberi JARAK antar
  // kartu (tiap halaman lebih sempit dari viewport). Sebelumnya 1.0 → dua
  // kartu bersentuhan tanpa jeda saat swipe. Kartu jadi sedikit lebih sempit
  // dari kartu feed lain, itu konsekuensi yang diminta.
  final PageController _controller = PageController(viewportFraction: 0.94);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pinned = ref.watch(pinnedAnnouncementsProvider(const {}));
    final items = pinned.asData?.value;
    // Error/kosong: hilang total (bukan placeholder kosong). Loading:
    // skeleton #134 - sebelumnya shrink lalu muncul mendadak ("magic").
    if (pinned.isLoading) {
      return const _PinnedHomeBannerSkeleton();
    }
    if (items == null || items.isEmpty) return const SizedBox.shrink();

    // Refresh bisa memendekkan list: jaga _page valid.
    if (_page >= items.length) _page = items.length - 1;

    final theme = context.theme;
    final accent = theme.colors.primary;

    return Padding(
      // #134: banner Diskusi di atas cuma menyumbang bottom 10 - mepet.
      // Carousel pengumuman tambah 8 di atasnya supaya antar kartu bernapas.
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            // Tinggi disamakan dengan banner Ruang Diskusi (82) supaya kedua
            // kartu di beranda seragam - sebelumnya 64 (18px lebih pendek).
            height: 82,
            child: PageView.builder(
              controller: _controller,
              itemCount: items.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) {
                final a = items[i];
                // GestureDetector, bukan InkWell: tanpa ancestor Material
                // (aturan Forui no-material-widgets).
                return GestureDetector(
                  onTap: () => context.pushNamed(
                    ActivityRouter.announcementDetail.name,
                    pathParameters: {'id': a.id},
                    extra: a,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colors.secondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.35),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(FLucideIcons.pin, color: accent, size: 20),
                        const Gap(10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.typography.sm.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Gap(2),
                              Text(
                                announcementPreviewText(a.body, a.bodyType),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.typography.sm.copyWith(
                                  color: theme.colors.mutedForeground,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          FLucideIcons.chevronRight,
                          size: 18,
                          color: theme.colors.mutedForeground,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (items.length > 1) ...[
            const Gap(6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(items.length, (i) {
                final active = i == _page;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: active ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active
                          ? accent
                          : theme.colors.mutedForeground.withValues(
                              alpha: 0.4,
                            ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}

/// Skeleton banner home (#134): bentuk identik banner asli (tinggi 64 +
/// dots) supaya feed tak bergeser saat data datang.
class _PinnedHomeBannerSkeleton extends StatelessWidget {
  const _PinnedHomeBannerSkeleton();

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

    return SkeletonizerConfig(
      data: SkeletonizerConfigData(effect: shimmer),
      child: IgnorePointer(
        child: Skeletonizer(
          enabled: true,
          child: Padding(
            // Harus sama dengan banner asli (top 8 + bottom 10) supaya
            // feed tidak bergeser saat data datang.
            padding: const EdgeInsets.only(top: 8, bottom: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lebar = kartu asli (viewportFraction 0.94) supaya tidak geser
                // horizontal saat data datang.
                FractionallySizedBox(
                  widthFactor: 0.94,
                  alignment: Alignment.center,
                  child: Container(
                    height: 82,
                    decoration: BoxDecoration(
                      color: context.theme.colors.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(
                          FLucideIcons.pin,
                          color: context.theme.colors.primary,
                          size: 20,
                        ),
                        const Gap(10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Judul pengumuman prioritas',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.theme.typography.sm.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Gap(2),
                              Text(
                                'cuplikan isi pengumuman',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.theme.typography.sm.copyWith(
                                  color: context.theme.colors.mutedForeground,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        width: i == 0 ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: context.theme.colors.mutedForeground,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
