import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/utils/display_image_url.dart';

void main() {
  group('jsDelivrToRawGithubUrl', () {
    test('konversi path gh/owner/repo@branch/file', () {
      const src =
          'https://cdn.jsdelivr.net/gh/sambasku/data@main/assets/events/abc.webp';
      expect(
        jsDelivrToRawGithubUrl(src),
        'https://raw.githubusercontent.com/sambasku/data/main/assets/events/abc.webp',
      );
    });

    test('null untuk host non-jsDelivr', () {
      expect(
        jsDelivrToRawGithubUrl('https://ik.imagekit.io/x/y.webp'),
        isNull,
      );
    });

    test('null untuk path tidak lengkap', () {
      expect(
        jsDelivrToRawGithubUrl('https://cdn.jsdelivr.net/gh/sambasku/data@main'),
        isNull,
      );
    });
  });

  group('displayImageUrl', () {
    test('bungkus jsDelivr dengan wsrv', () {
      const src =
          'https://cdn.jsdelivr.net/gh/sambasku/data@main/assets/events/a.webp';
      final out = displayImageUrl(src, width: 360);
      expect(out, contains('wsrv.nl'));
      expect(out, contains('cdn.jsdelivr.net'));
    });
  });
}
