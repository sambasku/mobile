import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/explore/data/maps_url_resolve.dart';

void main() {
  group('extractMapsUrlCandidate', () {
    test('ambil URL dari teks paste ber-spasi', () {
      expect(
        extractMapsUrlCandidate(
          '  lihat\nhttps://maps.app.goo.gl/abc123  ya',
        ),
        'https://maps.app.goo.gl/abc123',
      );
    });

    test('terima google.com/maps & maps.google.com', () {
      expect(
        extractMapsUrlCandidate(
          'https://www.google.com/maps/place/Foo/@1.2,109.0,17z',
        ),
        isNotNull,
      );
      expect(
        extractMapsUrlCandidate('https://maps.google.com/?q=1.2,109.0'),
        isNotNull,
      );
    });

    test('tolak host asing & http', () {
      expect(extractMapsUrlCandidate('https://evil.test/maps'), isNull);
      expect(extractMapsUrlCandidate('http://maps.app.goo.gl/x'), isNull);
      expect(extractMapsUrlCandidate('pasar sambas'), isNull);
    });
  });

  group('looksLikeMapsUrl', () {
    test('true hanya untuk tautan Maps', () {
      expect(looksLikeMapsUrl('https://maps.app.goo.gl/x'), isTrue);
      expect(looksLikeMapsUrl('Pasar Sambas'), isFalse);
    });
  });
}
