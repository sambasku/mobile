import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/cache/cache_key.dart';
import '../../../../core/cache/cache_providers.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../core/widgets/pending_review_badge_icon.dart';
import '../../../../core/widgets/theme_toggle_header_action.dart';
import '../../../../core/widgets/verified_badge_icon.dart';
import '../../dictionary_router.dart';
import '../../domain/entities/word_summary.dart';
import '../models/latest_words_state.dart';
import '../providers/latest_words_providers.dart';
import '../providers/word_of_day_providers.dart';
import '../widgets/word_of_day_card.dart';
import '../../../translation_help/presentation/widgets/translation_help_home_banner.dart';

/// Tab HOME: feed kata yang sudah disetujui. Pencarian pindah ke
/// Daftar Kata A-Z (kolom cari hanya pintu masuk, langsung fokus).
class HomeSearchPage extends HookConsumerWidget {
  const HomeSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(latestWordsProvider);
    final notifier = ref.read(latestWordsProvider.notifier);
    final scroll = useScrollController();

    // Stabilkan filter WOTD: .asData hilang saat invalidate/loading ulang.
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

    useEffect(() {
      void listener() {
        if (!scroll.hasClients) return;
        if (scroll.position.maxScrollExtent - scroll.position.pixels < 200) {
          notifier.loadMore();
        }
      }

      scroll.addListener(listener);
      return () => scroll.removeListener(listener);
    }, [scroll]);

    // Halaman pertama yang tidak memenuhi layar tidak memicu scroll.
    useEffect(
      () {
        if (!feedReady ||
            state.isLoading ||
            state.isLoadingMore ||
            !state.hasMore ||
            state.errorMessage != null) {
          return null;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!scroll.hasClients) return;
          if (scroll.position.maxScrollExtent - scroll.position.pixels < 200) {
            notifier.loadMore();
          }
        });
        return null;
      },
      [
        feedReady,
        state.items.length,
        state.hasMore,
        state.isLoading,
        state.isLoadingMore,
        state.errorMessage,
        dayId,
      ],
    );

    useOnAppLifecycleStateChange((previous, current) {
      if (current != AppLifecycleState.resumed) return;
      if (previous == null || previous == AppLifecycleState.resumed) return;
      ref.invalidate(wordOfDayProvider);
      ref.read(latestWordsProvider.notifier).load();
    });

    return Column(
      children: [
        const FHeader(
          title: Text('SambasKu'),
          suffixes: [ThemeToggleHeaderAction()],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
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
    LatestWordsState state,
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
              if (item.id != dayId) item,
          ]
        : const <WordSummary>[];

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: ListView(
        controller: scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 2, 0, 16),
        children: [
          const WordOfDayCard(),
          const TranslationHelpHomeBanner(),
          const _FeedHeading(),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FAlert(
                variant: FAlertVariant.destructive,
                title: Text(state.errorMessage!),
              ),
            ),
          if (!feedReady)
            const _FeedListSkeleton()
          else if (items.isEmpty && state.errorMessage == null)
            const _EmptyFeed()
          else
            for (var i = 0; i < items.length; i++) ...[
              _FeedCard(item: items[i]),
              if (i != items.length - 1)
                Divider(height: 1, color: context.theme.colors.border),
            ],
          if (state.isLoadingMore) const _LoadingMoreFooter(),
        ],
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    final store = ref.read(responseCacheStoreProvider);
    await store.delete(
      buildCacheKey(method: 'GET', path: '/api/v1/words/today'),
    );
    await store.deleteByPrefix('GET|/api/v1/words/latest');
    ref.invalidate(wordOfDayProvider);
    await Future.wait([
      ref.read(latestWordsProvider.notifier).load(forceRefresh: true),
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

class _FeedCard extends StatelessWidget {
  const _FeedCard({required this.item});

  final WordSummary item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final sense = item.sense?.trim() ?? '';
    final when = formatRelative(item.approvedAt);
    final meta = [item.wordTypeLabel, if (when.isNotEmpty) when].join(' · ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          context.push(
            DictionaryRouter.detail.path.replaceFirst(':id', item.id),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.lemma,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: theme.colors.foreground,
                      ),
                    ),
                  ),
                  if (item.isVerified) ...[
                    const Gap(8),
                    const VerifiedBadgeIcon(size: 14),
                  ] else ...[
                    const Gap(8),
                    const PendingReviewBadgeIcon(size: 14),
                  ],
                ],
              ),
              if (sense.isNotEmpty) ...[
                const Gap(1),
                Text(
                  sense,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.xs.copyWith(
                    height: 1.2,
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ],
              const Gap(1),
              Text(
                meta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.xs.copyWith(
                  height: 1.2,
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
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

    final placeholder = WordSummary(
      id: 'skeleton',
      lemma: 'kata Sambas',
      languageCode: 'sbs',
      wordType: 'word',
      status: 'published',
      isVerified: true,
      sense: 'arti singkat satu baris',
      approvedAt: DateTime.now(),
    );

    return SkeletonizerConfig(
      data: SkeletonizerConfigData(effect: shimmer),
      child: IgnorePointer(
        child: Skeletonizer(
          enabled: true,
          child: Column(
            children: [
              for (var i = 0; i < 4; i++) ...[
                _FeedCard(item: placeholder),
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
        _FeedHeading(),
        _FeedListSkeleton(),
      ],
    );
  }
}

class _LoadingMoreFooter extends StatelessWidget {
  const _LoadingMoreFooter();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FCircularProgress(size: .xs),
            const Gap(8),
            Text(
              'Memuat...',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
