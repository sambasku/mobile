import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/vote/data/repositories/vote_repository_impl.dart';

/// Parser kartu deck 0101 + kelas kata per makna (`word_class`).
void main() {
  Map<String, dynamic> card({Object? wordClass = _ignored}) => {
        'id': '01MEANING0000000000000000A',
        'word_id': '01WORD0000000000000000000A',
        'lemma': 'pigar',
        'language_id': '01LANG',
        'language_code': 'sbs',
        'word_type': 'word',
        'status': 'published',
        'is_verified': false,
        'approved_at': '2026-09-01T00:00:00.000Z',
        'sense': 'sesuatu yang dipigar',
        'order_index': 2,
        'meaning_count': 3,
        if (wordClass != _ignored) 'word_class': wordClass,
      };

  test('word_class terisi → entity membawa kelas + label alias', () {
    final item = parseVoteDeckItem(
      card(
        wordClass: {
          'id': '01WCNOMINA000000000000000',
          'code': 'n',
          'name': 'Nomina',
          'alias': 'Kata Benda',
        },
      ),
    );

    expect(item.wordClass?.code, 'n');
    expect(item.wordClassLabel, 'Kata Benda');
    expect(item.orderIndex, 2);
    expect(item.meaningCount, 3);
  });

  test('word_class null / tidak dikirim → tanpa kelas, label kosong', () {
    expect(parseVoteDeckItem(card(wordClass: null)).wordClass, isNull);
    expect(parseVoteDeckItem(card()).wordClass, isNull);
    expect(parseVoteDeckItem(card()).wordClassLabel, '');
  });

  test('word_class tanpa id dianggap tidak ada (wire rusak)', () {
    final item = parseVoteDeckItem(
      card(wordClass: {'code': 'n', 'name': 'Nomina'}),
    );
    expect(item.wordClass, isNull);
  });

  test('code umum kapital tetap dianggap Umum (bukan alias)', () {
    final item = parseVoteDeckItem(
      card(
        wordClass: {
          'id': '01WCUMUM0000000000000000',
          'code': 'Umum',
          'name': 'Umum',
          'alias': 'Belum Diketahui',
        },
      ),
    );
    expect(item.wordClassLabel, 'Umum');
  });

  test('alias kosong → fallback nama kelas; code umum → nama kelas', () {
    final noAlias = parseVoteDeckItem(
      card(
        wordClass: {
          'id': '01WCNOMINA000000000000000',
          'code': 'n',
          'name': 'Nomina',
          'alias': '  ',
        },
      ),
    );
    expect(noAlias.wordClassLabel, 'Nomina');

    final umum = parseVoteDeckItem(
      card(
        wordClass: {
          'id': '01WCUMUM0000000000000000',
          'code': 'umum',
          'name': 'Umum',
          'alias': 'Belum Diketahui',
        },
      ),
    );
    expect(umum.wordClassLabel, 'Umum');
  });
}

/// Sentinel: bedakan "field tidak dikirim" dari "field bernilai null".
const _ignored = Object();
