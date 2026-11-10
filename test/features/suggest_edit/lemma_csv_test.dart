import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/suggest_edit/presentation/widgets/lemma_csv.dart';

void main() {
  group('parseLemmaCsv', () {
    test('pecah dan trim', () {
      expect(parseLemmaCsv('a, b , ,c'), ['a', 'b', 'c']);
      expect(parseLemmaCsv(''), isEmpty);
      expect(parseLemmaCsv('  '), isEmpty);
    });
  });

  group('appendLemmaCsv', () {
    test('tambah lemma baru dengan trailing koma', () {
      expect(appendLemmaCsv('', 'makatn'), 'makatn, ');
      expect(appendLemmaCsv('a, ', 'b'), 'a, b, ');
    });

    test('dedupe case-insensitive', () {
      expect(appendLemmaCsv('Makatn, ', 'makatn'), 'Makatn, ');
    });
  });

  group('removeLemmaCsv', () {
    test('hapus case-insensitive', () {
      expect(removeLemmaCsv('a, b, c, ', 'B'), 'a, c, ');
      expect(removeLemmaCsv('solo, ', 'solo'), '');
    });
  });
}
