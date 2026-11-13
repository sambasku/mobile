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

  group('extractCoordsFromMapsUrl', () {
    test('prioritas !3d!4d (pola extractCoordinatesShortUrl)', () {
      const url =
          'https://www.google.com/maps/place/Foo/@1.10,109.10,17z/data=!3m1!1e3!4m6!3m5!1s0x0:0x0!8m2!3d1.36!4d109.30';
      final coords = extractCoordsFromMapsUrl(url);
      expect(coords?.lat, 1.36);
      expect(coords?.lng, 109.3);
    });

    test('pakai @lat,lng bila tidak ada pin', () {
      final coords = extractCoordsFromMapsUrl(
        'https://www.google.com/maps/place/Foo/@1.36,109.30,17z',
      );
      expect(coords?.lat, 1.36);
      expect(coords?.lng, 109.3);
    });

    test('null untuk place-id-only (butuh Nominatim)', () {
      expect(
        extractCoordsFromMapsUrl(
          'https://www.google.com/maps/place/Temajuk,+Kec.+Paloh,+Kabupaten+Sambas,+Kalimantan+Barat/data=!4m2!3m1!1s0x31e5337401887c35:0x50f63442eed2ad98',
        ),
        isNull,
      );
    });
  });

  group('extractPlaceNameFromMapsUrl + candidates', () {
    test('nama Temajuk → kandidat pendek untuk Nominatim', () {
      const url =
          'https://www.google.com/maps/place/Temajuk,+Kec.+Paloh,+Kabupaten+Sambas,+Kalimantan+Barat/data=!4m2!3m1!1s0x31e5337401887c35:0x50f63442eed2ad98';
      expect(
        extractPlaceNameFromMapsUrl(url),
        'Temajuk, Kec. Paloh, Kabupaten Sambas, Kalimantan Barat',
      );
      expect(buildPlaceGeocodeCandidates(extractPlaceNameFromMapsUrl(url)!).first, 'Temajuk');
    });
  });

  group('isShortMapsUrl', () {
    test('maps.app.goo.gl saja', () {
      expect(isShortMapsUrl('https://maps.app.goo.gl/abc'), isTrue);
      expect(
        isShortMapsUrl('https://www.google.com/maps/place/Foo/@1,2,17z'),
        isFalse,
      );
    });
  });
}
