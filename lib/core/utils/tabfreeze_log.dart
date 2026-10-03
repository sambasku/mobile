import 'package:flutter/foundation.dart';

/// Breadcrumb diagnostik tab-freeze. Satu tag supaya mudah difilter:
/// `adb logcat -v time | grep tabfreeze`. Dipakai di router, sheet menu
/// kontribusi, gerbang auth, dan heartbeat watchdog.
void tfLog(String msg) => debugPrint('[tabfreeze] $msg');
