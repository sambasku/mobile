import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/suggest_edit/domain/meaning_edit_order.dart';

void main() {
  const meanings = ['utama', 'mukol', 'lain'];

  test('makna kartu di depan, sisanya urutan asli', () {
    expect(meaningsPreferredFirst(meanings, 'mukol', idOf: (m) => m), [
      'mukol',
      'utama',
      'lain',
    ]);
  });

  test('id kosong atau asing mempertahankan urutan asli', () {
    expect(meaningsPreferredFirst(meanings, null, idOf: (m) => m), meanings);
    expect(meaningsPreferredFirst(meanings, '  ', idOf: (m) => m), meanings);
    expect(
      meaningsPreferredFirst(meanings, 'tidak-ada', idOf: (m) => m),
      meanings,
    );
  });

  test('makna yang sudah di depan tidak diacak ulang', () {
    expect(meaningsPreferredFirst(meanings, 'utama', idOf: (m) => m), meanings);
  });
}
