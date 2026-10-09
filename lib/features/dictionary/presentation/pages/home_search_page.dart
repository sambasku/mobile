import 'package:flutter/material.dart';
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
import '../../../activity/presentation/providers/activity_feed_providers.dart';
import '../../../activity/presentation/providers/announcement_detail_provider.dart';
import '../../../activity/presentation/widgets/activity_feed_tile.dart';
import '../../../activity/presentation/widgets/pinned_home_banner.dart';
import '../../../contribution/contribution_router.dart';
import '../../../discussion/presentation/widgets/discussion_home_banner.dart';
import '../../dictionary_router.dart';
import '../providers/word_of_day_providers.dart';
import '../widgets/word_of_day_card.dart';

/// Durasi semua layer animasi header (tinggi, slide, fade, gap).
const _headerAnimDuration = Duration(milliseconds: 280);

/// Jarak scroll untuk membuka/menutup penuh blok header. Makin kecil =
/// makin responsif.
const _headerCollapseDistance = 90.0;

/// Key blok header collaps (dipakai test untuk menemukan blok ini).
const _headerCollapseKey = ValueKey('header_collapse');

/// Tab HOME: feed lintas aktivitas publik + Kata Hari Ini.
class HomeSearchPage extends HookConsumerWidget {
  const HomeSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activityFeedProvider);
    final scroll = useScrollController();

    // Animation, bukan double: halaman tidak rebuild tiap frame scroll.
    // Yang rebuild hanya blok collaps di bawah (AnimatedBuilder).
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
      ref.read(activityFeedProvider.notifier).load();
    });

    useEffect(() {
      void listener() {
        if (!scroll.hasClients) return;
        if (scroll.position.maxScrollExtent - scroll.position.pixels < 200) {
          ref.read(activityFeedProvider.notifier).loadMore();
        }
      }

      scroll.addListener(listener);
      return () => scroll.removeListener(listener);
    }, [scroll]);

    return Column(
      children: [
        const FHeader(
          title: BrandWordmark(),
          suffixes: [ThemeToggleHeaderAction()],
        ),
        // Search + tombol usul: satu blok collaps scroll-proportional.
        // Transform dihitung dari collapse.value (0 terbuka, 1 tertutup):
        // tinggi menyusut, fade. ClipRect menjaga isi tidak bocor saat
        // tinggi < tinggi konten. IgnorePointer menutup tap saat blok
        // hampir tertutup supaya tidak menangkap gesture feed.
        // Rebuild dibatasi ke blok ini saja (AnimatedBuilder) agar scroll
        // feed tidak rebuild row per frame.
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
          // child di-cache: tidak rebuild saat animasi jalan.
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push(
                          '${DictionaryRouter.list.path}?focus=1',
                        ),
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
                        DictionaryRouter.letter.path.replaceFirst(
                          ':letter',
                          'a',
                        ),
                      ),
                      child: const Text('A-Z'),
                    ),
                  ],
                ),
                const Gap(8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FButton(
                    size: .sm,
                    variant: FButtonVariant.outline,
                    prefix: const Icon(FLucideIcons.plus),
                    onPress: () {
                      AnalyticsService.instance.log(
                        AnalyticsEvents.contributeStart,
                        params: {'from': 'home'},
                      );
                      context.push(ContributionRouter.contribute.path);
                    },
                    child: const Text('Usul kata baru'),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Jarak blok collaps ke feed; ikut menyusut saat blok hilang.
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
  }) {
    if (state.isLoading && state.items.isEmpty) {
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
    // 0 Kata Hari Ini, 1 spanduk diskusi, 2 banner pinned (shrink jika
    // kosong), 3 judul, lalu opsional peringatan.
    final headerCount = 4 + (hasError ? 1 : 0);
    final bodyCount = showPlaceholder
        ? 1
        : items.length + (state.isLoadingMore ? 1 : 0);

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: ListView.builder(
        controller: scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 2, 0, 16),
        itemCount: headerCount + bodyCount,
        itemBuilder: (context, index) {
          if (index == 0) return const WordOfDayCard();
          if (index == 1) return const DiscussionHomeBanner();
          if (index == 2) return const PinnedHomeBanner();
          if (index == 3) return const _FeedHeading();
          var cursor = 4;
          if (hasError) {
            if (index == cursor) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FAlert(
                  variant: FAlertVariant.destructive,
                  title: Text(state.errorMessage!),
                ),
              );
            }
            cursor++;
          }
          final bodyIndex = index - cursor;
          if (!feedReady) return const _FeedListSkeleton();
          if (items.isEmpty && state.errorMessage == null) {
            return const _EmptyFeed();
          }
          if (bodyIndex >= items.length) {
            return const Padding(
              padding: EdgeInsets.only(top: 12, bottom: 8),
              child: Center(child: FCircularProgress()),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ActivityFeedTile(item: items[bodyIndex]),
              if (bodyIndex != items.length - 1)
                Divider(height: 1, color: context.theme.colors.border),
            ],
          );
        },
      ),
    );
  }

  static bool _isWordOfDayDuplicate(FeedActivityItem item, String? dayId) {
    if (dayId == null || dayId.isEmpty) return false;
    if (item.kind != FeedActivityKind.word) return false;
    return item.target?.type == 'word' && item.target?.id == dayId;
  }

  Future<void> _refresh(WidgetRef ref) async {
    final store = ref.read(responseCacheStoreProvider);
    await store.delete(
      buildCacheKey(method: 'GET', path: '/api/v1/words/today'),
    );
    await store.deleteByPrefix('GET|/api/v1/activity');
    ref.invalidate(wordOfDayProvider);
    ref.invalidate(pinnedAnnouncementsProvider);
    await Future.wait([
      ref.read(activityFeedProvider.notifier).load(forceRefresh: true),
      ref.read(wordOfDayProvider.future),
    ]);
  }
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
        style: theme.typography.sm.copyWith(
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
            style: theme.typography.md.copyWith(color: theme.colors.foreground),
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
    final shimmer = ShimmerEffect(
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
      data: SkeletonizerConfigData(effect: shimmer),
      child: IgnorePointer(
        child: Skeletonizer(
          enabled: true,
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
        WordOfDayCard(),
        DiscussionHomeBanner(),
        PinnedHomeBanner(),
        _FeedHeading(),
        _FeedListSkeleton(),
      ],
    );
  }
}
