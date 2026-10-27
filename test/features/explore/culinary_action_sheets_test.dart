import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/explore/presentation/culinary_labels.dart';
import 'package:sambasku_mobile/features/explore/presentation/widgets/culinary_action_sheets.dart';

const _cuisine = CulinaryEditTarget.cuisine(
  id: 'c1',
  name: 'Bubur Pedas',
  description: 'Bubur khas Sambas',
  ingredients: ['beras', 'santan'],
);

const _place = CulinaryEditTarget.place(
  id: 'p1',
  name: 'Warung Bubur',
  description: 'Warung pagi',
  addressText: 'Jl. Merdeka 10',
);

void main() {
  test('tanpa perubahan: fields kosong (server tolak EMPTY_CHANGE)', () {
    final d = culinaryEditDiff(
      target: _cuisine,
      name: 'Bubur Pedas',
      description: 'Bubur khas Sambas',
      ingredients: 'beras, santan',
    );
    expect(d.fields, isEmpty);
    expect(d.payload, isEmpty);
  });

  test('ubah nama saja: hanya name masuk payload dan fields', () {
    final d = culinaryEditDiff(
      target: _cuisine,
      name: 'Bubur Pedas Sambas',
      description: 'Bubur khas Sambas',
      ingredients: 'beras, santan',
    );
    expect(d.fields, ['name']);
    expect(d.payload, {'name': 'Bubur Pedas Sambas'});
  });

  test('bahan: spasi & urutan sama tidak dianggap berubah', () {
    final d = culinaryEditDiff(
      target: _cuisine,
      name: 'Bubur Pedas',
      description: 'Bubur khas Sambas',
      ingredients: '  beras ,santan  ',
    );
    expect(d.fields, isEmpty);
  });

  test('bahan diubah: dikirim sebagai list bersih', () {
    final d = culinaryEditDiff(
      target: _cuisine,
      name: 'Bubur Pedas',
      description: 'Bubur khas Sambas',
      ingredients: 'beras, santan, terubuk',
    );
    expect(d.fields, ['ingredients']);
    expect(d.payload['ingredients'], ['beras', 'santan', 'terubuk']);
  });

  test('tempat: alamat berubah, bahan diabaikan', () {
    final d = culinaryEditDiff(
      target: _place,
      name: 'Warung Bubur',
      description: 'Warung pagi',
      address: 'Jl. Merdeka 12',
      ingredients: 'apa saja',
    );
    expect(d.fields, ['addressText']);
    expect(d.payload, {'addressText': 'Jl. Merdeka 12'});
  });

  test('enam alasan laporan sesuai kode API', () {
    expect(culinaryReportReasons, [
      'closed',
      'wrong_location',
      'invalid_contact',
      'misleading',
      'duplicate',
      'abuse',
    ]);
  });
}
