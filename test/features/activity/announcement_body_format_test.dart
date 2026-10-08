import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/activity/presentation/pages/announcement_body_format.dart';

void main() {
  group('detectAnnouncementBodyFormat', () {
    test('html: tag block-level di awal', () {
      expect(
        detectAnnouncementBodyFormat('<p>Halo <b>dunia</b></p>'),
        AnnouncementBodyFormat.html,
      );
      expect(
        detectAnnouncementBodyFormat('<div>x</div>'),
        AnnouncementBodyFormat.html,
      );
    });

    test('html: lebih dari satu tag inline (bukan prose biasa)', () {
      expect(
        detectAnnouncementBodyFormat('Halo <b>tebal</b> dan <i>miring</i>'),
        AnnouncementBodyFormat.html,
      );
    });

    test('markdown: heading / list / emphasis', () {
      expect(
        detectAnnouncementBodyFormat('# Judul\n\nIsi paragraf.'),
        AnnouncementBodyFormat.markdown,
      );
      expect(
        detectAnnouncementBodyFormat('- item satu\n- item dua'),
        AnnouncementBodyFormat.markdown,
      );
      expect(
        detectAnnouncementBodyFormat('Teks **penting** ada.'),
        AnnouncementBodyFormat.markdown,
      );
    });

    test('plain: teks biasa tanpa markup', () {
      expect(
        detectAnnouncementBodyFormat('Server istirahat 10 menit malam ini.'),
        AnnouncementBodyFormat.plain,
      );
      // Satu tag inline tunggal di tengah prose = ambigu, tetap plain
      // (lebih aman salah plain daripada render salah).
      expect(
        detectAnnouncementBodyFormat('Harga naik < 5% dan turun > 2%.'),
        AnnouncementBodyFormat.plain,
      );
    });
  });
}
