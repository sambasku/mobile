import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/services/notification_service.dart';

void main() {
  test('shade inactive lalu resumed tidak refresh', () {
    final tracker = NotificationResumeTracker();
    expect(tracker.onLifecycle(AppLifecycleState.inactive), isFalse);
    expect(tracker.onLifecycle(AppLifecycleState.resumed), isFalse);
  });

  test('paused, inactive, lalu resumed refresh sekali', () {
    final tracker = NotificationResumeTracker();
    expect(tracker.onLifecycle(AppLifecycleState.paused), isFalse);
    expect(tracker.onLifecycle(AppLifecycleState.inactive), isFalse);
    expect(tracker.onLifecycle(AppLifecycleState.resumed), isTrue);
    expect(tracker.onLifecycle(AppLifecycleState.resumed), isFalse);
  });

  test('hidden lalu resumed refresh', () {
    final tracker = NotificationResumeTracker();
    expect(tracker.onLifecycle(AppLifecycleState.hidden), isFalse);
    expect(tracker.onLifecycle(AppLifecycleState.resumed), isTrue);
  });
}
