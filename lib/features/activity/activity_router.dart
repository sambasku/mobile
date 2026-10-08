import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'domain/entities/feed_activity_item.dart';
import 'presentation/pages/announcement_detail_page.dart';
import 'presentation/pages/pinned_announcements_page.dart';
import 'presentation/providers/announcement_detail_provider.dart';

/// Router pengumuman (#102). Detail dibuka dengan `state.extra` berisi
/// [FeedAnnouncement] beku dari baris feed - tanpa fetch ulang (payload
/// adalah sumber kebenaran feed, pola #94). Deep link / restore state
/// (extra hilang) → fetch publik by id.
class ActivityRouter {
  ActivityRouter._();

  static const announcementDetail = RouteDefiner(
    path: '/announcements/:id',
    name: 'ActivityRouter.announcementDetail',
  );

  static const pinnedAnnouncements = RouteDefiner(
    path: '/pinned',
    name: 'ActivityRouter.pinnedAnnouncements',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: pinnedAnnouncements.path,
      name: pinnedAnnouncements.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const PinnedAnnouncementsPage(),
    ),
    GoRoute(
      path: announcementDetail.path,
      name: announcementDetail.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is FeedAnnouncement) {
          return AnnouncementDetailPage(announcement: extra);
        }
        return AnnouncementDeepLinkPage(id: state.pathParameters['id'] ?? '');
      },
    ),
  ];
}

/// Fallback deep link: pengumuman sudah dihapus / tidak ditemukan.
class AnnouncementMissingPage extends StatelessWidget {
  const AnnouncementMissingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: const Text('Pengumuman'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      childPad: true,
      child: Center(
        child: Text(
          'Pengumuman tidak lagi tersedia.',
          style: context.theme.typography.sm.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
      ),
    );
  }
}

/// Pembungkus deep link: `state.extra` kosong → fetch by id,
/// gagal/404 → [AnnouncementMissingPage].
class AnnouncementDeepLinkPage extends ConsumerWidget {
  const AnnouncementDeepLinkPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (id.isEmpty) return const AnnouncementMissingPage();
    final detail = ref.watch(announcementDetailProvider(id));
    return detail.when(
      loading: () => const _AnnouncementLoader(),
      error: (_, _) => const AnnouncementMissingPage(),
      data: (announcement) => announcement == null
          ? const AnnouncementMissingPage()
          : AnnouncementDetailPage(announcement: announcement),
    );
  }
}

class _AnnouncementLoader extends StatelessWidget {
  const _AnnouncementLoader();

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: const Text('Pengumuman'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      childPad: true,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
