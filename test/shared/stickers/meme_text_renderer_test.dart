import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/shared/stickers/meme_text_renderer.dart';

Future<File> _writeSquareBase(Directory dir) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawRect(
    const ui.Rect.fromLTWH(0, 0, 100, 100),
    ui.Paint()..color = const ui.Color(0xFF336699),
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(100, 100);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File('${dir.path}/base.png');
  await file.writeAsBytes(data!.buffer.asUint8List());
  return file;
}

void main() {
  // flutter_test memakai font Ahem (blok) secara default. Muat Anton supaya
  // pengukuran dan hasil render memakai font yang sama dengan aplikasi.
  setUpAll(() async {
    final bytes = File('assets/fonts/Anton-Regular.ttf').readAsBytesSync();
    await ui.loadFontFromList(bytes, fontFamily: kMemeFontFamily);
  });

  group('fitMemeFontSize', () {
    test('teks pendek memakai ukuran maksimal yang muat', () {
      final size = fitMemeFontSize(
        text: 'OK',
        maxWidth: 488,
        maxHeight: 244,
      );
      expect(size, greaterThan(40));
      expect(size, lessThanOrEqualTo(120));
    });

    test('teks panjang menghasilkan ukuran lebih kecil', () {
      final short = fitMemeFontSize(
        text: 'HAI',
        maxWidth: 488,
        maxHeight: 244,
      );
      final long = fitMemeFontSize(
        text: 'KAMU SUDAH MAKAN SIANG BELUM HARI INI',
        maxWidth: 488,
        maxHeight: 244,
      );
      expect(long, lessThan(short));
    });

    test('tidak pernah turun di bawah ukuran minimum', () {
      final size = fitMemeFontSize(
        text: 'SANGAT SANGAT PANJANG ' * 40,
        maxWidth: 488,
        maxHeight: 244,
      );
      expect(size, 18);
    });
  });

  group('renderMemeImage', () {
    testWidgets('menghasilkan PNG 512x512 dengan dan tanpa teks', (tester) async {
      await tester.runAsync(() async {
        final dir = Directory.systemTemp.createTempSync('meme_render_test');
        addTearDown(() => dir.deleteSync(recursive: true));

        final base = await _writeSquareBase(dir);
        final out = await renderMemeImage(
          baseFile: base,
          topText: 'atas',
          bottomText: 'bawah',
          outFile: File('${dir.path}/out_text.png'),
        );
        final noText = await renderMemeImage(
          baseFile: base,
          topText: '  ',
          bottomText: '',
          outFile: File('${dir.path}/out_empty.png'),
        );

        for (final file in [out, noText]) {
          final codec = await ui.instantiateImageCodec(await file.readAsBytes());
          final frame = await codec.getNextFrame();
          expect(frame.image.width, 512);
          expect(frame.image.height, 512);
          frame.image.dispose();
          codec.dispose();
        }
      });
    });
    testWidgets('warna teks dan border pilihan user ikut dirender', (tester) async {
      await tester.runAsync(() async {
        final dir = Directory.systemTemp.createTempSync('meme_color_test');
        addTearDown(() => dir.deleteSync(recursive: true));

        // Base 0x336699 (b=153) tidak lolos ambang biru di bawah.
        final base = await _writeSquareBase(dir);
        final out = await renderMemeImage(
          baseFile: base,
          topText: 'MEME',
          bottomText: '',
          outFile: File('${dir.path}/out_color.png'),
          textColor: MemeColor.red,
          borderColor: MemeColor.blue,
        );

        final codec = await ui.instantiateImageCodec(await out.readAsBytes());
        final frame = await codec.getNextFrame();
        final rgba = (await frame.image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!
            .buffer
            .asUint8List();
        frame.image.dispose();
        codec.dispose();

        var redPixels = 0;
        var bluePixels = 0;
        for (var i = 0; i < rgba.length; i += 4) {
          final r = rgba[i];
          final g = rgba[i + 1];
          final b = rgba[i + 2];
          if (r > 200 && g < 80 && b < 80) redPixels++;
          if (b > 200 && r < 80 && g < 160) bluePixels++;
        }
        expect(redPixels, greaterThan(0));
        expect(bluePixels, greaterThan(0));
      });
    });
  });
}
