import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
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

  group('ringsFor (adm4 per kecamatan)', () {
    Map<String, dynamic> adm4() => {
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'properties': {'id': 'desa-a', 'parentId': 'kec-a'},
          'geometry': {
            'type': 'Polygon',
            'coordinates': [
              [
                [109.0, 1.0],
                [109.1, 1.0],
                [109.1, 1.1],
                [109.0, 1.0],
              ],
            ],
          },
        },
        {
          'type': 'Feature',
          'properties': {'id': 'desa-b', 'parentId': 'kec-a'},
          'geometry': {
            'type': 'MultiPolygon',
            'coordinates': [
              [
                [
                  [109.2, 1.0],
                  [109.3, 1.0],
                  [109.3, 1.1],
                  [109.2, 1.0],
                ],
              ],
              [
                [
                  [109.4, 1.0],
                  [109.5, 1.0],
                  [109.5, 1.1],
                  [109.4, 1.0],
                ],
              ],
            ],
          },
        },
        {
          'type': 'Feature',
          'properties': {'id': 'desa-x', 'parentId': 'kec-b'},
          'geometry': {
            'type': 'Polygon',
            'coordinates': [
              [
                [108.0, 2.0],
                [108.1, 2.0],
                [108.1, 2.1],
                [108.0, 2.0],
              ],
            ],
          },
        },
      ],
    };

    test('hanya ring milik kecamatan diminta (Polygon + MultiPolygon)', () {
      final rings = RegionGeometry.ringsFor(adm4(), 'kec-a');
      expect(rings.keys, unorderedEquals(['desa-a', 'desa-b']));
      expect(rings['desa-a'], hasLength(1));
      expect(rings['desa-b'], hasLength(2), reason: 'MultiPolygon = 2 ring');
      // Koordinat ring luar desa-a lolos parse (lng, lat).
      expect(rings['desa-a']!.first.first, [109.0, 1.0]);
    });

    test('kecamatan tanpa fitur -> map kosong (bukan throw)', () {
      expect(RegionGeometry.ringsFor(adm4(), 'kec-z'), isEmpty);
    });

    test('features tidak valid dilewati tanpa gagal total', () {
      final bad = {
        'type': 'FeatureCollection',
        'features': [
          {'geometry': null},
          {
            'type': 'Feature',
            'properties': {'id': 1, 'parentId': 'kec-a'},
          },
          null,
        ],
      };
      expect(RegionGeometry.ringsFor(bad, 'kec-a'), isEmpty);
    });
  });

  group('RFC 7946 GeoJSON validity (iOS MLNShape)', () {
    test('asset regions.geojson & regions-adm4.geojson bebas ring < 4 titik', () async {
      for (final asset in [
        'assets/data/regions.geojson',
        'assets/data/regions-adm4.geojson',
      ]) {
        final raw = await rootBundle.loadString(asset);
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final feats = decoded['features'] as List;
        for (final f in feats) {
          final g = (f as Map)['geometry'] as Map;
          final type = g['type'] as String;
          final polys = type == 'Polygon'
              ? [g['coordinates'] as List]
              : (g['coordinates'] as List);
          for (final poly in polys) {
            for (final ring in poly as List) {
              final r = ring as List;
              expect(
                r.length,
                greaterThanOrEqualTo(4),
                reason: '$asset punya ring < 4 titik (ditolak MLNShape iOS)',
              );
              expect(r.first, equals(r.last), reason: '$asset ring tidak tertutup');
            }
          }
        }
      }
    });

    test('sanitizeFeatureCollection membuang ring degenerat < 4 titik', () {
      final dirty = {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'properties': {'id': 'pemangkat'},
            'geometry': {
              'type': 'Polygon',
              'coordinates': [
                [
                  [109.0, 1.0],
                  [109.1, 1.0],
                  [109.1, 1.1],
                  [109.0, 1.0],
                ],
                [
                  [108.97, 1.18],
                  [108.97, 1.19],
                  [108.97, 1.18],
                ],
              ],
            },
          },
          {
            'type': 'Feature',
            'properties': {'id': 'jawai-selatan'},
            'geometry': {
              'type': 'MultiPolygon',
              'coordinates': [
                [
                  [
                    [109.0, 1.0],
                    [109.1, 1.0],
                    [109.1, 1.1],
                    [109.0, 1.0],
                  ],
                ],
                [
                  [
                    [108.97, 1.18],
                    [108.97, 1.19],
                    [108.97, 1.18],
                  ],
                ],
              ],
            },
          },
        ],
      };

      final clean = RegionGeometry.sanitizeFeatureCollection(dirty);
      final feats = clean['features'] as List;
      expect(feats, hasLength(2));
      expect((feats[0]['geometry']['coordinates'] as List), hasLength(1));
      expect((feats[1]['geometry']['coordinates'] as List), hasLength(1));
    });
  });
}
