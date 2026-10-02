import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/cache/cache_providers.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../../vote/presentation/widgets/vote_buttons.dart';
import '../../domain/discussion_models.dart';
import '../../discussion_router.dart';
import '../providers/discussion_list_providers.dart';
import '../widgets/discussion_image_thumb.dart';

/// Feed publik ruang diskusi yang sudah tayang.
class DiscussionFeedPage extends HookConsumerWidget {
  const DiscussionFeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(discussionFeedProvider);
    final sort = ref.watch(discussionFeedSortProvider);
    final scroll = useScrollController();

    useEffect(() {
      void listener() {
        if (!scroll.hasClients) return;
        if (scroll.position.maxScrollExtent - scroll.position.pixels < 200) {
          ref.read(discussionFeedProvider.notifier).loadMore();
        }
      }

      scroll.addListener(listener);
      return () => scroll.removeListener(listener);
    }, [scroll]);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Ruang Diskusi'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.history),
            onPress: () => context.push(DiscussionRouter.mine.path),
          ),
        ],
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(responseCacheStoreProvider)
              .deleteByPrefix('GET|/api/v1/discussions');
          ref.invalidate(discussionFeedProvider);
          await ref.read(discussionFeedProvider.future);
        },
        child: async.when(
          loading: () => const _FeedSkeleton(),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              const _NewThreadComposer(),
              const Gap(24),
              Icon(
                FLucideIcons.circleAlert,
                size: 40,
                color: context.theme.colors.mutedForeground,
              ),
              const Gap(10),
              Text(
                error is DiscussionFailure
                    ? error.message
                    : 'Gagal memuat diskusi',
                textAlign: TextAlign.center,
                style: context.theme.typography.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
              const Gap(16),
              FButton(
                variant: FButtonVariant.outline,
                onPress: () => ref.invalidate(discussionFeedProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
          data: (state) {
            if (state.items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
                children: [
                  const _NewThreadComposer(),
                  const Gap(16),
                  _SortChips(
                    sort: sort,
                    onSelect: (s) =>
                        ref.read(discussionFeedSortProvider.notifier).select(s),
                  ),
                  const Gap(24),
                  Icon(
                    FLucideIcons.languages,
                    size: 40,
                    color: context.theme.colors.mutedForeground,
                  ),
                  const Gap(10),
                  Text(
                    'Belum ada diskusi yang tayang',
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
                ],
              );
            }

            // index 0 = composer, 1 = sort, lalu items (+ loading footer)
            return ListView.separated(
              controller: scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
              itemCount:
                  state.items.length + 2 + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) {
                // Pemisah hanya antar tile feed (bukan di atas composer/sort).
                if (index < 1) return const SizedBox.shrink();
                return Divider(height: 1, color: context.theme.colors.border);
              },
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: _NewThreadComposer(),
                  );
                }
                if (index == 1) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _SortChips(
                      sort: sort,
                      onSelect: (s) => ref
                          .read(discussionFeedSortProvider.notifier)
                          .select(s),
                    ),
                  );
                }
                final itemIndex = index - 2;
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

/// Field palsu di atas feed: tap → form buat thread + autofokus deskripsi.
class _NewThreadComposer extends StatelessWidget {
  const _NewThreadComposer();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            context.push('${DiscussionRouter.create.path}?focus=1'),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colors.border),
            color: theme.colors.secondary.withValues(alpha: 0.35),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  FLucideIcons.plus,
                  size: 18,
                  color: theme.colors.mutedForeground,
                ),
                const Gap(10),
                Expanded(
                  child: Text(
                    'Mulai thread baru…',
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedTile extends ConsumerWidget {
  const _FeedTile({required this.item});

  final DiscussionItem item;

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
        .read(discussionFeedProvider.notifier)
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
    final dateLabel = formatRelativeCompact(
      DateTime.tryParse(item.createdAt),
    );
    final actorLabel = displayPublicAccountLabel(
      displayName: item.displayName,
      username: item.username,
    );
    final canOpenProfile = isLinkablePublicUsername(item.username);
    final body = item.body?.trim() ?? '';
    final images = item.images;
    final contextMeta = [
      'Diskusi',
      if (images.length > 1) '${images.length} foto',
      if (item.hasAudio) 'Suara',
    ].join(' · ');

    // Satu foto 1:1 di kanan (seperti thumb ringkas; multi-foto hanya di detail).
    const thumbSize = 72.0;
    final leadImage = images.isEmpty ? null : images.first;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(DiscussionRouter.detailPath(item.id)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(name: actorLabel, imageUrl: item.avatarUrl, size: 40),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: canOpenProfile
                                    ? () => UserProfileRouter.open(
                                          context,
                                          item.username!,
                                        )
                                    : null,
                                child: Text(
                                  actorLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.typography.sm.copyWith(
                                    fontWeight: FontWeight.w700,
                                    height: 1.25,
                                    color: canOpenProfile
                                        ? theme.colors.primary
                                        : theme.colors.foreground,
                                  ),
                                ),
                              ),
                            ),
                            if (dateLabel.isNotEmpty) ...[
                              const Gap(8),
                              Text(
                                dateLabel,
                                style: theme.typography.xs.copyWith(
                                  color: theme.colors.mutedForeground,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (body.isNotEmpty) ...[
                          const Gap(4),
                          Text(
                            body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.typography.sm.copyWith(
                              height: 1.35,
                              color: theme.colors.foreground,
                            ),
                          ),
                        ],
                        const Gap(4),
                        Text(
                          contextMeta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.xs.copyWith(
                            color: theme.colors.mutedForeground,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (leadImage != null) ...[
                    const Gap(12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: DiscussionImageThumb(
                        image: leadImage,
                        revealed: false,
                        width: thumbSize,
                        height: thumbSize,
                      ),
                    ),
                  ],
                ],
              ),
              const Gap(8),
              // GestureDetector menyerap tap vote agar tidak buka detail.
              GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    const Gap(52), // sejajar teks di kanan avatar (40 + 12)
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
                        style: theme.typography.xs.copyWith(
                          color: theme.colors.mutedForeground,
                          height: 1.25,
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

  static const _options = <({String value, String label})>[
    (value: 'latest', label: 'Terbaru'),
    (value: 'popular', label: 'Populer'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final opt in _options)
                GestureDetector(
                  onTap: sort == opt.value ? null : () => onSelect(opt.value),
                  child: FBadge(
                    variant: sort == opt.value
                        ? FBadgeVariant.primary
                        : FBadgeVariant.secondary,
                    child: Text(opt.label),
                  ),
                ),
            ],
          ),
        ),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone.circle(size: 40),
              Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone.text(words: 2),
                    Gap(4),
                    Bone.multiText(lines: 2),
                    Gap(4),
                    Bone.text(words: 2),
                  ],
                ),
              ),
              Gap(12),
              Bone(width: 72, height: 72),
            ],
          ),
        ),
      ),
    );
  }
}
