import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../core/constants/env.dart';
import '../../../l10n/app_localizations.dart';
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
/// #130: link presisi (mapsUrl) menang; fallback koordinat lat,lng.
/// Tanpa keduanya: null - tombol maps disembunyikan (canOpenMaps false).
Uri? placeGoogleMapsUri(Place place) {
  if (place.mapsUrl != null) {
    final uri = Uri.tryParse(place.mapsUrl!);
    if (uri != null && uri.isScheme('https')) return uri;
  }
  if (place.hasCoordinates) {
    return Uri.https(
      'www.google.com',
      '/maps/search/',
      {'api': '1', 'query': '${place.lat},${place.lng}'},
    );
  }
  return null;
}

/// Toast info tempat tanpa koordinat (belum bisa dipetakan).
void showPlaceNoCoordinates(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  showFToast(
    context: context,
    title: Text(l10n.placeNoCoordinatesTitle),
    description: Text(l10n.placeNoCoordinatesBody),
  );
}

/// Label tipe wisata; null bila tipe tidak dikenal.
String? placeTypeLabel(AppLocalizations l10n, PlaceType? type) =>
    switch (type) {
      PlaceType.sejarah => l10n.placeTypeSejarah,
      PlaceType.alam => l10n.placeTypeAlam,
      PlaceType.budaya => l10n.placeTypeBudaya,
      PlaceType.pantai => l10n.placeTypePantai,
      PlaceType.belanja => l10n.placeTypeBelanja,
      null => null,
    };

/// Label kategori Place (badge atas di detail).
String placeCategoryLabel(AppLocalizations l10n, PlaceCategory category) =>
    switch (category) {
      PlaceCategory.kuliner => l10n.placeCategoryKuliner,
      PlaceCategory.budaya => l10n.placeTypeBudaya,
      PlaceCategory.wisata => l10n.placeTypeWisata,
    };

/// Label singkat untuk list/kartu: type wisata, atau kategori.
String placeLabel(AppLocalizations l10n, Place place) =>
    switch (place.category) {
      PlaceCategory.kuliner => l10n.placeCategoryKuliner,
      PlaceCategory.budaya => l10n.placeTypeBudaya,
      PlaceCategory.wisata =>
        placeTypeLabel(l10n, place.type) ?? l10n.placeTypeWisata,
    };

void showPlaceBookmarkSoon(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  showFToast(
    context: context,
    title: Text(l10n.placeBookmarkSoonTitle),
    description: Text(l10n.placeBookmarkSoonBody),
  );
}
