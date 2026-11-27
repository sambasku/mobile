import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/shared/profile/profile_covers.dart';

void main() {
  test('fromEnvelope parses tab, public, wotd, and layanan urls', () {
    final c = ProfileCovers.fromEnvelope({
      'success': true,
      'data': {
        'tab_url': 'https://cdn.example/tab.webp',
        'public_url': '  ',
        'wotd_url': 'https://cdn.example/wotd.webp',
        'layanan_url': 'https://cdn.example/layanan.webp',
      },
    });
    expect(c.tabUrl, 'https://cdn.example/tab.webp');
    expect(c.publicUrl, isNull);
    expect(c.wotdUrl, 'https://cdn.example/wotd.webp');
    expect(c.layananUrl, 'https://cdn.example/layanan.webp');
  });

  test('fromEnvelope returns null layananUrl when absent or blank', () {
    final c = ProfileCovers.fromEnvelope({
      'success': true,
      'data': {'layanan_url': '   '},
    });
    expect(c.layananUrl, isNull);
  });
}