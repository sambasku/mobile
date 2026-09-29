import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/widgets/pending_review_badge_icon.dart';
import '../../../../core/widgets/verified_badge_icon.dart';
import '../../dictionary_router.dart';
import '../../domain/entities/word_summary.dart';
import '../models/letter_words_state.dart';
import '../providers/letter_words_providers.dart';
import '../widgets/alphabet_letter_strip.dart';

/// Direktori kata per huruf - setara web `/huruf/:letter`.
class LetterWordsPage extends HookConsumerWidget {
  const LetterWordsPage({super.key, required this.letter});

  /// Satu huruf a-z (sudah dinormalisasi di router).
  final String letter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(letterWordsProvider(letter));
    final notifier = ref.read(letterWordsProvider(letter).notifier);
    final scroll = useScrollController();
    final theme = context.theme;
    final display = letter.toUpperCase();

    useEffect(() {
      void listener() {
        if (!scroll.hasClients) return;
        if (scroll.position.maxScrollExtent - scroll.position.pixels < 200) {
          notifier.loadMore();
        }
      }

      scroll.addListener(listener);
      return () => scroll.removeListener(listener);
    }, [scroll, letter]);

    useEffect(
      () {
        if (state.isLoading ||
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
        state.items.length,
        state.hasMore,
        state.isLoading,
        state.isLoadingMore,
        state.errorMessage,
        letter,
      ],
    );

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text('Huruf $display'),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop() ? context.pop() : context.go('/'),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Kata yang dimulai dengan huruf $display.',
            textAlign: TextAlign.center,
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
              height: 1.4,
            ),
          ),
          const Gap(10),
          AlphabetLetterStrip(activeLetter: letter, replaceOnSelect: true),
          const Gap(8),
          Expanded(child: _buildBody(context, ref, theme, state, scroll)),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    FThemeData theme,
    LetterWordsState state,
    ScrollController scroll,
  ) {
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final skeletonPerPage = (viewportHeight ~/ 80) + 2;

    if (state.isLoading && state.items.isEmpty) {
      return _ListSkeleton(itemCount: skeletonPerPage);
    }

    if (state.errorMessage != null && state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FLucideIcons.circleAlert,
                size: 40,
                color: theme.colors.mutedForeground,
              ),
              const Gap(8),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: theme.typography.md.copyWith(
                  color: theme.colors.foreground,
                ),
              ),
              const Gap(12),
              FButton(
                onPress: () =>
                    ref.read(letterWordsProvider(letter).notifier).load(),
                variant: FButtonVariant.outline,
                prefix: const Icon(FLucideIcons.rotateCcw),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FLucideIcons.list,
                size: 40,
                color: theme.colors.mutedForeground,
              ),
              const Gap(8),
              Text(
                'Belum ada kata untuk huruf ${letter.toUpperCase()}.',
                textAlign: TextAlign.center,
                style: theme.typography.md.copyWith(
                  color: theme.colors.foreground,
                ),
              ),
              const Gap(12),
              FButton(
                onPress: () => context.push(DictionaryRouter.list.path),
                variant: FButtonVariant.outline,
                child: const Text('Lihat semua kata'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(letterWordsProvider(letter).notifier).load(),
      child: ListView(
        controller: scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
        children: [
          FTileGroup(
            physics: const NeverScrollableScrollPhysics(),
            children: [for (final item in state.items) _WordTile(item: item)],
          ),
          if (state.isLoadingMore) const _LoadingMoreFooter(),
        ],
      ),
    );
  }
}

class _WordTile extends StatelessWidget with FTileMixin {
  const _WordTile({required this.item});

  final WordSummary item;

  @override
  Widget build(BuildContext context) {
    final gloss = item.sense?.trim();
    final subtitle = (gloss != null && gloss.isNotEmpty)
        ? gloss
        : (item.wordType != 'word' ? item.wordTypeLabel : null);

    return FTile(
      title: Text(item.lemma),
      subtitle: subtitle != null ? Text(subtitle) : null,
      suffix: item.isVerified
          ? const VerifiedBadgeIcon()
          : const PendingReviewBadgeIcon(),
      onPress: () {
        context.push(DictionaryRouter.detail.path.replaceFirst(':id', item.id));
      },
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton({required this.itemCount});

  final int itemCount;

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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
            children: [
              FTileGroup(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (var i = 0; i < itemCount; i++) const _SkeletonTile(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonTile extends StatelessWidget with FTileMixin {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    return FTile(
      title: const Text('kata Sambas contoh'),
      suffix: Icon(
        FLucideIcons.badgeCheck,
        size: 18,
        color: context.theme.colors.mutedForeground,
      ),
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
