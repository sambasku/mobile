import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/shared/widgets/image_crop_page.dart';

void main() {
  group('CropAspectRatio & Constants', () {
    test('kCropAspectRatios has 5 predefined ratios', () {
      expect(kCropAspectRatios.length, 5);
      expect(kCropAspectRatios[0].label, 'Bebas');
      expect(kCropAspectRatios[0].ratio, isNull);
      expect(kCropAspectRatios[1].label, '1:1');
      expect(kCropAspectRatios[1].ratio, 1.0);
      expect(kCropAspectRatios[2].label, '4:3');
      expect(kCropAspectRatios[2].ratio, 4 / 3);
      expect(kCropAspectRatios[3].label, '3:4');
      expect(kCropAspectRatios[3].ratio, 3 / 4);
      expect(kCropAspectRatios[4].label, '16:9');
      expect(kCropAspectRatios[4].ratio, 16 / 9);
    });
  });

  group('windowCropRect', () {
    test('returns full rect for identical aspect ratio at scale 1 without offset', () {
      final rect = windowCropRect(
        imageWidth: 1000,
        imageHeight: 1000,
        width: 300,
        height: 300,
        scale: 1.0,
        offset: Offset.zero,
      );
      expect(rect.left, 0.0);
      expect(rect.top, 0.0);
      expect(rect.width, 1000.0);
      expect(rect.height, 1000.0);
    });

    test('centers crop when window is narrower than image', () {
      final rect = windowCropRect(
        imageWidth: 2000,
        imageHeight: 1000,
        width: 300,
        height: 300, // 1:1 window over 2:1 image
        scale: 1.0,
        offset: Offset.zero,
      );
      // Height should be 1000, width should be 1000, left should be 500
      expect(rect.top, 0.0);
      expect(rect.height, 1000.0);
      expect(rect.width, 1000.0);
      expect(rect.left, 500.0);
    });

    test('crops correctly with zoom scale', () {
      final rect = windowCropRect(
        imageWidth: 1000,
        imageHeight: 1000,
        width: 300,
        height: 300,
        scale: 2.0,
        offset: Offset.zero,
      );
      // Zoom 2x means visible area is half
      expect(rect.width, 500.0);
      expect(rect.height, 500.0);
      expect(rect.left, 250.0);
      expect(rect.top, 250.0);
    });
  });

  group('cropOutputSize', () {
    test('keeps original size if smaller than max', () {
      const src = Rect.fromLTWH(0, 0, 500, 400);
      final size = cropOutputSize(src, maxSide: 1000);
      expect(size.width, 500);
      expect(size.height, 400);
    });

    test('downscales proportionally if exceeding maxSide', () {
      const src = Rect.fromLTWH(0, 0, 2000, 1000);
      final size = cropOutputSize(src, maxSide: 1000);
      expect(size.width, 1000);
      expect(size.height, 500);
    });
  });

  group('clampWindowOffset', () {
    test('clamps offset to 0 when scale is 1 and aspect matches', () {
      final clamped = clampWindowOffset(
        imageWidth: 1000,
        imageHeight: 1000,
        width: 300,
        height: 300,
        scale: 1.0,
        offset: const Offset(50, 50),
      );
      expect(clamped, Offset.zero);
    });

    test('allows movement within overflow range on zoom', () {
      final clamped = clampWindowOffset(
        imageWidth: 1000,
        imageHeight: 1000,
        width: 300,
        height: 300,
        scale: 2.0,
        offset: const Offset(100, 100),
      );
      // total width = 600, overflow = 300, half = 150
      expect(clamped.dx, 100.0);
      expect(clamped.dy, 100.0);
    });
  });

  group('free crop helpers', () {
    test('containImageRect letterboxes landscape in tall avail', () {
      final r = containImageRect(
        imageWidth: 2000,
        imageHeight: 1000,
        avail: const Size(400, 800),
      );
      expect(r.width, 400);
      expect(r.height, 200);
      expect(r.top, 300);
    });

    test('clampFreeNorm enforces min size and bounds', () {
      final tiny = clampFreeNorm(const Rect.fromLTWH(0.9, 0.9, 0.01, 0.01));
      expect(tiny.width, greaterThanOrEqualTo(0.12));
      expect(tiny.height, greaterThanOrEqualTo(0.12));
      expect(tiny.right, lessThanOrEqualTo(1.0));
      expect(tiny.bottom, lessThanOrEqualTo(1.0));
    });

    test('freeCropToSource maps display crop to image pixels', () {
      const display = Rect.fromLTWH(10, 20, 200, 100);
      const crop = Rect.fromLTWH(60, 45, 100, 50); // half of display, centered-ish
      final src = freeCropToSource(
        cropDisplay: crop,
        imageDisplay: display,
        imageWidth: 2000,
        imageHeight: 1000,
      );
      expect(src.left, 500);
      expect(src.top, 250);
      expect(src.width, 1000);
      expect(src.height, 500);
    });

    test('freeCropToDisplay round-trips with freeCropToSource for full frame', () {
      const display = Rect.fromLTWH(0, 0, 300, 150);
      const norm = Rect.fromLTWH(0, 0, 1, 1);
      final crop = freeCropToDisplay(norm, display);
      final src = freeCropToSource(
        cropDisplay: crop,
        imageDisplay: display,
        imageWidth: 900,
        imageHeight: 450,
      );
      expect(src.left, 0);
      expect(src.top, 0);
      expect(src.width, 900);
      expect(src.height, 450);
    });
  });
}
