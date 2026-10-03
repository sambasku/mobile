import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/suggest_edit/presentation/widgets/word_change_history_section.dart';

void main() {
  group('isTechnicalChangeField', () {
    test('returns true for fields ending with _id', () {
      expect(isTechnicalChangeField('contribution_id'), isTrue);
      expect(isTechnicalChangeField('reopened_by'), isTrue);
      expect(isTechnicalChangeField('language_id'), isTrue);
      expect(isTechnicalChangeField('source_word_id'), isTrue);
      expect(isTechnicalChangeField('split_from_word_id'), isTrue);
      expect(isTechnicalChangeField('word_id'), isTrue);
      expect(isTechnicalChangeField('meaning_id'), isTrue);
    });

    test('returns true for fields ending with _ids', () {
      expect(isTechnicalChangeField('meaning_ids'), isTrue);
      expect(isTechnicalChangeField('merged_word_ids'), isTrue);
    });

    test('returns true for fields ending with _by', () {
      expect(isTechnicalChangeField('reopened_by'), isTrue);
    });

    test('returns true for bookkeeping fields', () {
      expect(isTechnicalChangeField('comma_split'), isTrue);
      expect(isTechnicalChangeField('created'), isTrue);
      expect(isTechnicalChangeField('merged_on_create'), isTrue);
      expect(isTechnicalChangeField('merged_on_update'), isTrue);
      expect(isTechnicalChangeField('self_applied'), isTrue);
    });

    test('returns false for user-facing fields', () {
      expect(isTechnicalChangeField('lemma'), isFalse);
      expect(isTechnicalChangeField('notes'), isFalse);
      expect(isTechnicalChangeField('definition'), isFalse);
      expect(isTechnicalChangeField('translation_text'), isFalse);
      expect(isTechnicalChangeField('status'), isFalse);
      expect(isTechnicalChangeField('comment'), isFalse);
      expect(isTechnicalChangeField('reason_code'), isFalse);
      expect(isTechnicalChangeField('is_verified'), isFalse);
      expect(isTechnicalChangeField('is_corrected'), isFalse);
      expect(isTechnicalChangeField('relations'), isFalse);
      expect(isTechnicalChangeField('variants'), isFalse);
      expect(isTechnicalChangeField('images'), isFalse);
      expect(isTechnicalChangeField('word_type'), isFalse);
    });

    test('case insensitive', () {
      expect(isTechnicalChangeField('CONTRIBUTION_ID'), isTrue);
      expect(isTechnicalChangeField('Lemma'), isFalse);
    });
  });

  group('friendlyChangeValue', () {
    test('returns null for empty string', () {
      expect(friendlyChangeValue(''), isNull);
      expect(friendlyChangeValue('   '), isNull);
    });

    test('returns null for ULID (26 char Crockford base32)', () {
      const ulid = '01ARZ3NDEKTSV4RRFFQ69G5FAV';
      expect(friendlyChangeValue(ulid), isNull);
      // lowercase also matches
      expect(friendlyChangeValue(ulid.toLowerCase()), isNull);
    });

    test('returns null for JSON object without added/removed/set_primary', () {
      const json = '{"status":"published","reason_code":"spam"}';
      expect(friendlyChangeValue(json), isNull);
      expect(friendlyChangeValue('{"foo":"bar"}'), isNull);
    });

    test('summarizes JSON with added/removed', () {
      expect(
        friendlyChangeValue('{"added":[{"id":"1"}],"removed":[]}'),
        'Ditambah 1',
      );
      expect(
        friendlyChangeValue('{"added":[],"removed":[{"id":"1"},{"id":"2"}]}'),
        'Dihapus 2',
      );
      expect(
        friendlyChangeValue('{"added":[1],"removed":[1],"set_primary":[1]}'),
        'Ditambah 1, Dihapus 1, Dijadikan utama 1',
      );
    });

    test('returns original string for non-JSON, non-ULID values', () {
      expect(friendlyChangeValue('kata baru'), 'kata baru');
      expect(friendlyChangeValue('Sebelum: lama'), 'Sebelum: lama');
      expect(friendlyChangeValue('-'), '-');
      expect(friendlyChangeValue('some text'), 'some text');
    });

    test('returns null for JSON array', () {
      expect(friendlyChangeValue('[1,2,3]'), isNull);
    });

    test('returns null for JSON boolean/number primitives', () {
      expect(friendlyChangeValue('true'), isNull);
      expect(friendlyChangeValue('false'), isNull);
      expect(friendlyChangeValue('123'), isNull);
      expect(friendlyChangeValue('0'), isNull);
    });

    test('handles invalid JSON gracefully', () {
      expect(friendlyChangeValue('{not json}'), '{not json}');
      expect(friendlyChangeValue('just text'), 'just text');
    });
  });
}