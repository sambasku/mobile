import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/share/domain/share_models.dart';
import 'package:sambasku_mobile/features/share/presentation/share_sheet.dart';

void main() {
  WordMeaning meaning({
    required String id,
    required int order,
    String? code,
    String? definition,
    List<WordTranslation> translations = const [],
  }) {
    return WordMeaning(
      id: id,
      orderIndex: order,
      wordClassCode: code,
      wordClassName: code == null ? null : 'Kelas $code',
      definition: definition,
      translations: translations,
    );
  }

  test('senseLinesForCard default hanya makna terpilih dengan kode kelas', () {
    final selected = meaning(
      id: 'm1',
      order: 1,
      code: 'n',
      definition: 'bulu di atas bibir',
      translations: const [
        WordTranslation(text: 'kumis', type: 'direct'),
      ],
    );
    final other = meaning(
      id: 'm2',
      order: 2,
      code: 'v',
      definition: 'dimarahi',
    );

    final lines = senseLinesForCard(
      [selected, other],
      allMeanings: false,
      selected: selected,
    );

    expect(lines, hasLength(1));
    expect(lines.first.wordClassBracket, '[n]');
    expect(lines.first.padanan, 'kumis');
    expect(lines.first.definition, 'bulu di atas bibir');
  });

  test('senseLinesForCard semua makna urut orderIndex, maks 3', () {
    final meanings = [
      meaning(id: 'm3', order: 3, code: 'adj', definition: 'ketiga'),
      meaning(id: 'm1', order: 1, code: 'n', definition: 'pertama'),
      meaning(id: 'm2', order: 2, code: 'v', definition: 'kedua'),
      meaning(id: 'm4', order: 4, code: 'adv', definition: 'keempat'),
    ];

    final lines = senseLinesForCard(
      meanings,
      allMeanings: true,
      selected: meanings.first,
      max: 3,
    );

    expect(lines.map((s) => s.wordClassBracket).toList(), ['[n]', '[v]', '[adj]']);
    expect(lines.map((s) => s.definition).toList(), [
      'pertama',
      'kedua',
      'ketiga',
    ]);
  });

  test('ShareCardData.copyText memakai daftar makna bernomor', () {
    final data = ShareCardData(
      lemma: 'somet',
      senses: const [
        ShareSenseLine(
          wordClassCode: 'n',
          padanan: 'kumis',
          definition: 'bulu di atas bibir',
        ),
        ShareSenseLine(
          wordClassCode: 'v',
          definition: 'dimarahi',
        ),
      ],
    );

    expect(
      data.copyText,
      contains('1 [n] → kumis\nbulu di atas bibir\n2 [v]\ndimarahi'),
    );
  });

  test('creditLine: stok biasa vs Creative Commons', () {
    expect(
      const ShareCardData(lemma: 'x', photographer: 'Jane', provider: 'pixabay')
          .creditLine,
      'Foto: Jane / Pixabay',
    );
    expect(
      const ShareCardData(
        lemma: 'x',
        photographer: 'Ada',
        provider: 'openverse',
        license: 'CC BY 2.0',
        source: 'flickr',
      ).creditLine,
      'Foto: Ada (CC BY 2.0, diubah) / Flickr',
    );
    expect(
      const ShareCardData(
        lemma: 'x',
        photographer: 'Ada',
        provider: 'openverse',
        license: 'CC0 1.0',
      ).creditLine,
      'Foto: Ada (CC0 1.0) / Openverse',
    );
  });
}
