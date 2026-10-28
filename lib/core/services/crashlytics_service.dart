import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../../flavors.dart';

/// Abstraksi Firebase Crashlytics. Page/notifier tidak memanggil
/// `FirebaseCrashlytics` langsung - fatal/uncaught lewat hook di [init].
class CrashlyticsService {
  CrashlyticsService._({FirebaseCrashlytics? crashlytics})
    : _injected = crashlytics;

  static CrashlyticsService? _instance;

  static CrashlyticsService get instance =>
      _instance ??= CrashlyticsService._();

  @visibleForTesting
  static void debugReset([CrashlyticsService? service]) {
    _instance = service;
  }

  final FirebaseCrashlytics? _injected;
  FirebaseCrashlytics? _resolved;
  bool _ready = false;

  FirebaseCrashlytics get _crashlytics =>
      _injected ?? (_resolved ??= FirebaseCrashlytics.instance);

  /// Panggil sekali setelah `Firebase.initializeApp()`, sebelum
  /// `installStagingExceptionLog` (supaya ExceptionLog bisa chain ke hook
  /// Crashlytics sebagai `previous`).
  Future<void> init() async {
    if (_ready || kIsWeb) return;
    try {
      // Aktif di semua flavor (termasuk debug/staging) supaya crash staging
      // terlihat di console Firebase; filter lewat custom key app_flavor.
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
      await _crashlytics.setCustomKey('app_flavor', F.appFlavor.name);

      FlutterError.onError = (FlutterErrorDetails details) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };

      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      _ready = true;
    } catch (e, st) {
      debugPrint('CrashlyticsService.init failed: $e\n$st');
    }
  }

  /// Error non-fatal (opsional, dari catch yang ingin dipantau).
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    String? reason,
  }) async {
    if (!_ready || kIsWeb) return;
    try {
      await _crashlytics.recordError(
        error,
        stack,
        fatal: fatal,
        reason: reason,
      );
    } catch (e, st) {
      debugPrint('CrashlyticsService.recordError failed: $e\n$st');
    }
  }
}
