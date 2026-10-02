import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/dictionary/data/card_images_config.dart';

void main() {
  group('CardImagesConfig.tryParse', () {
    test('null/rusak/kosong → null', () {
      expect(CardImagesConfig.tryParse(null), isNull);
      expect(CardImagesConfig.tryParse('bukan-map'), isNull);
      expect(CardImagesConfig.tryParse({'cards': {}}), isNull);
    });

    test('entry valid ter-parse, alignment valid dipertahankan', () {
      final cfg = CardImagesConfig.tryParse({
        'version': 1,
        'cards': {
          'wotd': {
            'imageUrl': 'https://cdn.jsdelivr.net/gh/x@main/a.webp',
            'alignment': 'topCenter',
          },
        },
      });
      expect(cfg, isNotNull);
      expect(
        cfg!.entryOf('wotd')!.imageUrl,
        'https://cdn.jsdelivr.net/gh/x@main/a.webp',
      );
      expect(cfg.entryOf('wotd')!.alignmentValue, Alignment.topCenter);
    });

    test('imageUrl non-https / absen → entry dibuang', () {
      final cfg = CardImagesConfig.tryParse({
        'cards': {
          'wotd': {'imageUrl': 'http://insecure/x.webp'},
          'banner': {'imageUrl': 123},
        },
      });
      expect(cfg, isNull); // semua entry invalid → config null
    });

    test('alignment aneh → fallback bottomCenter', () {
      final cfg = CardImagesConfig.tryParse({
        'cards': {
          'wotd': {'imageUrl': 'https://x/y.webp', 'alignment': 'kena-angin'},
        },
      });
      expect(cfg!.entryOf('wotd')!.alignmentValue, Alignment.bottomCenter);
    });
  });
}
