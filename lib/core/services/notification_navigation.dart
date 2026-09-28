import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/my_contributions/my_contributions_router.dart';
import '../../features/notification/domain/entities/inbox_notification.dart';
import '../../features/notification/notification_router.dart';
import '../../features/discussion/discussion_router.dart';
import '../../features/review/review_router.dart';
import '../../features/verifier_application/verifier_application_router.dart';
import '../router/app_router.dart';

/// Map payload FCM / AwesomeNotifications / inbox tile → rute atau URL eksternal.
Future<void> navigateFromNotificationPayload(
  Map<String, String?> data, {
  BuildContext? context,
}) async {
  final router = AppRouter.router;
  final type = data['type']?.trim() ?? '';
  final actionKind =
      data['action_kind']?.trim() ?? data['deep_link_kind']?.trim();
  final actionValue =
      data['action_value']?.trim() ??
      data['deep_link_value']?.trim() ??
      data['url']?.trim();

  if (actionKind == 'url' && actionValue != null && actionValue.isNotEmpty) {
    final opened = await openHttpsUrl(actionValue);
    if (!opened && context != null && context.mounted) {
      showFToast(
        context: context,
        title: const Text('Tidak bisa membuka tautan'),
      );
    }
    return;
  }

  if (actionKind == 'word' && actionValue != null && actionValue.isNotEmpty) {
    _go(router, '/words/$actionValue?focus=activity');
    return;
  }

  if ((actionKind == 'contribution' || actionKind == 'suggestion') &&
      actionValue != null &&
      actionValue.isNotEmpty) {
    _go(
      router,
      MyContributionsRouter.detailPath(kind: actionKind!, id: actionValue),
    );
    return;
  }

  if (actionKind == 'discussion' &&
      actionValue != null &&
      actionValue.isNotEmpty) {
    if (type == 'discussion_pending_review') {
      _go(router, ReviewRouter.discussionDetailPath(actionValue));
    } else {
      _go(router, DiscussionRouter.detailPath(actionValue));
    }
    return;
  }

  // Campaign tanpa CTA / fallback inbox.
  if (type == 'campaign' || data['target_kind']?.trim() == 'campaign') {
    final deepLinkKind = data['deep_link_kind']?.trim();
    final deepLinkValue = data['deep_link_value']?.trim();
    if (deepLinkKind == 'word' &&
        deepLinkValue != null &&
        deepLinkValue.isNotEmpty) {
      _go(router, '/words/$deepLinkValue?focus=activity');
      return;
    }
    if ((deepLinkKind == 'contribution' || deepLinkKind == 'suggestion') &&
        deepLinkValue != null &&
        deepLinkValue.isNotEmpty) {
      _go(
        router,
        MyContributionsRouter.detailPath(
          kind: deepLinkKind!,
          id: deepLinkValue,
        ),
      );
      return;
    }
    if (deepLinkKind == 'url' &&
        deepLinkValue != null &&
        deepLinkValue.isNotEmpty) {
      final opened = await openHttpsUrl(deepLinkValue);
      if (!opened && context != null && context.mounted) {
        showFToast(
          context: context,
          title: const Text('Tidak bisa membuka tautan'),
        );
      }
      return;
    }
    _go(router, NotificationRouter.list.path);
    return;
  }

  final targetKind = data['target_kind']?.trim();
  final targetId =
      data['target_id']?.trim() ??
      data['contribution_id']?.trim() ??
      data['application_id']?.trim();

  if (targetKind == 'word' && targetId != null && targetId.isNotEmpty) {
    _go(router, '/words/$targetId?focus=activity');
    return;
  }

  if (targetKind == 'discussion' ||
      type.startsWith('discussion')) {
    if (targetId != null && targetId.isNotEmpty) {
      if (type == 'discussion_pending_review') {
        _go(router, ReviewRouter.discussionDetailPath(targetId));
      } else {
        _go(router, DiscussionRouter.detailPath(targetId));
      }
    } else {
      _go(router, DiscussionRouter.mine.path);
    }
    return;
  }

  if (targetKind == 'verifier_application' ||
      type.startsWith('verifier_application')) {
    _go(router, VerifierApplicationRouter.apply.path);
    return;
  }

  if (targetKind != null &&
      targetKind.isNotEmpty &&
      targetId != null &&
      targetId.isNotEmpty) {
    _go(
      router,
      MyContributionsRouter.detailPath(kind: targetKind, id: targetId),
    );
    return;
  }

  final contributionId = data['contribution_id']?.trim();
  if (contributionId != null && contributionId.isNotEmpty) {
    _go(
      router,
      MyContributionsRouter.detailPath(
        kind: 'contribution',
        id: contributionId,
      ),
    );
    return;
  }

  if (type.isNotEmpty) {
    _go(router, NotificationRouter.list.path);
  }
}

/// Navigasi dari tile inbox (satu helper dengan FCM).
Future<void> navigateFromInboxNotification(
  BuildContext context,
  InboxNotification item,
) {
  return navigateFromNotificationPayload(
    {
      'type': item.type,
      'target_kind': item.targetKind,
      'target_id': item.targetId,
      'action_kind': item.actionKind,
      'action_value': item.actionValue,
    },
    context: context,
  );
}

/// Hanya https:// - tolak http, custom scheme, traversal (M-07).
Future<bool> openHttpsUrl(String raw) async {
  final trimmed = raw.trim();
  Uri? uri;
  try {
    uri = Uri.parse(trimmed);
  } catch (_) {
    return false;
  }
  if (uri.scheme.toLowerCase() != 'https') return false;
  if (uri.host.isEmpty) return false;
  if (uri.hasAbsolutePath && uri.path.contains('..')) return false;
  try {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e, st) {
    debugPrint('openHttpsUrl failed: $e\n$st');
    return false;
  }
}

void _go(GoRouter router, String location) {
  try {
    final targetPath = Uri.parse(location).path;
    // Sudah di halaman yang sama (mis. fallback inbox saat user di
    // /notifications) → jangan push lagi; stack jadi dobel tolol.
    if (router.state.uri.path == targetPath) {
      return;
    }
    router.push(location);
  } catch (e, st) {
    debugPrint('Notification navigation failed ($location): $e\n$st');
  }
}
