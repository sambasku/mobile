import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/review/data/review_correct_body.dart';

const _sbs = '01LANGSAMBAS0000000000000';
const _idn = '01LANGIDN00000000000000000';
const _eng = '01LANGENG00000000000000000';
const _nomina = '01CLASSNOMINA000000000000';
const _verba = '01CLASSVERBA0000000000000';

final _entity = <String, dynamic>{
  'languageId': _sbs,
  'lemma': 'kalintiak',
  'wordType': 'word',
  'meanings': [
    {
      'definition': 'ikan kecil',
      'wordClass': {'id': _nomina},
      'translations': [
        {'languageId': _idn, 'translationText': 'ikan', 'translationType': 'direct'},
        {'languageId': _eng, 'translationText': 'small fish', 'translationType': 'idiomatic'},
      ],
      'examples': [
        {
          'sourceLanguageId': _sbs,
          'sourceSentence': 'Kalintiak di sungai',
          'targetLanguageId': _idn,
          'targetSentence': 'Ikan kecil di sungai',
          'sourceType': 'folk',
        },
      ],
    },
    {
      'definition': 'makna yang dihapus',
      'wordClass': {'id': _verba},
      'translations': <Map<String, dynamic>>[],
    },
  ],
  'relatedWords': [
    {'wordId': 'W-OLD', 'lemma': 'lama', 'relationType': 'synonym'},
  ],
  'variants': [
    {'form': 'klintiak', 'variantType': 'regional', 'dialectId': 'D1'},
  ],
  'images': [
    {'url': 'https://cdn.example/a.png', 'providerFileId': 'f1', 'isPrimary': true},
  ],
  'pronunciations': [
    {'notation': 'ipa', 'value': 'ka.lin.tiak'},
  ],
  'categories': [
    {'id': 'C1'},
  ],
};

void main() {
  test('makna baru + contoh, makna dihapus, relasi & variasi dari form', () {
    final body = buildWordCorrectBody(
      entity: _entity,
      lemma: 'kalintiak',
      notes: '',
      wordType: 'word',
      usageLabels: const ['kasar', 'seksual'],
      meanings: [
        (
          sourceIndex: 0,
          definition: 'ikan kecil',
          translation: 'ikan teri',
          translationLanguageId: null,
          wordClassId: null,
          meaningSource: 'manual',
          examples: [
            (source: 'Kalintiak di sungai', target: 'Ikan kecil di sungai', sourceIndex: 0),
            (source: 'Kalintiak goreng', target: 'Ikan goreng', sourceIndex: null),
            (source: '   ', target: 'diabaikan', sourceIndex: null),
          ],
        ),
        (
          sourceIndex: null,
          definition: '',
          translation: 'orang kecil',
          translationLanguageId: _idn,
          wordClassId: _nomina,
          meaningSource: 'manual',
          examples: const [],
        ),
        (
          sourceIndex: null,
          definition: 'tanpa kelas kata dibuang',
          translation: '',
          translationLanguageId: _idn,
          wordClassId: null,
          meaningSource: 'manual',
          examples: const [],
        ),
      ],
      relatedWords: [
        (wordId: 'W-NEW', relationType: 'antonym'),
        (wordId: 'W-NEW', relationType: 'antonym'),
      ],
      variants: ['klintiak', 'Kalinti', 'kalinti', ''],
      publish: true,
    );

    final meanings = body['meanings'] as List;
    expect(meanings, hasLength(2));

    final first = meanings[0] as Map<String, dynamic>;
    expect(first['order_index'], 0);
    expect(first['translations'], [
      {'language_id': _idn, 'translation_text': 'ikan teri', 'translation_type': 'direct'},
      {'language_id': _eng, 'translation_text': 'small fish', 'translation_type': 'idiomatic'},
    ]);
    expect(first['examples'], [
      {
        'source_language_id': _sbs,
        'source_sentence': 'Kalintiak di sungai',
        'target_language_id': _idn,
        'target_sentence': 'Ikan kecil di sungai',
        'source_type': 'folk',
      },
      {
        'source_language_id': _sbs,
        'source_sentence': 'Kalintiak goreng',
        'target_language_id': _idn,
        'target_sentence': 'Ikan goreng',
      },
    ]);

    final added = meanings[1] as Map<String, dynamic>;
    expect(added['order_index'], 1);
    expect(added['word_class_id'], _nomina);
    expect(added['definition'], '-');
    expect(added['is_have_definition'], isFalse);
    expect(added['is_have_translation'], isTrue);

    expect(body['related_words'], [
      {'word_id': 'W-NEW', 'relation_type': 'antonym'},
    ]);
    expect(body['variants'], [
      {'form': 'klintiak', 'variant_type': 'regional', 'dialect_id': 'D1'},
      {'form': 'Kalinti', 'variant_type': 'alternative'},
    ]);
    expect(body['images'], hasLength(1));
    expect(body['pronunciation'], {'notation': 'ipa', 'value': 'ka.lin.tiak'});
    expect(body['category_ids'], ['C1']);
    expect(body['usage_labels'], ['kasar', 'seksual']);
  });

  test('relasi dan variasi kosong tidak dikirim (server mengosongkan)', () {
    final body = buildWordCorrectBody(
      entity: _entity,
      lemma: 'kalintiak',
      notes: null,
      wordType: 'word',
      usageLabels: const [],
      meanings: const [],
      relatedWords: const [],
      variants: const [],
      publish: false,
    );
    expect(body.containsKey('related_words'), isFalse);
    expect(body.containsKey('variants'), isFalse);
    expect(body['publish'], isFalse);
    expect(body['usage_labels'], isEmpty);
  });
}
