import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/dictionary/data/models/card_images_dto.dart';

void main() {
  group('CardImagesDto', () {
    test('parse home.json valid lengkap', () {
      const json = {
        'version': 1,
        'cards': {
          'wotd': {
            'imageUrl':
                'https://cdn.jsdelivr.net/gh/sambasku/data@main/mobile/assets/wotd_cover.webp',
            'alignment': 'topCenter',
          },
        },
      };

      final dto = CardImagesDto.fromJson(json);

      expect(dto.version, 1);
      expect(dto.cards['wotd']?.imageUrl,
          'https://cdn.jsdelivr.net/gh/sambasku/data@main/mobile/assets/wotd_cover.webp');
      expect(dto.cards['wotd']?.alignment, 'topCenter');
    });

    test('alignment tidak valid/absen → default bottomCenter', () {
      final dto = CardImagesDto.fromJson({
        'version': 1,
        'cards': {
          'a': {'imageUrl': 'https://x.test/a.webp'},
          'b': {'imageUrl': 'https://x.test/b.webp', 'alignment': 'kiri'},
        },
      });

      expect(dto.cards['a']?.alignment, 'bottomCenter');
      expect(dto.cards['b']?.alignment, 'bottomCenter');
    });

    test('entry tanpa imageUrl atau non-https → entry dibuang', () {
      final dto = CardImagesDto.fromJson({
        'version': 1,
        'cards': {
          'x': {'alignment': 'center'},
          'y': {'imageUrl': 'http://insecure.test/a.webp'},
        },
      });

      expect(dto.cards, isEmpty);
    });

    test('JSON bukan map / cards bukan map → CardImagesException', () {
      expect(
        () => CardImagesDto.fromJson({'cards': 1}),
        throwsA(isA<CardImagesException>()),
      );
    });

    test('toEntity membawa card valid ke entity, whitelist alignment', () {
      final dto = CardImagesDto.fromJson({
        'version': 1,
        'cards': {
          'wotd': {'imageUrl': 'https://x.test/wotd.webp'},
          'bad': {'imageUrl': 'http://x.test/bad.webp'},
        },
      });

      final entity = dto.toEntity();

      expect(entity.entryOf('wotd')?.alignmentValue, Alignment.bottomCenter);
      expect(entity.entryOf('bad'), isNull);
    });
  });
}
