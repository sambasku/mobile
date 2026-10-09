import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../activity_router.dart';
import '../../domain/entities/feed_activity_item.dart';
import '../providers/announcement_detail_provider.dart';
import '../widgets/announcement_body.dart';

/// Halaman pengumuman yang dipin (mobile carousel / halaman pinned).
/// - 0 item → shrink: teks "Tidak ada pengumuman yang dipin"
/// - 1 item → single card (mirip AnnouncementDetailPage, tanpa carousel)
/// - >1 item → scroll horizontal bebas, kartu dipisah Gap() murni
class PinnedAnnouncementsPage extends ConsumerStatefulWidget {
  const PinnedAnnouncementsPage({super.key});

  @override
  ConsumerState<PinnedAnnouncementsPage> createState() =>
      _PinnedAnnouncementsPageState();
}

class _PinnedAnnouncementsPageState
    extends ConsumerState<PinnedAnnouncementsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final pinnedAsync = ref.watch(pinnedAnnouncementsProvider(const {}));

    return FScaffold(
      header: FHeader.nested(
        title: const Text('Pengumuman Prioritas'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      childPad: true,
      child: pinnedAsync.when(
        loading: () => _buildSkeleton(context),
        error: (err, _) => _buildError(context, err, ref),
        data: (items) => _buildContent(context, theme, items),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    FThemeData theme,
    List<FeedAnnouncement> items,
  ) {
    if (items.isEmpty) {
      return _buildEmpty(theme);
    }

    if (items.length == 1) {
      return _buildSingle(context, theme, items.first);
    }

    return _buildCarousel(context, theme, items);
  }

  Widget _buildEmpty(FThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FLucideIcons.pinOff,
              size: 48,
              color: theme.colors.mutedForeground,
            ),
            const Gap(12),
            Text(
              'Tidak ada pengumuman yang dipin',
              textAlign: TextAlign.center,
              style: theme.typography.md.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingle(
    BuildContext context,
    FThemeData theme,
    FeedAnnouncement announcement,
  ) {
    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        // #134: FScaffold childPad sudah kasih horizontal 12 - konten cukup
        // vertikal, jangan tambah horizontal (gutter menumpuk).
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [_PinnedAnnouncementCard(announcement: announcement)],
      ),
    );
  }

  Widget _buildCarousel(
    BuildContext context,
    FThemeData theme,
    List<FeedAnnouncement> items,
  ) {
    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      // Carousel ideal: snap per kartu + jarak napas. Kartu = lebar - 12,
      // dipisah Gap(12) → stride tiap item pas sama lebar viewport, jadi
      // PageScrollPhysics mendarat presisi rata kiri. Di tepi kanan hanya
      // terlihat jarak 12px (napas), bukan kartu tetangga yang mengintip.
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth - 12;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const PageScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Gap(12),
            itemBuilder: (_, index) => SizedBox(
              width: cardWidth,
              child: _PinnedAnnouncementCard(announcement: items[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
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
          // Bentuk identik carousel asli (horizontal, kartu lebar-12, Gap
          // antar kartu) supaya tidak bergeser saat data datang.
          child: LayoutBuilder(
            builder: (context, constraints) => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: 3,
              separatorBuilder: (_, _) => const Gap(12),
              itemBuilder: (_, i) => SizedBox(
                width: constraints.maxWidth - 12,
                child: _PinnedAnnouncementCard(
                  announcement: FeedAnnouncement(
                    id: 'skeleton-$i',
                    title: 'Judul Pengumuman',
                    body: 'Isi pengumuman singkat untuk skeleton',
                    bodyType: AnnouncementBodyType.plain,
                    expired: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error, WidgetRef ref) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FLucideIcons.alertCircle,
              size: 48,
              color: theme.colors.destructive,
            ),
            const Gap(12),
            Text(
              'Gagal memuat pengumuman',
              textAlign: TextAlign.center,
              style: theme.typography.md.copyWith(
                color: theme.colors.foreground,
              ),
            ),
            const Gap(4),
            // Detail error ringkas, bukan toString() penuh (bisa sangat
            // panjang di DioException dan overflow layar kecil).
            Text(
              _errorBrief(error),
              textAlign: TextAlign.center,
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const Gap(16),
            FButton(
              onPress: () => _refresh(ref),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(pinnedAnnouncementsProvider);
    await ref.read(pinnedAnnouncementsProvider(const {}).future);
  }

  /// Error singkat yang aman ditampilkan: tanpa stack Dio panjang.
  static String _errorBrief(Object error) {
    final raw = error.toString();
    return raw.length <= 120 ? raw : '${raw.substring(0, 120)}...';
  }
}

/// Card ringkas untuk item di carousel / single view.
/// Tap → buka AnnouncementDetailPage dengan payload beku.
class _PinnedAnnouncementCard extends StatelessWidget {
  const _PinnedAnnouncementCard({required this.announcement});

  final FeedAnnouncement announcement;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final titleStyle = theme.typography.lg.copyWith(
      fontWeight: FontWeight.w700,
      height: 1.3,
    );
    return Semantics(
      label:
          'Pengumuman: ${announcement.title}${announcement.expired ? ', sudah berakhir' : ''}',
      button: true,
      child: GestureDetector(
        onTap: () => _openDetail(context),
        // #134: tanpa FCard - konten langsung (senada detail page); border
        // halus hanya pemisah antar halaman carousel, bukan kotak penuh.
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colors.border.withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header: badge "Dipin" + expired
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FLucideIcons.pin,
                            size: 12,
                            color: theme.colors.primary,
                          ),
                          const Gap(4),
                          Text(
                            'Dipin',
                            style: theme.typography.xs.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (announcement.expired)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colors.mutedForeground.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Berakhir',
                          style: theme.typography.xs.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                  ],
                ),
                const Gap(12),
                // Title
                Text(announcement.title, style: titleStyle),
                const Gap(8),
                // Carousel/skeleton: preview ringan semua tipe (#134) -
                // jaga swipe mulus. Body penuh (md, webview loadRequest)
                // ada di halaman detail, tap kartu.
                AnnouncementBodyPreview(
                  body: announcement.body,
                  bodyType: announcement.bodyType,
                ),
                // Action button hint if exists
                if (announcement.actionUrl != null &&
                    announcement.actionUrl!.isNotEmpty) ...[
                  const Gap(12),
                  Row(
                    children: [
                      Icon(
                        FLucideIcons.externalLink,
                        size: 14,
                        color: theme.colors.mutedForeground,
                      ),
                      const Gap(6),
                      Flexible(
                        child: Text(
                          announcement.actionLabel?.isNotEmpty == true
                              ? announcement.actionLabel!
                              : 'Buka tautan',
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    context.pushNamed(
      ActivityRouter.announcementDetail.name,
      pathParameters: {'id': announcement.id},
      extra: announcement,
    );
  }
}
