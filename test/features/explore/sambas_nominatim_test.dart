import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/explore/data/sambas_nominatim.dart';

void main() {
  group('cleanNominatimQuery', () {
    test('null untuk kosong, pendek, panjang, tanpa alnum', () {
      expect(cleanNominatimQuery(''), isNull);
      expect(cleanNominatimQuery('  '), isNull);
      expect(cleanNominatimQuery('ab'), isNull);
      expect(cleanNominatimQuery('!!!'), isNull);
      expect(cleanNominatimQuery('a' * 81), isNull);
    });

    test('trim dan rapatkan spasi', () {
      expect(cleanNominatimQuery('  Pasar   Sambas  '), 'Pasar Sambas');
    });
  });

  group('inSambasBounds', () {
    test('titik pusat Sambas diterima', () {
      expect(inSambasBounds(1.36, 109.3), isTrue);
    });

    test('titik di luar kotak ditolak', () {
      expect(inSambasBounds(0.5, 109.3), isFalse);
      expect(inSambasBounds(1.36, 108.0), isFalse);
      expect(inSambasBounds(2.0, 109.3), isFalse);
      expect(inSambasBounds(1.36, 110.5), isFalse);
    });
  });

  group('parseNominatimHits', () {
    test('buang di luar bounds dan baris invalid', () {
      final hits = parseNominatimHits([
        {
          'lat': '1.36',
          'lon': '109.3',
          'display_name': 'Pasar Sambas',
        },
        {
          'lat': '-6.2',
          'lon': '106.8',
          'display_name': 'Jakarta',
        },
        {'lat': 'nan', 'lon': '109.3', 'display_name': 'rusak'},
        'bukan-map',
      ]);

      expect(hits, hasLength(1));
      expect(hits.single.lat, 1.36);
      expect(hits.single.lng, 109.3);
      expect(hits.single.label, 'Pasar Sambas');
    });

    test('tanpa display_name pakai fallback l10n', () {
      final hits = parseNominatimHits([
        {'lat': '1.36', 'lon': '109.3'},
      ]);

      expect(hits, hasLength(1));
      expect(hits.single.label, isNotEmpty);
    });

    test('bukan list → kosong', () {
      expect(parseNominatimHits(null), isEmpty);
      expect(parseNominatimHits({'lat': '1'}), isEmpty);
    });
  });
}
