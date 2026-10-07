import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'domain/entities/feed_activity_item.dart';
import 'presentation/pages/announcement_detail_page.dart';

/// Router pengumuman (#102). Detail dibuka dengan `state.extra` berisi
/// [FeedAnnouncement] beku dari baris feed - tanpa fetch ulang (payload
/// adalah sumber kebenaran feed, pola #94).
class ActivityRouter {
  ActivityRouter._();

  static const announcementDetail = RouteDefiner(
    path: '/announcements/:id',
    name: 'ActivityRouter.announcementDetail',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: announcementDetail.path,
      name: announcementDetail.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) {
        final announcement = state.extra;
        return announcement is FeedAnnouncement
            ? AnnouncementDetailPage(announcement: announcement)
            : const AnnouncementMissingPage();
      },
    ),
  ];
}

/// Fallback state.extra hilang (deep link / restore). Tanpa fetch ulang
/// v1: pengumuman hanya diakses dari feed.
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
