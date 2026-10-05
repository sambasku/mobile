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
import '../models/word_list_state.dart';
import '../providers/search_history_provider.dart';
import '../providers/word_list_providers.dart';
import '../../../../shared/widgets/exclude_semantics_on_exit.dart';

/// Daftar kata. q kosong di mode Sambas = A-Z (`GET /words`).
/// q terisi, atau mode Indonesia, memakai `GET /words/search` supaya
/// hasil kosong tercatat sebagai search-miss dan bisa diusulkan.
class WordListPage extends HookConsumerWidget {
  const WordListPage({super.key, this.autofocus = false});

  /// true saat dibuka dari kolom cari beranda (`?focus=1`).
  final bool autofocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wordListProvider);
    final notifier = ref.read(wordListProvider.notifier);
    final controller = useTextEditingController(text: state.q);
    final focusNode = useFocusNode();
    final scroll = useScrollController();
    final history = ref.watch(searchHistoryControllerProvider);
    final showHistory =
        state.q.trim().isEmpty &&
        !state.isLoading &&
        state.items.isEmpty &&
        history.isNotEmpty;

    useEffect(() {
      if (!autofocus) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        focusNode.requestFocus();
      });
      return null;
    }, [autofocus]);

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

    // Halaman pertama yang lebih pendek dari layar tidak memicu scroll,
    // jadi sisa halaman tidak pernah dimuat.
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
      ],
    );

    final theme = context.theme;

    return ExcludeSemanticsOnExit(
      child: FScaffold(
        childPad: true,
        header: FHeader.nested(
          title: const Text('Daftar Kata A-Z'),
          prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 6),
              child: Row(
                children: [
                  Expanded(
                    child: FButton(
                      size: .sm,
                      variant: state.searchIn == 'lemma'
                          ? FButtonVariant.primary
                          : FButtonVariant.outline,
                      onPress: () => notifier.onSearchInChanged('lemma'),
                      child: const Text('Sambas'),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: FButton(
                      size: .sm,
                      variant: state.searchIn == 'translation'
                          ? FButtonVariant.primary
                          : FButtonVariant.outline,
                      onPress: () => notifier.onSearchInChanged('translation'),
                      child: const Text('Indonesia'),
                    ),
                  ),
                ],
              ),
            ),
            FTextField(
              control: FTextFieldControl.managed(
                controller: controller,
                onChange: (value) => notifier.onQueryChanged(value.text),
              ),
              focusNode: focusNode,
              hint: state.searchIn == 'translation'
                  ? 'Cari kata Indonesia...'
                  : 'Cari atau saring kata Sambas...',
              clearable: (value) => value.text.isNotEmpty,
              prefixBuilder: (context, style, variants) =>
                  FTextField.prefixIconBuilder(
                    context,
                    style,
                    variants,
                    const Icon(FLucideIcons.search),
                  ),
            ),
            const Gap(10),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                child: FAlert(
                  variant: FAlertVariant.destructive,
                  title: Text(state.errorMessage!),
                ),
              ),
            if (showHistory)
              _SearchHistorySection(
                history: history,
                onPick: (q) {
                  controller.text = q;
                  notifier.onQueryChanged(q);
                },
                onRemove: (q) => ref
                    .read(searchHistoryControllerProvider.notifier)
                    .remove(q),
                onClear: () =>
                    ref.read(searchHistoryControllerProvider.notifier).clear(),
              )
            else
              Expanded(child: _buildBody(context, ref, theme, state, scroll)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    FThemeData theme,
    WordListState state,
    ScrollController scroll,
  ) {
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final skeletonPerPage = (viewportHeight ~/ 80) + 2;

    if (state.isLoading) {
      return _ListSkeleton(itemCount: skeletonPerPage);
    }

    if (state.items.isEmpty) {
      final query = state.q.trim();
      final askIndonesia = state.searchIn == 'translation' && query.isEmpty;
      return Center(
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                askIndonesia ? FLucideIcons.search : FLucideIcons.list,
                size: 40,
                color: theme.colors.mutedForeground,
              ),
              const Gap(8),
              Text(
                askIndonesia
                    ? 'Ketik kata Indonesia untuk mencari terjemahannya di Sambas.'
                    : query.isEmpty
                    ? 'Belum ada kata terbit.'
                    : 'Tidak ada kata untuk "$query"',
                textAlign: TextAlign.center,
                style: theme.typography.md.copyWith(
                  color: theme.colors.foreground,
                ),
              ),
              if (query.isNotEmpty) ...[
                const Gap(4),
                Text(
                  'Belum ada di kamus. Usulkan supaya bisa dicari orang lain.',
                  textAlign: TextAlign.center,
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                const Gap(12),
                FButton(
                  onPress: () {
                    final params = Uri(
                      queryParameters: {
                        'lemma': query,
                        'search_in': state.searchIn,
                      },
                    ).query;
                    context.push('/contribute?$params');
                  },
                  child: const Text('Usul kata ini'),
                ),
              ],
              if (!askIndonesia) ...[
                const Gap(8),
                FButton(
                  onPress: () => ref.read(wordListProvider.notifier).load(),
                  variant: FButtonVariant.outline,
                  prefix: const Icon(FLucideIcons.rotateCcw),
                  child: const Text('Coba lagi'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(wordListProvider.notifier).load(),
              child: NotificationListener<UserScrollNotification>(
                onNotification: (_) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  return false;
                },
                child: FTileGroup.builder(
                  scrollController: scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  count: state.items.length,
                  tileBuilder: (context, index) => _WordTile(
                    item: state.items[index],
                    searchIn: state.searchIn,
                  ),
                ),
              ),
            ),
          ),
          if (state.isLoadingMore) const _LoadingMoreFooter(),
        ],
      ),
    );
  }
}

class _WordTile extends StatelessWidget with FTileMixin {
  const _WordTile({required this.item, required this.searchIn});

  final WordSummary item;

  /// `lemma` (Sambas A-Z / saring) atau `translation` (cari Indonesia).
  final String searchIn;

  @override
  Widget build(BuildContext context) {
    // Sambas: gloss A-Z / sense hasil search.
    // Indonesia: sense (gloss Sambas) - fallback matched_translation.
    final gloss = item.sense?.trim();
    final matched = item.matchedTranslation?.trim();
    String? subtitle;
    if (gloss != null && gloss.isNotEmpty) {
      subtitle = gloss;
    } else if (searchIn == 'translation' &&
        matched != null &&
        matched.isNotEmpty) {
      subtitle = matched;
    } else if (searchIn != 'translation' && item.wordType != 'word') {
      subtitle = item.wordTypeLabel;
    }

    return FTile(
      title: Text(item.lemma),
      subtitle: subtitle != null ? Text(subtitle) : null,
      suffix: item.isVerified
          ? const VerifiedBadgeIcon()
          : const PendingReviewBadgeIcon(),
      onPress: () {
        FocusManager.instance.primaryFocus?.unfocus();
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
            padding: const EdgeInsets.only(bottom: 24),
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

/// Riwayat pencarian: tampil saat field kosong. Tap = jalankan query itu,
/// ikon x = hapus satu, "Hapus" = bersihkan semua. Data lokal di HP
/// (shared_preferences), tidak dikirim ke server.
class _SearchHistorySection extends StatelessWidget {
  const _SearchHistorySection({
    required this.history,
    required this.onPick,
    required this.onRemove,
    required this.onClear,
  });

  final List<String> history;
  final ValueChanged<String> onPick;
  final ValueChanged<String> onRemove;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Gap(8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Riwayat pencarian',
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onClear,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    'Hapus',
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Gap(4),
          Expanded(
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final q = history[index];
                return FTile(
                  prefix: const Icon(FLucideIcons.history, size: 16),
                  title: Text(q),
                  suffix: GestureDetector(
                    onTap: () => onRemove(q),
                    child: const Icon(FLucideIcons.x, size: 16),
                  ),
                  onPress: () => onPick(q),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
