import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/notification_service.dart';

/// State shortcut "Izinkan notifikasi" untuk [ProfilePage].
class AllowNotificationShortcut {
  const AllowNotificationShortcut({
    required this.visible,
    required this.busy,
    required this.onPress,
  });

  /// True hanya jika izin OS belum diberikan.
  final bool visible;
  final bool busy;
  final Future<void> Function(BuildContext context) onPress;
}

/// Panggil dari build [HookWidget]. Tile disembunyikan kalau sudah diizinkan.
AllowNotificationShortcut useAllowNotificationShortcut() {
  final visible = useState(false);
  final busy = useState(false);
  final alive = useRef(true);

  Future<void> refresh() async {
    if (kIsWeb) return;
    try {
      final action = await NotificationService.currentAllowAction();
      if (!alive.value) return;
      visible.value = action != NotificationAllowAction.alreadyAllowed;
    } catch (error, stack) {
      debugPrint('allow-notif check failed: $error\n$stack');
      if (alive.value) visible.value = false;
    }
  }

  useEffect(() {
    unawaited(refresh());
    final listener = AppLifecycleListener(
      onResume: () {
        unawaited(refresh());
      },
    );
    return () {
      alive.value = false;
      listener.dispose();
    };
  }, const []);

  Future<void> onPress(BuildContext context) async {
    if (busy.value || !alive.value) return;
    busy.value = true;
    try {
      var action = await NotificationService.currentAllowAction();
      if (action == NotificationAllowAction.request) {
        await NotificationService.requestPermissions();
        action = await NotificationService.currentAllowAction();
      }
      if (!alive.value || !context.mounted) return;
      switch (action) {
        case NotificationAllowAction.alreadyAllowed:
          visible.value = false;
          _logAllow('granted');
          showFToast(
            context: context,
            title: const Text('Notifikasi diizinkan'),
          );
        case NotificationAllowAction.openSettings:
          final opened = await showAllowNotificationSettingsSheet(context);
          _logAllow(opened ? 'settings' : 'dismissed');
        case NotificationAllowAction.request:
          _logAllow('denied');
          showFToast(
            context: context,
            title: const Text('Notifikasi belum diizinkan'),
          );
      }
    } finally {
      if (alive.value) busy.value = false;
    }
  }

  return AllowNotificationShortcut(
    visible: visible.value,
    busy: busy.value,
    onPress: onPress,
  );
}

void _logAllow(String result) {
  AnalyticsService.instance.log(
    AnalyticsEvents.notificationAllow,
    params: {'result': result, 'source': 'profile'},
  );
}

/// OS tidak menampilkan dialog lagi. User harus menyalakan dari Pengaturan.
/// True jika user menekan Pengaturan.
Future<bool> showAllowNotificationSettingsSheet(BuildContext context) async {
  final opened = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    barrierColor: Colors.black54,
    builder: (sheetContext) => Padding(
      padding: MediaQuery.of(sheetContext).viewInsets,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FTileGroup(
              children: [
                FTile(
                  title: const Text('Notifikasi dimatikan'),
                  subtitle: const Text(
                    'Aktifkan notifikasi SambasKu di Pengaturan perangkat agar kabar usulan tetap sampai.',
                  ),
                ),
                FTile(
                  title: const Text(''),
                  suffix: FButton(
                    onPress: () {
                      openAppSettings();
                      Navigator.of(sheetContext).pop(true);
                    },
                    child: const Text('Pengaturan'),
                  ),
                ),
                FTile(
                  title: const Text(''),
                  suffix: FButton(
                    onPress: () => Navigator.of(sheetContext).pop(false),
                    child: const Text('Batal'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return opened ?? false;
}
