import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/app_update/domain/latest_release.dart';

void main() {
  group('isNewerRelease', () {
    test('versi lebih tinggi = true', () {
      expect(isNewerRelease('0.2.0', '0.1.0'), isTrue);
      expect(isNewerRelease('1.0.0', '0.9.9'), isTrue);
      expect(isNewerRelease('0.10.0', '0.9.1'), isTrue); // numerik, bukan string
      expect(isNewerRelease('0.1.1', '0.1.0'), isTrue);
    });

    test('versi sama atau lebih rendah = false', () {
      expect(isNewerRelease('0.1.0', '0.1.0'), isFalse);
      expect(isNewerRelease('0.1.0', '0.2.0'), isFalse);
      expect(isNewerRelease('0.9.9', '1.0.0'), isFalse);
    });

    test('build number (+N) diabaikan', () {
      expect(isNewerRelease('0.2.0+5', '0.2.0+100'), isFalse);
      expect(isNewerRelease('0.2.0', '0.1.0+99'), isTrue);
      // pubspec mobile: 0.1.0+1
      expect(isNewerRelease('0.1.0+2', '0.1.0+1'), isFalse);
    });

    test('panjang segmen beda (minor missing = 0)', () {
      expect(isNewerRelease('0.1.0.1', '0.1.0'), isTrue);
      expect(isNewerRelease('0.1', '0.1.0'), isFalse);
    });

    test('segmen non-numerik diperlakukan 0, tidak crash', () {
      expect(isNewerRelease('0.2.0', 'beta'), isTrue);
      expect(isNewerRelease('x.y.z', '0.0.0'), isFalse);
    });
  });

  group('LatestRelease.fromJson', () {
    test('store_url kosong/null = storeUrl null (banner skip)', () {
      expect(
        LatestRelease.fromJson({
          'platform': 'ios',
          'version': '0.1.0',
          'store_url': null,
        }).storeUrl,
        isNull,
      );
      expect(
        LatestRelease.fromJson({
          'platform': 'ios',
          'version': '0.1.0',
          'store_url': '',
        }).storeUrl,
        isNull,
      );
    });

    test('store_url valid terparse', () {
      final r = LatestRelease.fromJson({
        'platform': 'android',
        'version': '0.2.0',
        'store_url': 'https://play.google.com/store/apps/details?id=com.iamutaki.sambasku',
        'notes': 'Bug fixes',
      });
      expect(r.storeUrl?.host, 'play.google.com');
      expect(r.version, '0.2.0');
      expect(r.notes, 'Bug fixes');
    });

    test('data null API (belum ada release) aman', () {
      final r = LatestRelease.fromJson(<String, dynamic>{});
      expect(r.version, '');
      expect(r.storeUrl, isNull);
    });
  });
}
