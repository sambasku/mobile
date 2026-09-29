import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../discussion/domain/discussion_models.dart';
import '../../review_router.dart';
import '../providers/discussion_review_providers.dart';

/// Antrean diskusi pending_review untuk verifikator.
class DiscussionReviewQueuePage extends ConsumerWidget {
  const DiscussionReviewQueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final async = ref.watch(discussionReviewListProvider);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Tinjauan Diskusi'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: async.when(
        loading: () => Skeletonizer(
          enabled: true,
          child: ListView(
            children: List.generate(
              6,
              (_) => FTile(
                title: Text('Cuplikan diskusi'),
                subtitle: Text('Pengirim'),
              ),
            ),
          ),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                error is DiscussionFailure
                    ? error.message
                    : 'Gagal memuat antrean diskusi',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(12),
              FButton(
                variant: FButtonVariant.outline,
                onPress: () => ref.invalidate(discussionReviewListProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (state) {
          if (state.items.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada diskusi menunggu tinjauan',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(discussionReviewListProvider);
              await ref.read(discussionReviewListProvider.future);
            },
            child: ListView.builder(
              itemCount: state.items.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.items.length) {
                  if (!state.isLoadingMore) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.read(discussionReviewListProvider.notifier).loadMore();
                    });
                  }
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: FCircularProgress()),
                  );
                }
                final item = state.items[index];
                final preview = (item.body ?? '').trim();
                final name = displayPublicAccountLabel(
                  displayName: item.displayName,
                  username: item.username,
                );
                final thumb = item.images.isNotEmpty
                    ? item.images.first.displaySource
                    : null;
                return FTile(
                  prefix: thumb != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: CachedNetworkImageWithFallback(
                              imageUrl: displayImageUrl(thumb) ?? thumb,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : const Icon(FLucideIcons.messageSquare),
                  title: Text(
                    preview.isEmpty ? '(tanpa teks)' : preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    [
                      name,
                      if (item.createdAt.isNotEmpty)
                        formatRelativeCompact(
                          DateTime.tryParse(item.createdAt),
                        ),
                      if (item.linkUrl != null && item.linkUrl!.isNotEmpty)
                        'Ada tautan',
                    ].where((e) => e.isNotEmpty).join(' · '),
                  ),
                  suffix: const Icon(FLucideIcons.chevronRight),
                  onPress: () => context.push(
                    ReviewRouter.discussionDetailPath(item.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
