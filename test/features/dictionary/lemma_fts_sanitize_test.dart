import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/dictionary/data/dataset/lemma_fts_sanitize.dart';

void main() {
  test('sanitize strips quotes and operators', () {
    final q = sanitizeFtsMatchQuery('kong" * ^:');
    expect(q.contains('"'), isTrue);
    expect(q.contains('*'), isTrue); // prefix marker kita sendiri
    expect(q.contains('^'), isFalse);
    expect(q, contains('kong'));
  });

  test('empty after sanitize', () {
    expect(sanitizeFtsMatchQuery('"""'), '');
    expect(sanitizeFtsMatchQuery('   '), '');
  });

  test('limits tokens', () {
    final q = sanitizeFtsMatchQuery('a b c d e f g h i j k');
    final parts = q.split(' ');
    expect(parts.length, lessThanOrEqualTo(8));
  });
}
