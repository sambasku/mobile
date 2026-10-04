import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/explore/data/models/cuisine_dto.dart';

void main() {
  group('CuisineDto', () {
    test('parse json lengkap', () {
      final dto = CuisineDto.fromJson(const {
        'version': 1,
        'cuisines': [
          {
            'id': 'bubur-pedas-sambas',
            'slug': 'bubur-pedas-sambas',
            'name': 'Bubur Pedas Sambas',
            'description': 'Bubur khas Sambas.',
            'images': [
              {
                'url':
                    'https://cdn.jsdelivr.net/gh/sambasku/images@main/assets/cuisine/bubur-pedas.webp',
                'isMain': true,
                'attribution': {
                  'name': 'Wibowo Djatmiko (Wie146)',
                  'provider': 'Wikimedia Commons',
                  'license': 'CC BY-SA 3.0',
                  'license_url': 'https://creativecommons.org/licenses/by-sa/3.0/',
                },
              },
            ],
            'ingredients': ['Beras', 'Santan', 42, null],
            'servingSuggestion': 'Sajikan hangat.',
            'region': 'Kota Sambas',
            'tags': ['sarapan', ''],
            'sources': [
              {
                'name': 'Wikipedia - Bubur Pedas',
                'type': 'web',
                'address': 'https://id.wikipedia.org/wiki/Bubur_pedas',
              },
            ],
          },
          {'name': 'tanpa field wajib'},
        ],
      });

      expect(dto.cuisines, hasLength(1));
      final k = dto.cuisines.first.toEntity();
      expect(k.slug, 'bubur-pedas-sambas');
      expect(k.region, 'Kota Sambas');
      expect(k.images, hasLength(1));
      expect(k.images.first.isMain, isTrue);
      expect(k.images.first.attribution?.license, 'CC BY-SA 3.0');
      // elemen non-string / kosong di-skip
      expect(k.ingredients, ['Beras', 'Santan']);
      expect(k.tags, ['sarapan']);
      expect(k.servingSuggestion, 'Sajikan hangat.');
      expect(k.sources, hasLength(1));
      expect(k.cover, isNotNull);
    });

    test('json rusak: collection kosong, bukan throw', () {
      final dto = CuisineDto.fromJson(const {'cuisines': 'bukan list'});
      expect(dto.cuisines, isEmpty);
    });

    test('image tanpa https di-skip, tanpa main → pertama jadi main', () {
      final dto = CuisineDto.fromJson(const {
        'cuisines': [
          {
            'id': 'x',
            'slug': 'x',
            'name': 'X',
            'description': 'desc',
            'region': 'Sambas',
            'images': [
              {'url': 'http://insecure/a.webp'},
              {
                'url': 'https://cdn.jsdelivr.net/gh/sambasku/images@main/b.webp',
              },
            ],
          },
        ],
      });

      final k = dto.cuisines.first.toEntity();
      expect(k.images, hasLength(1));
      expect(k.images.first.isMain, isTrue);
      expect(k.images.first.url, contains('b.webp'));
    });
  });
}
