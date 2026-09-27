import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/cache/cache_providers.dart';
import '../../../../core/utils/display_image_url.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../vote/presentation/widgets/vote_buttons.dart';
import '../../domain/translation_help_models.dart';
import '../../translation_help_router.dart';
import '../providers/translation_help_list_providers.dart';

/// Feed publik bantuan terjemahan yang sudah tayang.
class TranslationHelpFeedPage extends HookConsumerWidget {
  const TranslationHelpFeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(translationHelpFeedProvider);
    final sort = ref.watch(translationHelpFeedSortProvider);
    final scroll = useScrollController();

    useEffect(() {
      void listener() {
        if (!scroll.hasClients) return;
        if (scroll.position.maxScrollExtent - scroll.position.pixels < 200) {
          ref.read(translationHelpFeedProvider.notifier).loadMore();
        }
      }

      scroll.addListener(listener);
      return () => scroll.removeListener(listener);
    }, [scroll]);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Bantuan Terjemahan'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.history),
            onPress: () => context.push(TranslationHelpRouter.mine.path),
          ),
          FHeaderAction(
            icon: const Icon(FLucideIcons.plus),
            onPress: () => context.push(TranslationHelpRouter.create.path),
          ),
        ],
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(responseCacheStoreProvider)
              .deleteByPrefix('GET|/api/v1/translation-helps');
          ref.invalidate(translationHelpFeedProvider);
          await ref.read(translationHelpFeedProvider.future);
        },
        child: async.when(
          loading: () => const _FeedSkeleton(),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              const Gap(40),
              Icon(
                FLucideIcons.circleAlert,
                size: 40,
                color: context.theme.colors.mutedForeground,
              ),
              const Gap(10),
              Text(
                error is TranslationHelpFailure
                    ? error.message
                    : 'Gagal memuat bantuan terjemahan',
                textAlign: TextAlign.center,
                style: context.theme.typography.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
              const Gap(16),
              FButton(
                variant: FButtonVariant.outline,
                onPress: () => ref.invalidate(translationHelpFeedProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
          data: (state) {
            if (state.items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(0, 24, 0, 32),
                children: [
                  _SortChips(
                    sort: sort,
                    onSelect: (s) =>
                        ref.read(translationHelpFeedSortProvider.notifier).select(s),
                  ),
                  const Gap(24),
                  Icon(
                    FLucideIcons.languages,
                    size: 40,
                    color: context.theme.colors.mutedForeground,
                  ),
                  const Gap(10),
                  Text(
                    'Belum ada bantuan yang tayang',
                    textAlign: TextAlign.center,
                    style: context.theme.typography.md.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(6),
                  Text(
                    'Kirim foto atau teks yang sulit diterjemahkan supaya warga bisa membantu.',
                    textAlign: TextAlign.center,
                    style: context.theme.typography.sm.copyWith(
                      color: context.theme.colors.mutedForeground,
                    ),
                  ),
                  const Gap(16),
                  FButton(
                    onPress: () =>
                        context.push(TranslationHelpRouter.create.path),
                    child: const Text('Minta bantuan'),
                  ),
                ],
              );
            }

            return ListView.separated(
              controller: scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
              itemCount: state.items.length + 1 + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: context.theme.colors.border),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _SortChips(
                      sort: sort,
                      onSelect: (s) => ref
                          .read(translationHelpFeedSortProvider.notifier)
                          .select(s),
                    ),
                  );
                }
                final itemIndex = index - 1;
                if (itemIndex >= state.items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: FCircularProgress()),
                  );
                }
                return _FeedTile(item: state.items[itemIndex]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _FeedTile extends ConsumerWidget {
  const _FeedTile({required this.item});

  final TranslationHelpItem item;

  Future<void> _toggleVote(BuildContext context, WidgetRef ref, int value) async {
    final auth = ref.read(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) {
      showFToast(
        context: context,
        title: const Text('Masuk dulu untuk memberi vote'),
        variant: FToastVariant.primary,
      );
      context.push('/login');
      return;
    }
    final failure = await ref
        .read(translationHelpFeedProvider.notifier)
        .toggleHelpVote(item, value);
    if (failure != null && context.mounted) {
      showFToast(
        context: context,
        title: Text(failure.message),
        variant: FToastVariant.destructive,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final when = formatRelative(DateTime.tryParse(item.createdAt));
    final username = displayPublicAccountLabel(
      displayName: item.displayName,
      username: item.username,
    );
    final body = item.body?.trim() ?? '';
    final urls = item.imageDisplayUrls;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(TranslationHelpRouter.detailPath(item.id)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      username,
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  if (when.isNotEmpty)
                    Text(
                      when,
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
              if (body.isNotEmpty) ...[
                const Gap(6),
                Text(
                  body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.sm,
                ),
              ],
              if (urls.isNotEmpty) ...[
                const Gap(8),
                SizedBox(
                  height: 72,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: urls.length.clamp(0, 4),
                    separatorBuilder: (_, _) => const Gap(6),
                    itemBuilder: (context, i) {
                      final src = urls[i];
                      final display = displayImageUrl(src, width: 200) ?? src;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: CachedNetworkImageWithFallback(
                            imageUrl: display,
                            fallbackUrl: src,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const Gap(8),
              // GestureDetector menyerap tap vote agar tidak buka detail.
              GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    VoteButtons(
                      upvotes: item.upvotes,
                      downvotes: 0,
                      myVote: item.myVote,
                      onVote: (value) => _toggleVote(context, ref, value),
                      compact: true,
                      upvoteOnly: true,
                    ),
                    const Gap(10),
                    Expanded(
                      child: Text(
                        'Saya juga ingin tahu',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortChips extends StatelessWidget {
  const _SortChips({required this.sort, required this.onSelect});

  final String sort;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    Widget chip(String value, String label) {
      final selected = sort == value;
      return FButton(
        variant: selected ? FButtonVariant.primary : FButtonVariant.outline,
        onPress: selected ? null : () => onSelect(value),
        child: Text(label),
      );
    }

    return Row(
      children: [
        chip('latest', 'Terbaru'),
        const Gap(8),
        chip('popular', 'Populer'),
        const Spacer(),
        Text(
          sort == 'popular' ? 'Menurut upvote' : 'Menurut waktu',
          style: theme.typography.sm.copyWith(
            color: theme.colors.mutedForeground,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
        itemCount: 6,
        itemBuilder: (_, _) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone.text(words: 2),
              Gap(8),
              Bone.multiText(lines: 2),
              Gap(8),
              Bone(width: 72, height: 72),
            ],
          ),
        ),
      ),
    );
  }
}
