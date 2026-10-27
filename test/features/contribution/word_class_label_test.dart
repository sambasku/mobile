import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/contribution/presentation/widgets/word_class_picker_sheet.dart';
import 'package:sambasku_mobile/shared/reference/reference_data.dart';

/// Copy kelas kata harus seragam di chip deck dan picker: `umum` selalu
/// tampil "Umum", bukan alias seed "Belum Diketahui".
void main() {
  test('ReferenceItem.displayLabel: umum pakai name, lain pakai alias', () {
    const umum = ReferenceItem(
      id: 'a',
      name: 'Umum',
      code: 'umum',
      alias: 'Belum Diketahui',
    );
    const nomina = ReferenceItem(
      id: 'b',
      name: 'Nomina',
      code: 'n',
      alias: 'Kata Benda',
    );

    expect(umum.displayLabel, 'Umum');
    expect(nomina.displayLabel, 'Nomina (Kata Benda)');
  });

  test('displayLabel: code umum kapital tetap name', () {
    const item = ReferenceItem(
      id: 'c',
      name: 'Umum',
      code: 'Umum',
      alias: 'Belum Diketahui',
    );
    expect(item.displayLabel, 'Umum');
  });

  test('WordClassPickItem.displayLabel: umum pakai name', () {
    const umum = WordClassPickItem(
      id: 'a',
      name: 'Umum',
      code: 'umum',
      alias: 'Belum Diketahui',
    );
    const verba = WordClassPickItem(
      id: 'b',
      name: 'Verba',
      code: 'v',
      alias: 'Kata Kerja',
    );

    expect(umum.displayLabel, 'Umum');
    expect(verba.displayLabel, 'Verba (Kata Kerja)');
  });
}
