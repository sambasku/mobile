import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Geometri polygon kecamatan: parse ring luar + hit test.
///
/// ponytail: ray casting manual, O(19 kecamatan x ring ~26 titik) per tap -
/// instan untuk skala ini. Upgrade path: queryRenderedFeatures bila polygon
/// makin kompleks.
class RegionGeometry {
  RegionGeometry._();

  /// Parse ring luar tiap feature: id -> list ring (Polygon/MultiPolygon).
  static Map<String, List<List<List<double>>>> ringsOf(
    Map<String, dynamic> geojson,
  ) {
    final out = <String, List<List<List<double>>>>{};
    final feats = geojson['features'];
    if (feats is! List) return out;
    for (final f in feats) {
      if (f is! Map || f['properties'] is! Map) continue;
      final id = (f['properties'] as Map)['id'];
      final g = f['geometry'];
      if (id is! String || g is! Map) continue;
      if (g['type'] == 'Polygon') {
        out[id] = [_outerRing(g['coordinates'] as List)];
      } else if (g['type'] == 'MultiPolygon') {
        out[id] = [
          for (final poly in g['coordinates'] as List) _outerRing(poly as List),
        ];
      }
    }
    return out;
  }

  static List<List<double>> _outerRing(List poly) => [
    for (final p in poly.first as List)
      [(p as List)[0] as double, p[1] as double],
  ];

  /// Point-in-polygon ray casting (koordinat: lat, lng; ring: [lng, lat]).
  static bool pointInRing(double lat, double lng, List<List<double>> ring) {
    var inside = false;
    for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      final xi = ring[i][0], yi = ring[i][1];
      final xj = ring[j][0], yj = ring[j][1];
      final intersect =
          ((yi > lat) != (yj > lat)) &&
          (lng < (xj - xi) * (lat - yi) / (yj - yi) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  /// Kecamatan id yang memuat titik; null di luar semua polygon.
  static String? hitTest(
    double lat,
    double lng,
    Map<String, List<List<List<double>>>> rings,
  ) {
    for (final entry in rings.entries) {
      for (final ring in entry.value) {
        if (pointInRing(lat, lng, ring)) return entry.key;
      }
    }
    return null;
  }

  /// Muat asset geojson + parse sekali.
  static Future<Map<String, List<List<List<double>>>>> load() async {
    final raw = await rootBundle.loadString('assets/data/regions.geojson');
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('regions.geojson bukan object');
    }
    return ringsOf(decoded);
  }
}
