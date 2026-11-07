import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';
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
import '../../../../shared/widgets/back_to_top_button.dart';
import '../../../activity/domain/entities/feed_activity_item.dart';
import '../../../activity/data/activity_feed_repository.dart' show FeedCategory;
import '../../../activity/presentation/providers/activity_feed_providers.dart';
import '../../../activity/presentation/activity_labels.dart';
import '../../../activity/presentation/providers/announcement_detail_provider.dart';
import '../../../activity/presentation/widgets/activity_feed_tile.dart';
import '../../../activity/presentation/widgets/pinned_home_banner.dart';
import '../../../contribution/contribution_router.dart';
import '../../../discussion/discussion_router.dart';
import '../../../encyclopedia/encyclopedia_router.dart';
import '../../../entertainment/entertainment_router.dart';
import '../../dictionary_router.dart';
import '../providers/word_of_day_providers.dart';
import '../widgets/word_of_day_card.dart';

/// Durasi semua layer animasi header (tinggi, slide, fade, gap).
const _headerAnimDuration = Duration(milliseconds: 280);

/// Jarak jari untuk menutup penuh blok header (tile ikon 1:1 kecil + label
/// di bawah, scroll horizontal).
const _headerCollapseDistance = 78.0;

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
          child: const RepaintBoundary(
            child: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: _HomeActionChips(),
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
    // #193: chip kategori SELALU dirender (bukan diganti skeleton). Dulu
    // kategori yang belum pernah dimuat mengganti seluruh scroll view dengan
    // skeleton yang chipnya hard-code "Semua" + disabled -> saat user pilih
    // chip lain, pilihan terlihat "balik ke Semua" dan chips tak bisa
    // di-tap (persis seperti error). Kini hanya BODY yang skeleton.
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

    // #201: Stack + tombol kembali ke atas (muncul setelah scroll).
    return ScrollWithBackToTop(
      controller: scroll,
      child: RefreshIndicator(
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
            if (!feedReady || !state.hasLoaded)
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
                          Divider(
                            height: 1,
                            color: context.theme.colors.border,
                          ),
                      ],
                    ),
                  );
                },
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
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

/// Satu baris tile aksi beranda (Cari / A-Z / Usulkan / Diskusi / Pantun /
/// Ensiklopedia). Scroll horizontal; kotak ikon 1:1; label di bawahnya.
class _HomeActionChips extends StatelessWidget {
  const _HomeActionChips();

  /// Lebar kotak ikon (= tinggi, rasio 1:1). Sama dengan lebar kolom
  /// supaya antar-kotak tidak ada "udara" dari padding label.
  static const double _tileSize = 48;

  /// Slot label di bawah kotak (gap ikon→teks + 2 baris kecil).
  static const double _labelSlot = 28;

  /// Tinggi total baris (kotak + gap + label).
  static const double height = _tileSize + 6 + _labelSlot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <_HomeActionChip>[
      _HomeActionChip(
        icon: FLucideIcons.search,
        label: l10n.dictSearchChip,
        semanticsLabel: l10n.dictSearchHint,
        onPress: () => context.push('${DictionaryRouter.list.path}?focus=1'),
      ),
      _HomeActionChip(
        icon: FLucideIcons.aLargeSmall,
        label: l10n.dictAZ,
        onPress: () => context.push(
          DictionaryRouter.letter.path.replaceFirst(':letter', 'a'),
        ),
      ),
      _HomeActionChip(
        icon: FLucideIcons.plus,
        label: l10n.dictProposeChip,
        semanticsLabel: l10n.dictProposeWord,
        onPress: () {
          AnalyticsService.instance.log(
            AnalyticsEvents.contributeStart,
            params: {'from': 'home'},
          );
          context.push(ContributionRouter.contribute.path);
        },
      ),
      _HomeActionChip(
        icon: FLucideIcons.messagesSquare,
        label: l10n.dictDiscussionChip,
        semanticsLabel: l10n.dictDiscussionSubtitle,
        onPress: () => context.push(DiscussionRouter.feed.path),
      ),
      _HomeActionChip(
        icon: FLucideIcons.feather,
        label: l10n.pantunTitle,
        onPress: () => context.push(EntertainmentRouter.pantunHub.path),
      ),
      _HomeActionChip(
        icon: FLucideIcons.bookOpen,
        label: l10n.encyclopediaChip,
        semanticsLabel: l10n.encyclopediaTitle,
        onPress: () => context.push(EncyclopediaRouter.list.path),
      ),
    ];

    return SizedBox(
      height: height,
      child: ListView.separated(
        key: const ValueKey('home_action_chips'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
        itemCount: items.length,
        separatorBuilder: (_, _) => const Gap(8),
        itemBuilder: (context, i) => _HomeActionTile(item: items[i]),
      ),
    );
  }
}

class _HomeActionChip {
  const _HomeActionChip({
    required this.icon,
    required this.label,
    required this.onPress,
    this.semanticsLabel,
  });

  final IconData icon;
  final String label;
  final String? semanticsLabel;
  final VoidCallback onPress;
}

class _HomeActionTile extends StatelessWidget {
  const _HomeActionTile({required this.item});

  final _HomeActionChip item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final size = _HomeActionChips._tileSize;
    return Semantics(
      button: true,
      label: item.semanticsLabel ?? item.label,
      child: FTappable(
        onPress: item.onPress,
        // Lebar = ukuran kotak: jarak antar kotak = separator saja (4px).
        child: SizedBox(
          width: size,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colors.secondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.colors.border),
                  ),
                  child: Center(
                    child: Icon(
                      item.icon,
                      size: 18,
                      color: theme.colors.foreground,
                    ),
                  ),
                ),
              ),
              const Gap(6),
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.body.xs.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                  color: theme.colors.foreground,
                ),
              ),
            ],
          ),
        ),
      ),
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
            child: Text(
              feedCategoryLabel(AppLocalizations.of(context), category),
            ),
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

  /// Jarak napas antara baris chip dan konten feed di bawahnya; ikut tinggi
  /// delegate supaya saat pinned konten tidak menempel ke chip.
  static const double _bottomGap = 8;

  @override
  double get minExtent => _FeedCategoryChips.height + _bottomGap;

  @override
  double get maxExtent => _FeedCategoryChips.height + _bottomGap;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = context.theme;
    // Latar menutup chip + gap (opaque) supaya item feed tidak tembus saat
    // lewat di belakang; garis pemisah tepat di bawah chip.
    return ColoredBox(
      color: theme.colors.background,
      child: DecoratedBox(
        decoration: BoxDecoration(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.colors.border, width: 0.5),
                ),
              ),
              child: child,
            ),
            const SizedBox(height: _bottomGap),
          ],
        ),
      ),
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
        AppLocalizations.of(context).dictRecentActivity,
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
            AppLocalizations.of(context).dictNoActivity,
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
      body: AppLocalizations.of(context).dictActivitySkeletonLine,
      actor: FeedActivityActor(
        username: 'warga',
        displayName: AppLocalizations.of(context).dictCitizenFallback,
      ),
      subtitle: AppLocalizations.of(context).dictActivitySkeletonSubtitle,
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
