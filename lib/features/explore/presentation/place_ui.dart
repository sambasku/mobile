import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../core/constants/env.dart';
import '../domain/sambas_map_config.dart';
import '../domain/entities/place.dart';

/// URL publik HTTPS detail tempat (share + App Link). Web punya halaman
/// fallback di path yang sama untuk yang belum memasang aplikasi.
String? placePublicUrl(String slug) {
  final base = Env.webAppUrl;
  if (base == null || base.isEmpty) return null;
  final trimmed = base.endsWith('/')
      ? base.substring(0, base.length - 1)
      : base;
  return '$trimmed/wisata/${Uri.encodeComponent(slug)}';
}

/// Key SharedPreferences posisi kamera terakhir halaman peta Place.
/// Dipulihkan setelah app dibunuh sistem; restore best-effort (tersimpan
/// dengan debounce 500 ms).
const pinsCameraPrefKey = 'explore.pins.camera';

String encodeMapCamera(CameraPosition c) => jsonEncode({
  'lat': c.target.latitude,
  'lng': c.target.longitude,
  'zoom': c.zoom,
  'bearing': c.bearing,
  'tilt': c.tilt,
});

/// JSON rusak / field hilang -> null (pakai kamera default).
CameraPosition? decodeMapCamera(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    final m = jsonDecode(raw);
    if (m is! Map) return null;
    final lat = (m['lat'] as num?)?.toDouble();
    final lng = (m['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    return CameraPosition(
      target: LatLng(lat, lng),
      zoom: (m['zoom'] as num?)?.toDouble() ?? SambasMapConfig.fullscreenZoom,
      bearing: (m['bearing'] as num?)?.toDouble() ?? 0,
      tilt: (m['tilt'] as num?)?.toDouble() ?? 0,
    );
  } catch (_) {
    return null;
  }
}

/// Titik tempat di Google Maps; rute dan navigasi diurus aplikasi Maps.
Uri placeGoogleMapsUri(Place place) => Uri.https(
  'www.google.com',
  '/maps/search/',
  {'api': '1', 'query': '${place.lat},${place.lng}'},
);

const placeTypeLabels = {
  PlaceType.sejarah: 'Sejarah',
  PlaceType.alam: 'Alam',
  PlaceType.budaya: 'Budaya',
  PlaceType.pantai: 'Pantai',
  PlaceType.belanja: 'Belanja',
};

/// Label singkat untuk list/kartu: type wisata, atau "Kuliner"/"Wisata".
String placeLabel(Place place) => place.category == PlaceCategory.kuliner
    ? 'Kuliner'
    : placeTypeLabels[place.type] ?? 'Wisata';

void showPlaceBookmarkSoon(BuildContext context) => showFToast(
  context: context,
  title: const Text('Bookmark tempat belum bisa dipakai'),
  description: const Text('Kami sedang berusaha membuatnya jadi lebih baik.'),
);
