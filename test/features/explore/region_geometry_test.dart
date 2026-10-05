import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/explore/domain/region_geometry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('pointInRing: titik di dalam & di luar', () {
    // Segitiga kasar: (109,0) (110,0) (109.5,1)
    final ring = [
      [109.0, 0.0],
      [110.0, 0.0],
      [109.5, 1.0],
    ];
    expect(RegionGeometry.pointInRing(0.3, 109.5, ring), isTrue);
    expect(RegionGeometry.pointInRing(0.9, 109.1, ring), isFalse);
    expect(RegionGeometry.pointInRing(-1, 109.5, ring), isFalse);
  });

  test('geojson asset: 19 kecamatan, centroid masing-masing kena polygonnya', () async {
    final rings = await RegionGeometry.load();
    expect(rings, hasLength(19));

    // Centroid dari regions.json (generator sama) - tap di sana harus
    // mengenai kecamatan yang benar.
    final centroids = {
      'sambas': (1.34636, 109.31004),
      'pemangkat': (1.15042, 108.96997),
      'paloh': (1.85241, 109.45327),
      'tangaran': (1.54087, 109.16182),
    };
    for (final entry in centroids.entries) {
      final hit = RegionGeometry.hitTest(entry.value.$1, entry.value.$2, rings);
      expect(
        hit,
        entry.key,
        reason: 'centroid ${entry.key} harus kena polygonnya sendiri',
      );
    }

    // Titik jauh di luar Sambas -> null.
    expect(RegionGeometry.hitTest(-3.0, 118.0, rings), isNull);
  });
}
