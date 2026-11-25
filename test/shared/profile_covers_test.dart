import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/shared/profile/profile_covers.dart';

void main() {
  test('fromEnvelope parses tab and public urls', () {
    final c = ProfileCovers.fromEnvelope({
      'success': true,
      'data': {
        'tab_url': 'https://cdn.example/tab.webp',
        'public_url': '  ',
        'wotd_url': 'https://cdn.example/wotd.webp',
      },
    });
    expect(c.tabUrl, 'https://cdn.example/tab.webp');
    expect(c.publicUrl, isNull);
    expect(c.wotdUrl, 'https://cdn.example/wotd.webp');
  });
}