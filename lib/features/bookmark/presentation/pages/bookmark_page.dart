import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/pending_review_badge_icon.dart';
import '../../../../core/widgets/verified_badge_icon.dart';
import '../../../../shared/widgets/tile_group_list.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/entities/bookmark_item.dart';
import '../../domain/failures/bookmark_failure.dart';
import '../providers/bookmark_providers.dart';

/// Halaman daftar kata tersimpan milik user login - GET /api/v1/bookmarks/my
/// (16-api-bookmark.md). Diakses dari tile Bookmark di Profil.
///
/// List pakai TileGroupList: autoload saat scroll mendekati ekor,
/// ekor, tanpa tombol "Muat lagi".
class BookmarkPage extends ConsumerWidget {
  const BookmarkPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStatusProvider);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Bookmark'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      // Auth error → treat as guest (jangan spinner abadi lewat orElse).
      child: auth.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (_, _) => const _GuestState(),
        data: (status) =>
            status.isAuth ? const _BookmarkList() : const _GuestState(),
      ),
    );
  }
}

class _GuestState extends StatelessWidget {
  const _GuestState();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FLucideIcons.bookmark,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              'Masuk dulu untuk melihat kata tersimpan',
              style: theme.typography.md.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => context.push('/login'),
              child: const Text('Masuk'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkList extends ConsumerWidget {
  const _BookmarkList();

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(bookmarkListControllerProvider);
    await ref.read(bookmarkListControllerProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final async = ref.watch(bookmarkListControllerProvider);

    // Riverpod `when` mengecek isLoading DULU - saat AsyncLoading+error
    // (retry/rebuild) cabang error tidak pernah dipanggil → spinner tanpa
    // pesan. Prefer hasError supaya 4xx/5xx selalu tampil ke user.
    if (async.hasError) {
      final error = async.error!;
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FLucideIcons.circleAlert,
                size: 40,
                color: theme.colors.mutedForeground,
              ),
              const Gap(10),
              Text(
                error is BookmarkFailure
                    ? error.message
                    : 'Gagal memuat bookmark',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              FButton(
                variant: FButtonVariant.outline,
                onPress: () =>
                    ref.invalidate(bookmarkListControllerProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (async.isLoading) {
      return const Center(child: FCircularProgress());
    }

    final state = async.requireValue;

    if (state.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: LayoutBuilder(
          builder: (context, constraints) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: constraints.maxHeight,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FLucideIcons.bookmark,
                        size: 40,
                        color: theme.colors.mutedForeground,
                      ),
                      const Gap(10),
                      Text(
                        'Belum ada kata tersimpan.',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(4),
                      Text(
                        'Tekan ikon bookmark di halaman detail kata.',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: TileGroupList<BookmarkItem>(
        items: state.items,
        hasMore: state.hasMore,
        onLoadMore: () =>
            ref.read(bookmarkListControllerProvider.notifier).loadMore(),
        tileBuilder: (context, item) => _BookmarkRow(item: item),
      ),
    );
  }
}

class _BookmarkRow extends ConsumerWidget {
  const _BookmarkRow({required this.item});

  final BookmarkItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unavailable = !item.word.available;
    return FTile(
      title: Text(item.word.lemma),
      subtitle: Text(
        unavailable ? 'Entri tidak lagi tersedia' : item.word.wordTypeLabel,
      ),
      suffix: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.word.isVerified) ...[
            const VerifiedBadgeIcon(size: 16),
            const Gap(4),
          ] else if (!unavailable) ...[
            const PendingReviewBadgeIcon(size: 16),
            const Gap(4),
          ],
          _RemoveButton(wordId: item.wordId),
        ],
      ),
      onPress: unavailable
          ? () {
              showFToast(
                context: context,
                title: const Text('Entri tidak lagi tersedia'),
              );
            }
          : () => context.push('/words/${item.wordId}'),
    );
  }
}

class _RemoveButton extends ConsumerWidget {
  const _RemoveButton({required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    // GestureDetector di suffix: serap tap supaya tidak ikut onPress tile.
    return Semantics(
      button: true,
      label: 'Lepas kata dari bookmark',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          final failure = await ref
              .read(bookmarkListControllerProvider.notifier)
              .remove(wordId);
          if (failure != null && context.mounted) {
            showFToast(
              context: context,
              title: Text(failure.message),
              variant: FToastVariant.destructive,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            FLucideIcons.trash2,
            size: 16,
            color: theme.colors.mutedForeground,
          ),
        ),
      ),
    );
  }
}
