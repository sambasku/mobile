import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'device_registration_holder.dart';
import 'notification_navigation.dart';

/// Foreground FCM → Awesome Notifications (in-app saat app dibuka).
/// Permission diminta dari onboarding slide 3, bukan di cold start.
///
/// [onNotificationsMayHaveChanged] di-set dari bootstrap (`main`) agar
/// cache Riverpod (inbox + unread) di-invalidate tanpa `core` mengimpor
/// provider fitur.
class NotificationService {
  NotificationService._();

  static const _channelKey = 'sambasku_notifications';

  /// Dipanggil saat FCM foreground / tap / resume dari background.
  static VoidCallback? onNotificationsMayHaveChanged;

  /// Navigasi dari tap notifikasi (di-set di `main` setelah router siap).
  static void Function(Map<String, String?> payload)? onNotificationOpened;

  static bool _lifecycleAttached = false;
  static bool _initialMessageHandled = false;
  static final _lifecycleObserver = _NotificationLifecycleObserver();

  /// Init channel + listener tanpa meminta izin OS.
  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: _channelKey,
          channelName: 'SambasKu',
          channelDescription: 'Notifikasi dari SambasKu',
          defaultColor: const Color(0xFF0F766E),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
        ),
      ],
      debug: kDebugMode,
    );

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_onRemoteMessageOpened);

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceived,
    );

    debugPrint('NotificationService initialized (awesome_notifications)');
  }

  /// Cold start dari tap notifikasi (FCM). Panggil setelah [runApp].
  static Future<void> handleInitialMessage() async {
    if (_initialMessageHandled) return;
    _initialMessageHandled = true;
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      _onRemoteMessageOpened(initial);
    }
  }

  /// Pasang observer resume setelah [ProviderContainer] siap.
  /// Background FCM tidak punya akses ke container UI; resume menutup gap itu.
  static void attachAppLifecycle() {
    if (_lifecycleAttached) return;
    _lifecycleAttached = true;
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  /// Dipanggil dari onboarding slide 3 saat user tap Izinkan.
  static Future<void> requestPermissions() async {
    await FirebaseMessaging.instance.requestPermission();
    final allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!allowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    await DeviceRegistrationHolder.instance?.refreshFcmTokenAndRegister();
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] as String?;
    final body = notification?.body ?? message.data['body'] as String?;
    if (title == null && body == null) return;

    final imageUrl =
        message.data['image_url']?.toString() ??
        notification?.android?.imageUrl ??
        notification?.apple?.imageUrl;

    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: message.hashCode.abs() % 100000,
        channelKey: _channelKey,
        title: title ?? 'SambasKu',
        body: body ?? '',
        payload: message.data.map((k, v) => MapEntry(k, v.toString())),
        notificationLayout:
            hasImage ? NotificationLayout.BigPicture : NotificationLayout.Default,
        bigPicture: hasImage ? imageUrl : null,
      ),
    );

    // Banner tampil ≠ cache inbox/unread ikut berubah - invalidate di sini.
    _notifyCachesStale();
  }

  static void _notifyCachesStale() {
    onNotificationsMayHaveChanged?.call();
  }

  static void _onRemoteMessageOpened(RemoteMessage message) {
    debugPrint('Notification opened (FCM): ${message.data}');
    _notifyCachesStale();
    final payload = message.data.map((k, v) => MapEntry(k, v.toString()));
    final handler = onNotificationOpened;
    if (handler != null) {
      handler(payload);
    } else {
      navigateFromNotificationPayload(payload);
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _onActionReceived(ReceivedAction action) async {
    debugPrint('Notification tapped: ${action.payload}');
    _notifyCachesStale();
    final payload = action.payload;
    if (payload == null || payload.isEmpty) return;
    final handler = onNotificationOpened;
    if (handler != null) {
      handler(payload);
    } else {
      navigateFromNotificationPayload(payload);
    }
  }
}

class _NotificationLifecycleObserver with WidgetsBindingObserver {
  AppLifecycleState? _previous;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final previous = _previous;
    _previous = state;
    // Sama pola home feed: hanya saat benar-benar kembali dari non-resumed.
    if (state != AppLifecycleState.resumed) return;
    if (previous == null || previous == AppLifecycleState.resumed) return;
    NotificationService.onNotificationsMayHaveChanged?.call();
  }
}
