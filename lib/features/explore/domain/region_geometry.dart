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

  /// Ring luar per id desa, difilter satu kecamatan (ADM4 punya parentId).
  /// Parse sekali dari geojson hasil cache caller - dipakai load & sync.
  static Map<String, List<List<List<double>>>> ringsFor(
    Map<String, dynamic> geojson,
    String kecSlug,
  ) {
    final out = <String, List<List<List<double>>>>{};
    final feats = geojson['features'];
    if (feats is! List) return out;
    for (final f in feats) {
      if (f is! Map || f['properties'] is! Map) continue;
      final props = f['properties'] as Map;
      if (props['parentId'] != kecSlug) continue;
      final id = props['id'];
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

  /// Bersihkan FeatureCollection agar sesuai RFC 7946 (khususnya iOS
  /// MapLibre `MLNShape` yang menolak linear ring dengan < 4 titik).
  static Map<String, dynamic> sanitizeFeatureCollection(
    Map<String, dynamic> geojson,
  ) {
    final feats = geojson['features'];
    if (feats is! List) return geojson;
    final cleanFeatures = <Map<String, dynamic>>[];
    for (final f in feats) {
      if (f is! Map) continue;
      final g = f['geometry'];
      if (g is! Map) continue;
      final type = g['type'];
      final coords = g['coordinates'];
      if (type == 'Polygon' && coords is List) {
        final rings = _sanitizePolygonRings(coords);
        if (rings.isEmpty) continue;
        cleanFeatures.add({
          ...Map<String, dynamic>.from(f),
          'geometry': {'type': 'Polygon', 'coordinates': rings},
        });
      } else if (type == 'MultiPolygon' && coords is List) {
        final polys = <List<List<List<double>>>>[];
        for (final poly in coords) {
          if (poly is! List) continue;
          final rings = _sanitizePolygonRings(poly);
          if (rings.isNotEmpty) polys.add(rings);
        }
        if (polys.isEmpty) continue;
        cleanFeatures.add({
          ...Map<String, dynamic>.from(f),
          'geometry': {'type': 'MultiPolygon', 'coordinates': polys},
        });
      } else {
        cleanFeatures.add(Map<String, dynamic>.from(f));
      }
    }
    return {
      ...geojson,
      'type': 'FeatureCollection',
      'features': cleanFeatures,
    };
  }

  static List<List<List<double>>> _sanitizePolygonRings(List rawRings) {
    final out = <List<List<double>>>[];
    for (final rawRing in rawRings) {
      if (rawRing is! List) continue;
      final pts = <List<double>>[
        for (final p in rawRing)
          if (p is List && p.length >= 2 && p[0] is num && p[1] is num)
            [(p[0] as num).toDouble(), (p[1] as num).toDouble()],
      ];
      if (pts.length < 3) continue;
      final first = pts.first;
      final last = pts.last;
      if (first[0] != last[0] || first[1] != last[1]) {
        pts.add([first[0], first[1]]);
      }
      // RFC 7946: linear ring wajib minimal 4 posisi (3 titik unik + penutup).
      if (pts.length < 4) continue;
      out.add(pts);
    }
    return out;
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
