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
/// - >1 item → PageView carousel dengan indikator
class PinnedAnnouncementsPage extends ConsumerStatefulWidget {
  const PinnedAnnouncementsPage({super.key});

  @override
  ConsumerState<PinnedAnnouncementsPage> createState() =>
      _PinnedAnnouncementsPageState();
}

class _PinnedAnnouncementsPageState
    extends ConsumerState<PinnedAnnouncementsPage> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // #134: viewportFraction di PageController (Flutter 3.44+: tak ada
    // lagi param di PageView.builder). < 1 + padding horizontal = kartu
    // terlihat terpisah, sebelumnya berdempet tanpa celah.
    _pageController = PageController(viewportFraction: 0.86);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    if (!mounted) return;
    setState(() => _currentPage = page);
  }

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
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final announcement = items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  // Kartu aktif render penuh, neighbor preview ringan
                  // (#134: WebView/platform view per halaman = jank swipe).
                  child: _PinnedAnnouncementCard(
                    announcement: announcement,
                    isCarousel: true,
                    isPreview: index != _currentPage,
                  ),
                );
              },
            ),
          ),
          // Page indicator
          _buildPageIndicator(theme, items.length),
          const Gap(16),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(FThemeData theme, int count) {
    return Semantics(
      label: 'Indikator halaman carousel, ${_currentPage + 1} dari $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final isActive = index == _currentPage;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colors.primary
                    : theme.colors.mutedForeground.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
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
          child: ListView(
            // #134: tanpa horizontal - childPad FScaffold sudah 12.
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              for (var i = 0; i < 3; i++) ...[
                _PinnedAnnouncementCard(
                  announcement: FeedAnnouncement(
                    id: 'skeleton-$i',
                    title: 'Judul Pengumuman',
                    body: 'Isi pengumuman singkat untuk skeleton',
                    bodyType: AnnouncementBodyType.plain,
                    expired: false,
                  ),
                  isCarousel: true,
                ),
                if (i != 2) const Gap(16),
              ],
            ],
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
  const _PinnedAnnouncementCard({
    required this.announcement,
    this.isCarousel = false,
    this.isPreview = false,
  });

  final FeedAnnouncement announcement;
  final bool isCarousel;

  /// true = kartu neighbor carousel: preview teks ringan (#134). Kartu
  /// aktif render body penuh (md) - WebView tetap hanya di detail.
  final bool isPreview;

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
      // GestureDetector, bukan InkWell: FCard.raw tanpa ancestor Material
      // (aturan Forui no-material-widgets).
      child: GestureDetector(
        onTap: () => _openDetail(context),
        child: FCard.raw(
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
                // Neighbor carousel: preview ringan. Kartu aktif: body
                // penuh SEMUA tipe - webview = loadRequest URL dari body
                // (call HTML sesuai URL), WebView cuma 1 per halaman
                // aktif sehingga swipe tetap lancar (#134).
                if (isPreview)
                  AnnouncementBodyPreview(
                    body: announcement.body,
                    bodyType: announcement.bodyType,
                  )
                else
                  AnnouncementBody(
                    body: announcement.body,
                    bodyType: announcement.bodyType,
                    maxHeight: 280,
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
