import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../activity_router.dart';
import '../providers/announcement_detail_provider.dart';
import 'announcement_body.dart';

/// Carousel pengumuman prioritas (pinned) di beranda (#134): banner ringkas
/// swipable (judul + preview 1 baris) yang full-bleed selebar layar - jarak
/// antar kartu hidup di area bekas gutter, kartu tidak jadi sempit. Tap
/// kartu -> LANGSUNG detail dengan payload beku (pola #102). Loading/error/
/// kosong = shrink total supaya feed tak bergeser.
class PinnedHomeBanner extends ConsumerStatefulWidget {
  const PinnedHomeBanner({super.key});

  @override
  ConsumerState<PinnedHomeBanner> createState() => _PinnedHomeBannerState();
}

class _PinnedHomeBannerState extends ConsumerState<PinnedHomeBanner> {
  final _scroll = ScrollController();
  var _page = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  // Stride (kartu + Gap) = lebar viewport, jadi offset/viewport = nomor
  // halaman persis. Cukup listener offset, tanpa PageController.
  void _onScroll() {
    if (!_scroll.hasClients) return;
    final dim = _scroll.position.viewportDimension;
    if (dim <= 0) return;
    final page = (_scroll.offset / dim).round();
    if (page != _page) setState(() => _page = page);
  }

  @override
  Widget build(BuildContext context) {
    final pinned = ref.watch(pinnedAnnouncementsProvider(const {}));
    final items = pinned.asData?.value;
    // Skeleton hanya saat loading TANPA data (saat reload
    // pull-to-refresh data lama tetap tampil, tidak berkedip skeleton).
    if (pinned.isLoading && items == null) {
      return const _PinnedHomeBannerSkeleton();
    }
    // Error/kosong: hilang total (bukan placeholder kosong).
    if (items == null || items.isEmpty) return const SizedBox.shrink();

    final theme = context.theme;
    final accent = theme.colors.primary;
    final page = _page.clamp(0, items.length - 1);

    return Padding(
      // Napas vertikal minimal antar kartu beranda (permintaan review):
      // Ruang Diskusi di atas + heading teks di bawah.
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            // Tinggi disamakan dengan banner Ruang Diskusi (82) supaya kedua
            // kartu di beranda seragam.
            height: 82,
            // Full-bleed + snap presisi (pola halaman /pinned): list padding 12,
            // kartu = layar - 24 (lebar sama seperti sebelum childPad shell
            // dimatikan), Gap(24) pemisah. Stride = lebar viewport sehingga
            // PageScrollPhysics mendarat presisi rata kiri; di tepi kanan hanya
            // terlihat jarak napas, bukan kartu tetangga yang mengintip.
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth - 24;
                return ListView.separated(
                  controller: _scroll,
                  scrollDirection: Axis.horizontal,
                  physics: const PageScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Gap(24),
                  itemBuilder: (context, i) {
                    final a = items[i];
                    // GestureDetector, bukan InkWell: tanpa ancestor Material
                    // (aturan Forui no-material-widgets).
                    return SizedBox(
                      width: cardWidth,
                      child: Semantics(
                        button: true,
                        label:
                            'Pengumuman: ${a.title}${a.expired ? ', sudah berakhir' : ''}',
                        child: GestureDetector(
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
                      ),
                    ),
                  );
                },
              );
              },
            ),
          ),
          // Indikator titik: hanya saat ada halaman untuk digeser.
          if (items.length > 1) ...[
            const Gap(6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < items.length; i++)
                  Container(
                    key: ValueKey('pinned_dot_$i'),
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == page
                          ? accent
                          : theme.colors.mutedForeground.withValues(
                              alpha: 0.4,
                            ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Skeleton banner home (#134): bentuk identik banner asli (kartu tinggi 82
/// dengan gutter 12) supaya feed tak bergeser saat data datang.
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
            // Harus sama dengan banner asli (top 4 + bottom 4, gutter 12,
            // + baris dots) supaya feed tidak bergeser saat data datang.
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
                // Dots palsu: menutupi tinggi baris indikator kartu asli.
                const Gap(6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.theme.colors.mutedForeground,
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
