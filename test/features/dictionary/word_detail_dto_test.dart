import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/dictionary/data/models/word_detail_dto.dart';

/// Cuplikan GET /words/:id untuk "somet": contoh kedua punya target_sentence null.
/// Sebelumnya `as String` melempar dan seluruh halaman detail gagal.
void main() {
  test('WordDetailDto menerima target_sentence dan notes null', () {
    final dto = WordDetailDto.fromJson(sometDetail);

    expect(dto.notes, isNull);
    expect(dto.lemma, 'somet');
    expect(dto.usageLabels, isEmpty);
    expect(dto.meanings, hasLength(1));

    final examples = dto.meanings.first.examples;
    expect(examples, hasLength(2));
    expect(examples[0].targetSentence, 'sungguh tebal kumis orang itu');
    expect(examples[1].targetSentence, isNull);
    expect(examples[1].sourceType, isNull);
    expect(examples[1].targetLanguageId, '01M32TP371ZJ2JKVG24K2XNDZ4');
    expect(examples[1].audios, hasLength(1));
    expect(examples[1].audios.first.speakerName, 'Ibnul Mutaki');
    expect(dto.meanings.first.wordClass?.parentId, isNull);
    expect(dto.meanings.first.definition, contains('bibir'));
  });

  test('contoh tanpa target_language_id dan source_type tetap ter-parse', () {
    final dto = ExampleDto.fromJson({
      'id': 'ex-1',
      'source_language_id': 'src',
      'source_sentence': 'sometmu yo cukor',
      'target_language_id': null,
      'target_sentence': null,
      'source_type': null,
    });

    expect(dto.targetLanguageId, isNull);
    expect(dto.targetSentence, isNull);
    expect(dto.sourceType, isNull);
    expect(dto.audios, isEmpty);
  });

  test('WordDetailDto mem-parse usage_labels', () {
    final dto = WordDetailDto.fromJson({
      ...sometDetail,
      'usage_labels': ['kasar', 'informal'],
    });

    expect(dto.usageLabels, ['kasar', 'informal']);
  });
}

final sometDetail = <String, dynamic>{
  'id': '01M33HCMTN85A4QNPZE8CHWC02',
  'lemma': 'somet',
  'language_id': '01M32TP336MKN6E26BV09FMXEF',
  'notes': null,
  'word_type': 'word',
  'status': 'published',
  'is_verified': true,
  'is_corrected': false,
  'self_verified': true,
  'verified_by': {
    'username': 'admin',
    'display_name': 'Admin Sambas',
    'role': 'admin',
  },
  'verified_at': '2026-09-22T03:08:44.000Z',
  'meanings': [
    {
      'id': '01M34HHXKHJNZTMMY74PB34AMD',
      'word_class': {
        'id': '01M32TP3T3257CZKV1CQDJ1ZKE',
        'code': 'n',
        'name': 'Nomina',
        'alias': 'Kata Benda',
        'description': 'noun',
        'parent_id': null,
      },
      'inherited_from_meaning_id': null,
      'definition': 'bulu (rambut) yang tumbuh di atas bibir atas',
      'is_have_definition': true,
      'is_have_translation': true,
      'order_index': 1,
      'translations': [
        {
          'language_id': '01M32TP371ZJ2JKVG24K2XNDZ4',
          'translation_text': 'kumis',
          'translation_type': 'direct',
        },
      ],
      'examples': [
        {
          'id': '01M34HHXSTWP83207QC7NXMVZH',
          'source_language_id': '01M32TP336MKN6E26BV09FMXEF',
          'source_sentence': 'carekan tabal somet biak iye',
          'target_language_id': '01M32TP371ZJ2JKVG24K2XNDZ4',
          'target_sentence': 'sungguh tebal kumis orang itu',
          'source_type': 'native_speaker',
          'audios': [
            {
              'id': '01M33KJM35RVNNGEE03RD4BFR5',
              'url': 'https://example.com/a.wav',
              'dialect_id': '01M32TP3E1JFBBG0QF1A278EPD',
              'speaker_name': 'Ibnul Mutaki',
              'duration_ms': 1720,
              'is_primary': true,
              'mime_type': 'audio/wav',
            },
          ],
        },
        {
          'id': '01M34HHXSTV18D0JBFJ0F80QTS',
          'source_language_id': '01M32TP336MKN6E26BV09FMXEF',
          'source_sentence': 'sometmu yo cukor',
          'target_language_id': '01M32TP371ZJ2JKVG24K2XNDZ4',
          'target_sentence': null,
          'source_type': null,
          'audios': [
            {
              'id': '01M34HJY6XW7Y9V1NFFNADJ0KV',
              'url': 'https://example.com/b.wav',
              'dialect_id': '01M32TP3E1JFBBG0QF1A278EPD',
              'speaker_name': 'Ibnul Mutaki',
              'duration_ms': 1540,
              'is_primary': true,
              'mime_type': 'audio/wav',
            },
          ],
        },
      ],
    },
  ],
  'categories': [],
  'pronunciations': [],
  'images': [],
  'audios': [],
  'related_words': [],
  'appears_in': [],
  'variants': [],
};
