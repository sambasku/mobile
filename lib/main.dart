import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/cache/cache_providers.dart';
import 'core/network/auth_token_storage.dart';
import 'core/network/failover/api_host_resolver.dart';
import 'core/network/network_providers.dart';
import 'core/services/device_id_service.dart';
import 'core/services/device_registration_holder.dart';
import 'core/services/device_registration_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/notification_navigation.dart';
import 'core/services/analytics_service.dart';
import 'core/theme/forui_palette_controller.dart';
import 'core/theme/theme_mode_controller.dart';
import 'core/utils/tabfreeze_log.dart';
import 'features/device/data/datasources/device_remote_datasource.dart';
import 'features/device/data/repositories/device_repository_impl.dart';
import 'features/notification/presentation/providers/notification_providers.dart';
import 'features/onboarding/data/onboarding_prefs.dart';
import 'features/verifier_application/presentation/providers/verifier_application_providers.dart';
import 'flavors.dart';
import 'shared/dev_tool/dev_tool_overlay.dart';
import 'shared/dev_tool/exception_log/exception_log.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.messageId}');
}

/// Entry utama. Flavor dari:
/// - `--flavor staging|production` → inject FLUTTER_APP_FLAVOR
/// - atau `--dart-define=FLAVOR=...` (fallback lokal)
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Photo Picker di semua API (default hanya API 33+). Tanpa READ_MEDIA_*.
  final imagePickerImplementation = ImagePickerPlatform.instance;
  if (imagePickerImplementation is ImagePickerAndroid) {
    imagePickerImplementation.useAndroidPhotoPicker = true;
  }

  // TextureView di Android - lebih andal saat map berdampingan dengan scroll.
  MapLibreMap.useHybridComposition = true;
  // Abaikan hasil; preWarm fire-and-forget untuk cold start map lebih cepat.
  MapLibreMap.preWarm();

  const flutterFlavor = String.fromEnvironment('FLUTTER_APP_FLAVOR');
  const dartFlavor = String.fromEnvironment('FLAVOR', defaultValue: 'staging');
  final flavorName = flutterFlavor.isNotEmpty ? flutterFlavor : dartFlavor;

  F.appFlavor = Flavor.values.firstWhere(
    (element) => element.name == flavorName,
    orElse: () => Flavor.staging,
  );

  if (F.isStaging && !F.hideDevChrome) {
    installStagingExceptionLog();
  }

  // Daftar tier API harus siap SEBELUM dioProvider dibaca di bawah - Dio
  // mengambil baseUrl awalnya dari resolver.
  ApiHostResolver.instance.configureFromEnv();
  // Paksa-tier hanya dihormati saat perkakas dev hidup; build production milik
  // pengguna tidak boleh terkunci di tier cadangan karena preferensi lama.
  if (devToolsEnabled) await ApiHostResolver.instance.loadForcedTier();

  // Prefs sebelum runApp: frame pertama = preferensi tersimpan, bukan
  // ThemeMode.system (ikut device) yang lalu jump setelah hydrate async.
  final prefs = await SharedPreferences.getInstance();
  await ThemeModeController.preload(prefs);
  await ForuiPaletteController.preload(prefs);
  await OnboardingPrefs.preload(prefs);

  // L1 response cache (hive_ce) sebelum frame pertama - cold start
  // boleh menyajikan reference/WOTD dari disk.
  await initResponseCacheStore();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Izin notifikasi diminta di onboarding slide 3, bukan di cold start.
  await NotificationService.init();
  await AnalyticsService.instance.init();

  // getToken() bisa beberapa detik di OEM tertentu. Jangan ditunggu sebelum
  // frame pertama - DeviceRegistrationService.start() (setelah frame)
  // sudah fetch token sendiri.

  // Container agar device repo memakai Dio yang sama (dengan AuthInterceptor).
  final container = ProviderContainer(retry: (_, _) => null);
  final dio = container.read(dioProvider);
  final registrationService = DeviceRegistrationService(
    repository: DeviceRepositoryImpl(DeviceRemoteDatasource(dio)),
    tokenStorage: AuthTokenStorage.instance,
    deviceIdService: DeviceIdService(prefs: prefs),
    initialFcmToken: '',
  );
  DeviceRegistrationHolder.instance = registrationService;

  // Bridge FCM → Riverpod: keepAlive inbox/unread tidak auto-refetch.
  NotificationService.onNotificationsMayHaveChanged = () {
    container.invalidate(unreadNotificationCountControllerProvider);
    container.invalidate(notificationInboxListControllerProvider);
    // Status pengajuan verifikator ikut refresh saat approve/reject push masuk.
    container.invalidate(verifierApplicationProvider);
  };
  NotificationService.onNotificationOpened = (payload) {
    // Tunggu frame supaya GoRouter sudah punya navigator.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigateFromNotificationPayload(payload);
    });
  };
  NotificationService.attachAppLifecycle();

  // retry: null = matikan auto-retry Riverpod 3 (default: 10x backoff ~47s).
  // Failure 4xx tidak transient - retry manual via tombol "Coba lagi" di UI;
  // satu-satunya retry bermakna (401 -> refresh sekali) sudah di AuthInterceptor.
  runApp(UncontrolledProviderScope(container: container, child: const App()));

  // Watchdog diagnostik tab-freeze (staging/debug): heartbeat internal tiap
  // 2 detik (tanpa log per detak). Saat freeze terjadi lagi: heartbeat jalan = Dart hidup,
  // input diblokir barrier/navigator (keluarga sheet race); heartbeat
  // berhenti = event loop Dart wedged. Jeda >8s saat resumed (bukan
  // background/doze) tercatat ke ExceptionLog - terlihat di panel
  // DevTool tanpa perlu logcat.
  if (devToolsEnabled) {
    DateTime? lastBeat;
    DateTime? lastNonResumed;
    AppLifecycleListener(
      onStateChange: (s) {
        if (s != AppLifecycleState.resumed) lastNonResumed = DateTime.now();
      },
    );
    Timer.periodic(const Duration(seconds: 2), (_) {
      final now = DateTime.now();
      final last = lastBeat;
      lastBeat = now;
      if (last == null) return;
      final gap = now.difference(last);
      if (gap <= const Duration(seconds: 8)) return;
      // Jeda yang tumpang tindih periode non-resumed bukan wedge.
      final nonResumed = lastNonResumed;
      if (nonResumed != null && nonResumed.isAfter(last)) return;
      if (WidgetsBinding.instance.lifecycleState !=
          AppLifecycleState.resumed) {
        return;
      }
      tfLog('wedge gap=${gap.inSeconds}s');
      ExceptionLog.buffer.add(
        StateError('UI wedged ${gap.inSeconds}s (event loop Dart tertahan)'),
        StackTrace.current,
      );
    });
  }

  // HTTP register device SETELAH frame pertama. Kalau DevTool memaksa
  // tier 3 (Render tidur), menunggu 75s di sini sebelum runApp = ANR.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(registrationService.start());
    unawaited(NotificationService.handleInitialMessage());
  });
}
