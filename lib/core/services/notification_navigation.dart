import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/my_contributions/my_contributions_router.dart';
import '../../features/notification/domain/entities/inbox_notification.dart';
import '../../features/notification/notification_router.dart';
import '../../features/discussion/discussion_router.dart';
import '../../features/review/review_router.dart';
import '../../features/verifier_application/verifier_application_router.dart';
import '../../shared/utils/error_bottom_sheet.dart';
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
    await _openExternalUrl(context, actionValue);
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
      await _openExternalUrl(context, deepLinkValue);
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

Future<void> _openExternalUrl(BuildContext? context, String raw) async {
  // Tap dari shade: ColorOS membatalkan startActivity saat animasi tutup
  // (log: handleResized abandoned, lalu MainActivity langsung resume).
  if (context == null) await _waitForShadeToClose();
  final failure = await openHttpsUrl(raw);
  if (failure != null) debugPrint('openHttpsUrl failed: $failure');
  if (failure == null || context == null || !context.mounted) return;
  await showAppErrorSheet(
    context,
    title: 'Tidak bisa membuka tautan',
    message: failure,
  );
}

/// `https://play.google.com/store/apps/details?id=pkg` → `market://details?id=pkg`.
/// Selain listing Play Store, null (tetap dibuka sebagai https).
Uri? playStoreMarketUri(Uri uri) {
  if (uri.scheme.toLowerCase() != 'https') return null;
  if (uri.host.toLowerCase() != 'play.google.com') return null;
  final path = uri.path.endsWith('/') && uri.path.length > 1
      ? uri.path.substring(0, uri.path.length - 1)
      : uri.path;
  if (path != '/store/apps/details') return null;
  final id = uri.queryParameters['id']?.trim();
  if (id == null || id.isEmpty) return null;
  return Uri(scheme: 'market', host: 'details', queryParameters: {'id': id});
}

/// `null` bila tautan terbuka. Selain itu pesan gagal, termasuk teks exception.
Future<String?> openHttpsUrl(String raw) async {
  final trimmed = raw.trim();
  Uri? uri;
  try {
    uri = Uri.parse(trimmed);
  } catch (e) {
    return e.toString();
  }
  if (uri.scheme.toLowerCase() != 'https') {
    return 'Tautan harus https.';
  }
  if (uri.host.isEmpty) return 'Tautan tidak valid.';
  if (uri.hasAbsolutePath && uri.path.contains('..')) {
    return 'Tautan tidak valid.';
  }
  final market = playStoreMarketUri(uri);
  if (market != null) {
    try {
      final opened = await launchUrl(
        market,
        mode: LaunchMode.externalApplication,
      );
      if (opened) return null;
      debugPrint('openHttpsUrl market failed, fallback https: $market');
    } catch (e, st) {
      debugPrint('openHttpsUrl market failed: $e\n$st');
    }
  }
  try {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) return 'Tidak ada aplikasi yang bisa membuka tautan ini.';
    return null;
  } catch (e, st) {
    debugPrint('openHttpsUrl failed: $e\n$st');
    return e.toString();
  }
}

/// ponytail: 400ms menutup animasi shade ColorOS. Upgrade: callback animasi shade.
Future<void> _waitForShadeToClose() async {
  final binding = WidgetsBinding.instance;
  if (binding.lifecycleState != AppLifecycleState.resumed) {
    final done = Completer<void>();
    late final AppLifecycleListener listener;
    listener = AppLifecycleListener(
      onResume: () {
        if (!done.isCompleted) done.complete();
      },
    );
    try {
      await done.future.timeout(const Duration(seconds: 2));
    } on TimeoutException {
      // Activity tidak resume; tetap coba buka.
    }
    listener.dispose();
  }
  await Future<void>.delayed(const Duration(milliseconds: 400));
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
