import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/auth/presentation/pages/legal_webview_policy.dart';

/// WebView legal: JS off + hanya navigasi same-host in-app (#75).
void main() {
  const initial = 'https://sambasku.com/id/syarat-ketentuan';

  test('same host + https → in-app', () {
    expect(
      shouldAllowInAppNavigation(
        Uri.parse(initial),
        Uri.parse('https://sambasku.com/id/privasi'),
      ),
      isTrue,
    );
  });

  test('host lain → bukan in-app (buka eksternal)', () {
    expect(
      shouldAllowInAppNavigation(
        Uri.parse(initial),
        Uri.parse('https://evil.example.com/phish'),
      ),
      isFalse,
    );
    expect(
      shouldAllowInAppNavigation(
        Uri.parse(initial),
        Uri.parse('https://sambasku.com.evil.io/'),
      ),
      isFalse,
    );
    expect(
      shouldAllowInAppNavigation(
        Uri.parse(initial),
        Uri.parse('https://sub.sambasku.com/'),
      ),
      isFalse,
      reason: 'exact host match, bukan suffix',
    );
  });

  test('skema non-http → bukan in-app (mailto/tel/intent)', () {
    expect(
      shouldAllowInAppNavigation(
        Uri.parse(initial),
        Uri.parse('mailto:hi@sambasku.com'),
      ),
      isFalse,
    );
    expect(
      shouldAllowInAppNavigation(
        Uri.parse(initial),
        Uri.parse('tel:+628123456789'),
      ),
      isFalse,
    );
  });

  test('case-insensitive host', () {
    expect(
      shouldAllowInAppNavigation(
        Uri.parse('https://Sambasku.com/x'),
        Uri.parse('https://sambasku.COM/y'),
      ),
      isTrue,
    );
  });
}
