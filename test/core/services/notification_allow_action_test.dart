import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/services/notification_service.dart';

void main() {
  test('sudah diizinkan: shortcut tidak perlu aksi', () {
    expect(
      notificationAllowAction(osAllowed: true, permanentlyDenied: false),
      NotificationAllowAction.alreadyAllowed,
    );
    expect(
      notificationAllowAction(osAllowed: true, permanentlyDenied: true),
      NotificationAllowAction.alreadyAllowed,
    );
  });

  test('belum ditolak permanen: minta dialog sistem', () {
    expect(
      notificationAllowAction(osAllowed: false, permanentlyDenied: false),
      NotificationAllowAction.request,
    );
  });

  test('ditolak permanen: buka pengaturan', () {
    expect(
      notificationAllowAction(osAllowed: false, permanentlyDenied: true),
      NotificationAllowAction.openSettings,
    );
  });
}
