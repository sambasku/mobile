import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Kamera & style default untuk peta fokus Kabupaten Sambas.
abstract final class SambasMapConfig {
  /// Pusat Kabupaten Sambas (sekitar pusat kota Sambas).
  static const LatLng center = LatLng(1.361, 109.309);

  /// Zoom hub: cukup lebar untuk “sense of place”, belum street-level.
  static const double heroZoom = 10.2;

  /// Zoom layar penuh: sedikit lebih dekat untuk dijelajahi.
  static const double fullscreenZoom = 11.0;

  /// Zoom saat fokus satu Place (dari detail "Lihat di peta"): level jalan.
  /// Tempat di kompleks keraton cuma berjarak sekitar 90 m; di bawah 16 pin
  /// tetangga jatuh di bawah label.
  static const double placeZoom = 16.5;

  static const CameraPosition heroCamera = CameraPosition(
    target: center,
    zoom: heroZoom,
  );

  static const CameraPosition fullscreenCamera = CameraPosition(
    target: center,
    zoom: fullscreenZoom,
  );

  /// OpenFreeMap Liberty (terang) / Dark (gelap) - gratis, tanpa API key.
  static const String styleUrlLight =
      'https://tiles.openfreemap.org/styles/liberty';
  static const String styleUrlDark =
      'https://tiles.openfreemap.org/styles/dark';

  static String styleUrlFor(Brightness brightness) =>
      brightness == Brightness.dark ? styleUrlDark : styleUrlLight;
}
