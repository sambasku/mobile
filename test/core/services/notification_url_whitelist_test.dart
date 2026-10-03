import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/services/notification_navigation.dart';

void main() {
  test('host whitelist sambasku.com lolos', () {
    expect(
      isAllowedNotificationHost(Uri.parse('https://sambasku.com/id/donasi')),
      isTrue,
    );
  });

  test('host whitelist staging lolos', () {
    expect(
      isAllowedNotificationHost(
        Uri.parse('https://sambasku-web-staging.iamutaki.com/x'),
      ),
      isTrue,
    );
  });

  test('host whitelist play.google.com lolos', () {
    expect(
      isAllowedNotificationHost(
        Uri.parse('https://play.google.com/store/apps/details?id=x'),
      ),
      isTrue,
    );
  });

  test('domain mirip ditolak (evil suffix)', () {
    expect(
      isAllowedNotificationHost(Uri.parse('https://sambasku.com.evil.io')),
      isFalse,
    );
    expect(
      isAllowedNotificationHost(Uri.parse('https://evilsambasku.com')),
      isFalse,
    );
  });

  test('host lain ditolak', () {
    expect(
      isAllowedNotificationHost(Uri.parse('https://attacker.example/phish')),
      isFalse,
    );
  });

  test('subdomain acak dari host whitelist ditolak', () {
    // Exact-host match: hanya host yang terdaftar, bukan *.sambasku.com
    expect(
      isAllowedNotificationHost(Uri.parse('https://api.sambasku.com/x')),
      isFalse,
    );
  });
}
