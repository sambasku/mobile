import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/models/image_attribution.dart';
import 'package:sambasku_mobile/features/explore/data/models/place_dto.dart';
import 'package:sambasku_mobile/features/explore/data/models/places_dto.dart';
import 'package:sambasku_mobile/features/explore/domain/entities/place.dart';

void main() {
  group('PlaceDto', () {
    test('parse place wisata valid lengkap', () {
      final dto = PlaceDto.fromJson(const {
        'id': '01M3ZWJ0KH7TCJ1K7KDDJE92D7',
        'slug': 'istana-alwatzikoebillah',
        'name': 'Istana Alwatzikoebillah',
        'category': 'wisata',
        'type': 'sejarah',
        'lat': 1.361722806,
        'lng': 109.3130395,
        'shortDescription': 'Istana Kesultanan Sambas.',
        'images': [
          {
            'url': 'https://cdn.jsdelivr.net/gh/sambasku/images@main/a.webp',
            'isMain': true,
            'attribution': {
              'name': 'Zhilal Darma',
              'provider': 'wikimedia',
              'url': 'https://commons.wikimedia.org/wiki/File:A.jpg',
              'license': 'CC BY-SA 4.0',
              'license_url': 'https://creativecommons.org/licenses/by-sa/4.0/',
            },
          },
          {
            'url': 'https://cdn.jsdelivr.net/gh/sambasku/images@main/b.webp',
            'isMain': false,
          },
        ],
        'hours': null,
        'contact': null,
        'relatedWordIds': [],
        'related': [
          {'kind': 'place', 'id': '01M3ZWJ0KH1205XE74HC341B2V'},
          {'kind': 'article', 'id': 'art-1'},
        ],
        'sources': [
          {
            'name': 'Wikipedia - Istana Alwatzikoebillah',
            'type': 'web',
            'address': 'https://id.wikipedia.org/wiki/Istana_Alwatzikoebillah',
            'license': 'CC BY-SA 3.0',
            'licenseUrl': 'https://creativecommons.org/licenses/by-sa/3.0/',
          },
        ],
      });

      expect(dto, isNotNull);
      final place = dto!.toEntity();
      expect(place.category, PlaceCategory.wisata);
      expect(place.type, PlaceType.sejarah);
      expect(place.images.length, 2);
      expect(place.images.first.isMain, isTrue);
      expect(place.images.first.attribution?.license, 'CC BY-SA 4.0');
      expect(place.cover?.url, contains('a.webp'));
      // kind article belum dikenal → di-skip, bukan gagal.
      expect(place.related.length, 1);
      expect(place.related.first.kind, PlaceRelatedKind.place);
      expect(place.sources.length, 1);
      expect(place.sources.first.licenseUrl, isNotNull);
    });

    test('kuliner: type selalu null walau JSON isi', () {
      final dto = PlaceDto.fromJson(const {
        'id': '01M3ZWJ0KHASMVKSNDJ2M4T17P',
        'slug': 'terubuk-asap',
        'name': 'Terubuk Asap',
        'category': 'kuliner',
        'type': 'sejarah',
        'lat': 1.17,
        'lng': 108.97,
        'shortDescription': 'Ikan terubuk asap.',
      });

      expect(dto!.type, isNull);
      expect(dto.toEntity().category, PlaceCategory.kuliner);
    });

    test('type tidak dikenal → null, item tetap masuk', () {
      final dto = PlaceDto.fromJson(const {
        'id': '01M3ZWJ0KH4C19D7BM86D8QQ6Z',
        'slug': 'tempat-x',
        'name': 'Tempat X',
        'category': 'wisata',
        'type': 'gunung', // di luar enum
        'lat': 1.2,
        'lng': 109.0,
        'shortDescription': 'Test.',
      });

      expect(dto!.type, isNull);
    });

    test('tanpa isMain → elemen pertama jadi main', () {
      final dto = PlaceDto.fromJson(const {
        'id': '01M3ZWJ0KHC7K9AZ3JR2SSGKRP',
        'slug': 'tempat-y',
        'name': 'Tempat Y',
        'category': 'wisata',
        'lat': 1.2,
        'lng': 109.0,
        'shortDescription': 'Test.',
        'images': [
          {'url': 'https://x.test/1.webp'},
          {'url': 'https://x.test/2.webp'},
        ],
      });

      final place = dto!.toEntity();
      expect(place.images.first.isMain, isTrue);
      expect(place.images[1].isMain, isFalse);
      expect(place.cover?.url, 'https://x.test/1.webp');
    });

    test('isMain true kedua tidak menimpa yang pertama', () {
      final dto = PlaceDto.fromJson(const {
        'id': '01M3ZWJ0KH3SJ1ZSB3HYSTJZ69',
        'slug': 'tempat-z',
        'name': 'Tempat Z',
        'category': 'wisata',
        'lat': 1.2,
        'lng': 109.0,
        'shortDescription': 'Test.',
        'images': [
          {'url': 'https://x.test/1.webp', 'isMain': true},
          {'url': 'https://x.test/2.webp', 'isMain': true},
        ],
      });

      final mains = dto!.toEntity().images.where((i) => i.isMain).length;
      expect(mains, 1);
    });

    test('item rusak (field wajib absen) → null, di-skip', () {
      expect(PlaceDto.fromJson(const {'name': 'tanpa id'}), isNull);
    });

    test('item tanpa lat/lng tetap lolos (koordinat opsional)', () {
      final dto = PlaceDto.fromJson(const {
        'id': 'X',
        'slug': 's',
        'name': 'n',
        'category': 'kuliner',
        // lat/lng absen
        'shortDescription': 'd',
      });
      expect(dto, isNotNull);
      final place = dto!.toEntity();
      expect(place.hasCoordinates, isFalse);
      expect(place.lat, isNull);
      expect(place.lng, isNull);
    });

    test(
      'gambar non-https di-skip, attribution bentuk aneh → null attribution',
      () {
        final dto = PlaceDto.fromJson(const {
          'id': '01M3ZWJ0KHAP57WKXAVW6ATE83',
          'slug': 'tempat-w',
          'name': 'Tempat W',
          'category': 'kuliner',
          'lat': 1.2,
          'lng': 109.0,
          'shortDescription': 'Test.',
          'images': [
            {'url': 'http://insecure.test/a.webp'},
            {'url': 'https://x.test/ok.webp', 'attribution': 'rusak'},
          ],
        });

        final place = dto!.toEntity();
        expect(place.images.length, 1);
        expect(place.images.first.attribution, isNull);
      },
    );

    test('PlacesDto: item rusak di-skip, koleksi tetap hidup', () {
      final dto = PlacesDto.fromJson(const {
        'version': 1,
        'places': [
          {'name': 'rusak'},
          {
            'id': '01M3ZWJ0KHYKZ0231PWK0YW1V4',
            'slug': 'ok',
            'name': 'OK',
            'category': 'kuliner',
            'lat': 1.2,
            'lng': 109.0,
            'shortDescription': 'Hidup.',
          },
        ],
      });

      expect(dto.places.length, 1);
      expect(dto.toEntity().first.slug, 'ok');
    });

    test('ImageAttribution snake_case license_url ter-parse', () {
      final a = ImageAttribution.fromJson(const {
        'name': 'Zhilal Darma',
        'provider': 'wikimedia',
        'license': 'CC BY-SA 4.0',
        'license_url': 'https://creativecommons.org/licenses/by-sa/4.0/',
      });

      expect(a?.licenseUrl, 'https://creativecommons.org/licenses/by-sa/4.0/');
    });
  });
}
