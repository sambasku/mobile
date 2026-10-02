import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../activity/presentation/widgets/activity_feed_tile.dart';
import '../../domain/entities/public_profile.dart';
import '../../domain/public_activity_mapper.dart';
import '../providers/user_profile_providers.dart';

/// Bottom sheet yang menampilkan riwayat aktivitas per kategori (kind).
/// Pagination manual: loadMore saat scroll mendekati bawah.
class ActivityCategorySheet extends HookConsumerWidget {
  const ActivityCategorySheet({
    super.key,
    required this.username,
    required this.kind,
    required this.profile,
  });

  final String username;
  final String kind; // 'contribution' | 'comment' | 'verification' | 'vote'
  final PublicProfile profile;

  String _kindLabel(String kind) {
    switch (kind) {
      case 'contribution':
        return 'Kontribusi';
      case 'comment':
        return 'Komentar';
      case 'verification':
        return 'Verifikasi';
      case 'vote':
        return 'Vote';
      default:
        return kind;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final scrollController = useScrollController();
    final state = useState<(
      List<PublicActivityItem>,
      String?,
      bool,
      bool // isLoadingMore
    )>(
      ([], null, false, false),
    );

    Future<void> loadInitial() async {
      final page = await ref.read(
        publicActivityByKindProvider(username, kind).future,
      );
      state.value = (page.items, page.nextCursor, page.hasMore, false);
    }

    Future<void> loadMore() async {
      final (items, cursor, hasMore, isLoading) = state.value;
      if (!hasMore || isLoading || cursor == null) return;

      state.value = (items, cursor, hasMore, true);
      final page = await ref.read(
        publicActivityByKindProvider(username, kind, cursor: cursor).future,
      );
      state.value = (
        [...items, ...page.items],
        page.nextCursor,
        page.hasMore,
        false,
      );
    }

    useEffect(() {
      loadInitial();
      return;
    }, []);

    void onScroll() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        loadMore();
      }
    }

    useEffect(() {
      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    final (items, _, hasMore, isLoadingMore) = state.value;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header dengan handle
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Gap(12),
                Row(
                  children: [
                    Text(
                      _kindLabel(kind),
                      style: theme.typography.lg.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${items.length} item',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List
          Flexible(
            child: items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FLucideIcons.fileText,
                            size: 48,
                            color: theme.colors.mutedForeground,
                          ),
                          const Gap(12),
                          Text(
                            'Belum ada $_kindLabel${kind.toLowerCase()}',
                            style: theme.typography.md.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: items.length + (hasMore || isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      if (index >= items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: FCircularProgress()),
                        );
                      }
                      final item = items[index];
                      final feedItem = mapPublicActivityToFeed(item, profile);
                      return ActivityFeedTile(item: feedItem);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}