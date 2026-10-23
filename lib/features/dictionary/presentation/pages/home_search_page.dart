import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/cache/cache_key.dart';
import '../../../../core/cache/cache_providers.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/use_scroll_collapse.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/theme_toggle_header_action.dart';
import '../../../activity/domain/entities/feed_activity_item.dart';
import '../../../activity/data/activity_feed_repository.dart' show FeedCategory;
import '../../../activity/presentation/providers/activity_feed_providers.dart';
import '../../../activity/presentation/providers/announcement_detail_provider.dart';
import '../../../activity/presentation/widgets/activity_feed_tile.dart';
import '../../../activity/presentation/widgets/pinned_home_banner.dart';
import '../../../contribution/contribution_router.dart';
import '../../../discussion/discussion_router.dart';
import '../../dictionary_router.dart';
import '../providers/word_of_day_providers.dart';
import '../widgets/word_of_day_card.dart';

/// Durasi semua layer animasi header (tinggi, slide, fade, gap).
const _headerAnimDuration = Duration(milliseconds: 280);

/// Jarak jari untuk menutup penuh blok header (kolom cari + 2 tile: Usul
/// kata baru, Ruang Diskusi).
const _headerCollapseDistance = 90.0;

/// Key blok header collaps (dipakai test untuk menemukan blok ini).
const _headerCollapseKey = ValueKey('header_collapse');

/// Gutter manual horizontal beranda: shell childPad dimatikan demi carousel
/// pengumuman yang full-bleed, jadi tiap seksi non-carousel memasang sendiri.
const _hPad = EdgeInsets.symmetric(horizontal: 12);

/// Tab HOME: feed lintas aktivitas publik + Kata Hari Ini.
class HomeSearchPage extends HookConsumerWidget {
  const HomeSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // #193: kategori chips dipisah dari state feed. `useState` milik halaman
    // (bukan provider) - pindah tab tidak butuh hidup lintas halaman.
    final selectedCategory = useState(FeedCategory.all);
    final state = ref.watch(activityFeedProvider(selectedCategory.value));
    final scroll = useScrollController();

    // Animation, bukan double: halaman tidak rebuild tiap frame scroll.
    // Align.heightFactor hanya mengubah ukuran slot; constraint anak tetap
    // longgar, jadi FTileGroup tidak di-layout ulang tiap frame.
    final collapse = useScrollCollapse(
      scroll,
      distance: _headerCollapseDistance,
      duration: _headerAnimDuration,
    );

    final lastDayId = useRef<String?>(null);
    final wotdResolvedOnce = useRef(false);
    final wotdAsync = ref.watch(wordOfDayProvider);
    final wotdData = wotdAsync.asData;
    if (wotdData != null || wotdAsync.hasError) {
      wotdResolvedOnce.value = true;
      if (wotdData != null) {
        lastDayId.value = wotdData.value?.word.id;
      }
    }
    final dayId = lastDayId.value;
    final feedReady = wotdResolvedOnce.value;

    useOnAppLifecycleStateChange((previous, current) {
      if (current != AppLifecycleState.resumed) return;
      if (previous == null || previous == AppLifecycleState.resumed) return;
      ref.invalidate(wordOfDayProvider);
      // Pengumuman pinned bisa expired saat app di background; invalidate
      // (data lama tetap tampil selagi reload, tanpa skeleton berkedip).
      ref.invalidate(pinnedAnnouncementsProvider);
      ref.read(activityFeedProvider(selectedCategory.value).notifier).load();
    });

    useEffect(() {
      void listener() {
        if (!scroll.hasClients) return;
        if (scroll.position.maxScrollExtent - scroll.position.pixels < 200) {
          ref
              .read(activityFeedProvider(selectedCategory.value).notifier)
              .loadMore();
        }
      }

      scroll.addListener(listener);
      return () => scroll.removeListener(listener);
    }, [scroll, selectedCategory.value]);

    return Column(
      children: [
        Padding(
          padding: _hPad,
          child: const FHeader(
            title: BrandWordmark(),
            suffixes: [ThemeToggleHeaderAction()],
          ),
        ),
        AnimatedBuilder(
          animation: collapse,
          builder: (context, child) {
            final t = collapse.value;
            return Align(
              key: _headerCollapseKey,
              alignment: Alignment.topCenter,
              heightFactor: 1 - t,
              child: ClipRect(
                child: IgnorePointer(
                  ignoring: t > 0.5,
                  child: Opacity(
                    opacity: (1 - t * 1.4).clamp(0.0, 1.0),
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
              child: Column(
                children: [_HomeSearchRow(), Gap(8), _HomeMenuTiles()],
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: collapse,
          builder: (context, _) => SizedBox(height: 4 * (1 - collapse.value)),
        ),
        Expanded(
          child: _buildBody(
            context,
            ref,
            state,
            scroll,
            dayId: dayId,
            feedReady: feedReady,
            category: selectedCategory.value,
            onCategoryChanged: (next) {
              if (next == selectedCategory.value) return;
              // Feedback taktil: ganti filter terasa instan di jari.
              HapticFeedback.selectionClick();
              // Lazy: chip kategori hanya fetch saat PERTAMA di-tap.
              // Kategori yang sudah pernah dimuat = nol request.
              ref.read(activityFeedProvider(next).notifier).ensureLoaded();
              AnalyticsService.instance.log(
                AnalyticsEvents.feedFilter,
                params: {'category': next.wire},
              );
              selectedCategory.value = next;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ActivityFeedState state,
    ScrollController scroll, {
    required String? dayId,
    required bool feedReady,
    required FeedCategory category,
    required ValueChanged<FeedCategory> onCategoryChanged,
  }) {
    // #193: skeleton penuh hanya saat kategori ini BELUM PERNAH dimuat.
    // Pindah chip ke kategori yang sudah ter-cache = render langsung (nol
    // skeleton berkedip); kategori baru menampilkan skeleton sekali.
    if (!state.hasLoaded) {
      return const _FeedSkeleton();
    }

    final items = feedReady
        ? [
            for (final item in state.items)
              if (!_isWordOfDayDuplicate(item, dayId)) item,
          ]
        : const <FeedActivityItem>[];

    final hasError = state.errorMessage != null;
    final showPlaceholder =
        !feedReady || (items.isEmpty && state.errorMessage == null);
    // Feed = CustomScrollView (bukan ListView) supaya baris chip kategori
    // bisa PIN di bawah app bar saat scroll (lihat PinnedHeaderSliver).
    final bodyCount = showPlaceholder
        ? 1
        : items.length + (state.isLoadingMore ? 1 : 0);

    return RefreshIndicator(
      onRefresh: () => _refresh(ref, category),
      child: CustomScrollView(
        controller: scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(padding: _hPad, child: WordOfDayCard()),
          ),
          const SliverToBoxAdapter(child: PinnedHomeBanner()),
          const SliverToBoxAdapter(
            child: Padding(padding: _hPad, child: _FeedHeading()),
          ),
          // Chip kategori menempel di bawah app bar saat feed di-scroll
          // (pinned) - filter tetap terjangkau tanpa scroll balik ke atas.
          SliverPersistentHeader(
            pinned: true,
            delegate: _FeedCategoryChipsHeader(
              child: _FeedCategoryChips(
                selected: category,
                onChanged: onCategoryChanged,
              ),
            ),
          ),
          if (hasError)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: FAlert(
                  variant: FAlertVariant.destructive,
                  title: Text(state.errorMessage!),
                ),
              ),
            ),
          if (!feedReady)
            const SliverToBoxAdapter(child: _FeedListSkeleton())
          else if (items.isEmpty && state.errorMessage == null)
            const SliverToBoxAdapter(child: _EmptyFeed())
          else
            SliverList.builder(
              itemCount: bodyCount,
              itemBuilder: (context, bodyIndex) {
                if (bodyIndex >= items.length) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 12, bottom: 8),
                    child: Center(child: FCircularProgress()),
                  );
                }
                return Padding(
                  padding: _hPad,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ActivityFeedTile(item: items[bodyIndex]),
                      if (bodyIndex != items.length - 1)
                        Divider(height: 1, color: context.theme.colors.border),
                    ],
                  ),
                );
              },
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  static bool _isWordOfDayDuplicate(FeedActivityItem item, String? dayId) {
    if (dayId == null || dayId.isEmpty) return false;
    if (item.kind != FeedActivityKind.word) return false;
    return item.target?.type == 'word' && item.target?.id == dayId;
  }

  Future<void> _refresh(WidgetRef ref, FeedCategory category) async {
    final store = ref.read(responseCacheStoreProvider);
    await store.delete(
      buildCacheKey(method: 'GET', path: '/api/v1/words/today'),
    );
    await store.deleteByPrefix('GET|/api/v1/activity');
    ref.invalidate(wordOfDayProvider);
    ref.invalidate(pinnedAnnouncementsProvider);
    await Future.wait([
      ref
          .read(activityFeedProvider(category).notifier)
          .load(forceRefresh: true),
      ref.read(wordOfDayProvider.future),
    ]);
  }
}

class _HomeSearchRow extends StatelessWidget {
  const _HomeSearchRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('${DictionaryRouter.list.path}?focus=1'),
            child: AbsorbPointer(
              child: FTextField(
                size: .sm,
                readOnly: true,
                hint: 'Cari kata Sambas...',
                prefixBuilder: (context, style, variants) =>
                    FTextField.prefixIconBuilder(
                      context,
                      style,
                      variants,
                      const Icon(FLucideIcons.search),
                    ),
              ),
            ),
          ),
        ),
        const Gap(8),
        FButton(
          size: .sm,
          variant: FButtonVariant.outline,
          onPress: () => context.push(
            DictionaryRouter.letter.path.replaceFirst(':letter', 'a'),
          ),
          child: const Text('A-Z'),
        ),
      ],
    );
  }
}

class _HomeMenuTiles extends StatelessWidget {
  const _HomeMenuTiles();

  @override
  Widget build(BuildContext context) {
    // #193: tile "Dicari warga" dipindah ke chips kategori feed (kini bisa
    // diakses langsung dari beranda); area CTA hanya menyisakan "Usul kata
    // baru" - blok lebih pendek, jarak collapse disesuaikan.
    return FTileGroup(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        FTile(
          prefix: const Icon(FLucideIcons.plus, size: 18),
          title: const Text('Usul kata baru'),
          suffix: const Icon(FLucideIcons.chevronRight, size: 16),
          onPress: () {
            AnalyticsService.instance.log(
              AnalyticsEvents.contributeStart,
              params: {'from': 'home'},
            );
            context.push(ContributionRouter.contribute.path);
          },
        ),
        FTile(
          prefix: const Icon(FLucideIcons.languages, size: 18),
          title: const Text('Ruang Diskusi'),
          subtitle: const Text(
            'Tanya arti atau bahas kata Sambas bareng warga',
          ),
          suffix: const Icon(FLucideIcons.chevronRight, size: 16),
          onPress: () => context.push(DiscussionRouter.feed.path),
        ),
      ],
    );
  }
}

/// #193: chips kategori feed beranda. Full-bleed (tanpa _hPad) + scroll
/// horizontal: chip terakhir tidak terpotong gutter, tepi kiri rata layar.
class _FeedCategoryChips extends StatelessWidget {
  const _FeedCategoryChips({required this.selected, this.onChanged});

  final FeedCategory selected;

  /// Null = mode statis (dipakai skeleton: render tanpa aksi).
  final ValueChanged<FeedCategory>? onChanged;

  /// Tinggi baris chip (dipakai delegate pinned).
  static const double height = 36;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        // Key khusus test: ada ListView lain di halaman (feed vertical).
        key: const ValueKey('feed_category_chips'),
        scrollDirection: Axis.horizontal,
        // padding asimetris: kiri/kanan 12 sejajar gutter konten, tapi chip
        // bisa scroll melewati gutter (clamping ScrollView, bukan viewport
        // terpotong).
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 2),
        itemCount: FeedCategory.values.length,
        separatorBuilder: (_, _) => const Gap(6),
        itemBuilder: (context, i) {
          final category = FeedCategory.values[i];
          final isSelected = category == selected;
          return FButton(
            size: .xs,
            variant: isSelected
                ? FButtonVariant.primary
                : FButtonVariant.outline,
            onPress: onChanged == null ? null : () => onChanged!(category),
            child: Text(category.label),
          );
        },
      ),
    );
  }
}

/// Delegate pinned untuk baris chip kategori: baris ini menempel di bawah
/// app bar saat feed di-scroll, jadi filter selalu terjangkau.
///
/// Latar opaque (warna tema) wajib: tanpa itu, item feed yang lewat di
/// belakang baris chip akan tembus terlihat dan chip jadi susah dibaca.
class _FeedCategoryChipsHeader extends SliverPersistentHeaderDelegate {
  _FeedCategoryChipsHeader({required this.child});

  final Widget child;

  @override
  double get minExtent => _FeedCategoryChips.height;

  @override
  double get maxExtent => _FeedCategoryChips.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        // Garis bawah tipis sebagai pemisah dari feed yang lewat di bawah.
        border: Border(
          bottom: BorderSide(color: theme.colors.border, width: 0.5),
        ),
        // Saat menempel dengan konten lewat di belakang (pinned aktif),
        // bayangan halus menegaskan bar terpisah dari feed (pola app bar).
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: theme.colors.foreground.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(_FeedCategoryChipsHeader oldDelegate) =>
      oldDelegate.child != child;
}

class _FeedHeading extends StatelessWidget {
  const _FeedHeading();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: Text(
        'Aktivitas terbaru',
        style: theme.typography.body.sm.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colors.foreground,
        ),
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            FLucideIcons.bookOpen,
            size: 36,
            color: theme.colors.mutedForeground,
          ),
          const Gap(8),
          Text(
            'Belum ada aktivitas.',
            textAlign: TextAlign.center,
            style: theme.typography.body.md.copyWith(
              color: theme.colors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedListSkeleton extends StatelessWidget {
  const _FeedListSkeleton();

  @override
  Widget build(BuildContext context) {
    final materialBrightness = Theme.of(context).brightness;
    final isDark = materialBrightness == Brightness.dark;
    final muted = context.theme.colors.muted;
    PaintingEffect shimmerResolver(Brightness brightness) => ShimmerEffect(
      baseColor: isDark
          ? muted.withValues(alpha: 0.35)
          : const Color(0xFFE7E7EA),
      highlightColor: isDark
          ? muted.withValues(alpha: 0.55)
          : const Color(0xFFF4F4F5),
      duration: const Duration(milliseconds: 1500),
    );

    final placeholder = FeedActivityItem(
      id: 'skeleton',
      kind: FeedActivityKind.comment,
      createdAt: DateTime.now().toIso8601String(),
      body: 'aktivitas singkat satu baris',
      actor: const FeedActivityActor(
        username: 'warga',
        displayName: 'Warga Sambas',
      ),
      subtitle: 'lading',
    );

    return SkeletonizerConfig(
      data: SkeletonizerConfigData(effectResolver: shimmerResolver),
      child: IgnorePointer(
        child: Skeletonizer(
          enabled: true,
          child: Padding(
            padding: _hPad,
            child: Column(
              children: [
                for (var i = 0; i < 4; i++) ...[
                  ActivityFeedTile(item: placeholder),
                  if (i != 3)
                    Divider(height: 1, color: context.theme.colors.border),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 2, 0, 16),
      children: const [
        Padding(padding: _hPad, child: WordOfDayCard()),
        PinnedHomeBanner(),
        Padding(padding: _hPad, child: _FeedHeading()),
        _FeedCategoryChips(selected: FeedCategory.all, onChanged: null),
        _FeedListSkeleton(),
      ],
    );
  }
}
