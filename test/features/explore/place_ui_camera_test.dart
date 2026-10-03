import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sambasku_mobile/features/explore/domain/sambas_map_config.dart';
import 'package:sambasku_mobile/features/explore/presentation/place_ui.dart';

void main() {
  test('map camera survives JSON round-trip', () {
    const camera = CameraPosition(
      target: LatLng(1.3611, 109.3125),
      zoom: 15.25,
      bearing: 42,
      tilt: 30,
    );
    final decoded = decodeMapCamera(encodeMapCamera(camera));
    expect(decoded, isNotNull);
    expect(decoded!.target.latitude, closeTo(1.3611, 1e-9));
    expect(decoded.target.longitude, closeTo(109.3125, 1e-9));
    expect(decoded.zoom, 15.25);
    expect(decoded.bearing, 42);
    expect(decoded.tilt, 30);
  });

  test('broken or empty camera JSON falls back to null', () {
    expect(decodeMapCamera(null), isNull);
    expect(decodeMapCamera(''), isNull);
    expect(decodeMapCamera('bukan json'), isNull);
    expect(decodeMapCamera('{"zoom": 15}'), isNull);
  });

  test('missing optional fields default to fullscreen camera values', () {
    final decoded = decodeMapCamera('{"lat": -1.5, "lng": 110}');
    expect(decoded, isNotNull);
    expect(decoded!.zoom, SambasMapConfig.fullscreenZoom);
    expect(decoded.bearing, 0);
    expect(decoded.tilt, 0);
  });
}
