import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/explore/data/models/regions_dto.dart';
import 'package:sambasku_mobile/features/explore/domain/entities/region.dart'
    show RegionType;

void main() {
  test('parse kecamatan lengkap', () {
    final dto = RegionDto.fromJson({
      'id': 'tangaran',
      'name': 'Tangaran',
      'type': 'kecamatan',
      'lat': 1.57,
      'lng': 109.14,
    });
    expect(dto, isNotNull);
    expect(dto!.type, RegionType.kecamatan);
    expect(dto.parentId, isNull);
  });

  test('parse desa dengan parentId', () {
    final dto = RegionDto.fromJson({
      'id': 'sambas/semeto',
      'name': 'Semeto',
      'type': 'desa',
      'parentId': 'sambas',
    });
    expect(dto, isNotNull);
    expect(dto!.type, RegionType.desa);
    expect(dto.parentId, 'sambas');
  });

  test('field wajib absen - null (skip item)', () {
    expect(RegionDto.fromJson({'name': 'tanpa id'}), isNull);
    expect(RegionDto.fromJson({'id': 'x'}), isNull);
    expect(RegionDto.fromJson({'id': 'x', 'name': 'y'}), isNull);
    expect(RegionDto.fromJson({'id': 'x', 'name': 'y', 'type': 'kota'}), isNull);
  });

  test('wrapper: entri rusak di-skip, yang valid tetap masuk', () {
    final list = RegionsDto.fromJson({
      'version': 1,
      'regions': [
        {'id': 'sambas', 'name': 'Sambas', 'type': 'kecamatan', 'lat': 1, 'lng': 109},
        {'name': 'rusak'},
        {'id': 'jawai', 'name': 'Jawai', 'type': 'kecamatan', 'lat': 1, 'lng': 109},
      ],
    });
    expect(list, isNotNull);
    expect(list!.regions, hasLength(2));
  });

  test('body bukan object - null', () {
    expect(RegionsDto.fromJson(null), isNull);
  });

  test('slug id', () {
    expect(regionSlug('Teluk Keramat'), 'teluk-keramat');
  });
}
