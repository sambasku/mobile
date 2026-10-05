import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/notification_navigation.dart';
import '../../../../core/utils/display_image_url.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/tile_group_list.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/entities/inbox_notification.dart';
import '../../domain/failures/notification_failure.dart';
import '../../domain/providers/notification_domain_providers.dart';
import '../../notification_router.dart';
import '../providers/notification_providers.dart';

class NotificationInboxPage extends HookConsumerWidget {
  const NotificationInboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      AnalyticsService.instance.log(AnalyticsEvents.inboxOpen);
      return null;
    }, const []);

    final auth = ref.watch(authStatusProvider);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Notifikasi'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: auth.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (_, _) => const _GuestState(),
        data: (status) =>
            status.isAuth ? const _InboxList() : const _GuestState(),
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
              FLucideIcons.bell,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              'Masuk dulu untuk melihat notifikasi',
              style: theme.typography.md.copyWith(fontWeight: FontWeight.w600),
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

class _InboxList extends HookConsumerWidget {
  const _InboxList();

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(notificationInboxListControllerProvider);
    ref.invalidate(unreadNotificationCountControllerProvider);
    await ref.read(notificationInboxListControllerProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final async = ref.watch(notificationInboxListControllerProvider);
    final unreadCount =
        ref.watch(unreadNotificationCountControllerProvider).value ?? 0;
    final markingAll = useState(false);

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
                error is NotificationFailure
                    ? error.message
                    : 'Gagal memuat notifikasi',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              FButton(
                variant: FButtonVariant.outline,
                onPress: () =>
                    ref.invalidate(notificationInboxListControllerProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (async.isLoading) {
      final viewportHeight = MediaQuery.sizeOf(context).height;
      final skeletonPerPage = (viewportHeight ~/ 80) + 2;
      return _ListSkeleton(itemCount: skeletonPerPage);
    }

    Future<void> markAllRead() async {
      if (markingAll.value || unreadCount <= 0) return;
      markingAll.value = true;
      final result = await ref.read(markAllNotificationsReadUseCaseProvider)();
      if (!context.mounted) return;
      result.match(
        (failure) {
          markingAll.value = false;
          showFToast(context: context, title: Text(failure.message));
        },
        (_) {
          ref
              .read(notificationInboxListControllerProvider.notifier)
              .markAllLocalRead();
          ref.read(unreadNotificationCountControllerProvider.notifier).clear();
          markingAll.value = false;
        },
      );
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
                        FLucideIcons.bell,
                        size: 40,
                        color: theme.colors.mutedForeground,
                      ),
                      const Gap(10),
                      Text(
                        'Belum ada notifikasi',
                        style: theme.typography.md.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(4),
                      Text(
                        'Status usulan yang sudah direview akan muncul di sini.',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (unreadCount > 0)
          Align(
            alignment: Alignment.centerRight,
            child: FButton(
              variant: FButtonVariant.ghost,
              onPress: markingAll.value ? null : markAllRead,
              prefix: markingAll.value ? const FCircularProgress() : null,
              child: Text(
                markingAll.value
                    ? 'Menandai...'
                    : 'Tandai semua telah dibaca',
              ),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: TileGroupList<InboxNotification>(
              items: state.items,
              hasMore: state.hasMore,
              onLoadMore: () => ref
                  .read(notificationInboxListControllerProvider.notifier)
                  .loadMore(),
              tileBuilder: (context, item) => _NotificationTile(item: item),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationTile extends ConsumerWidget with FTileMixin {
  const _NotificationTile({required this.item});

  final InboxNotification item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = formatDateTimeIso(item.createdAt);
    final theme = context.theme;
    final isCampaign = item.type == 'campaign' || item.targetKind == 'campaign';
    final thumbUrl = displayImageUrl(item.imageUrl, width: 96, height: 96);
    final rawImage = item.imageUrl?.trim();
    return FTile(
      title: Text(
        item.title,
        style: TextStyle(
          color: item.isUnread
              ? theme.colors.foreground
              : theme.colors.mutedForeground,
          fontWeight: item.isUnread ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      subtitle: Text(
        [item.typeLabel, if (date.isNotEmpty) date, item.body].join(' · '),
      ),
      prefix: Badge(
        isLabelVisible: item.isUnread,
        backgroundColor: theme.colors.destructive,
        smallSize: 8,
        child: Icon(
          FLucideIcons.bell,
          color: item.isUnread
              ? theme.colors.foreground
              : theme.colors.mutedForeground,
        ),
      ),
      suffix: thumbUrl == null
          ? const Icon(FLucideIcons.chevronRight)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  button: true,
                  label: 'Lihat gambar',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: rawImage == null || rawImage.isEmpty
                        ? null
                        : () => showImagePreview(context, urls: [rawImage]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CachedNetworkImageWithFallback(
                          imageUrl: thumbUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const Gap(8),
                const Icon(FLucideIcons.chevronRight),
              ],
            ),
      onPress: () async {
        AnalyticsService.instance.log(
          AnalyticsEvents.notificationItemTap,
          params: {'type': item.type, 'target_kind': item.targetKind},
        );
        // Optimistic: UI + navigasi dulu; mark-read API di belakang
        // supaya tap tidak terasa lag menunggu jaringan.
        if (item.isUnread) {
          ref
              .read(notificationInboxListControllerProvider.notifier)
              .markLocalRead(item.id);
          ref
              .read(unreadNotificationCountControllerProvider.notifier)
              .decrement();
          unawaited(ref.read(markNotificationReadUseCaseProvider)(item.id));
        }
        if (!context.mounted) return;
        if (isCampaign) {
          context.push(NotificationRouter.detailPath(item.id), extra: item);
          return;
        }
        await navigateFromInboxNotification(context, item);
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
      title: Text('Usulan disetujui contoh'),
      subtitle: Text('Disetujui · 21 Sep 2026 00:00 · Usulan kata Anda'),
    );
  }
}
