import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
  final PageController _controller = PageController();
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
    // Loading/error/kosong: hilang, bukan placeholder kosong.
    if (items == null || items.isEmpty) return const SizedBox.shrink();

    // Refresh bisa memendekkan list: jaga _page valid.
    if (_page >= items.length) _page = items.length - 1;

    final theme = context.theme;
    final accent = theme.colors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 64,
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
                    margin: const EdgeInsets.symmetric(horizontal: 2),
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
