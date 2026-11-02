import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/entertainment/domain/rhyme_check.dart';

void main() {
  group('detectRhyme (port dari API)', () {
    const abab = [
      'Pergi berjalan ke Sambas',
      'Membeli ikan di pasar',
      'Pulang bawa rumbas',
      'Hatiku girang menyasar',
    ];

    test('ABAB valid → ok tanpa warning', () {
      final r = detectRhyme(abab, 'ABAB');
      expect(r, isA<RhymeOk>());
      expect((r as RhymeOk).warning, isNull);
    });

    test('AAAA valid → ok', () {
      const aaaa = [
        'Waktu sarapan makan',
        'Di warung ada ikan',
        'Kucing minta pakan',
        'Burung tengok takan',
      ];
      expect(detectRhyme(aaaa, 'AAAA'), isA<RhymeOk>());
    });

    test('baris kosong → RhymeLastWordUndetected', () {
      final r = detectRhyme([abab[0], '', abab[2], abab[3]], 'ABAB');
      expect(r, isA<RhymeLastWordUndetected>());
      expect((r as RhymeLastWordUndetected).lineIndex, 1);
    });

    test('AABB di bawah ABAB → pasangan dilaporkan', () {
      const aabb = [
        'pergi ke pasar',
        'membeli gula',
        'pulang bawa sasar',
        'manis di bibir',
      ];
      final r = detectRhyme(aabb, 'ABAB');
      expect(r, isA<RhymeMismatch>());
      expect((r as RhymeMismatch).pairs, contains(const (2, 4)));
    });

    test('tanda baca trailing di-strip + kapital dinormalisasi', () {
      const lines = [
        'Pergi berjalan ke SAMBAS.',
        'Membeli ikan di pasar,',
        'Pulang bawa RUMBAS!',
        'Hatiku girang menyasar?',
      ];
      expect(detectRhyme(lines, 'ABAB'), isA<RhymeOk>());
    });

    test('rima ambigu (suffix pendek) → ok + warning', () {
      const lines = [
        'Melihat indah mata',
        'Sungguh enak makan',
        'Bersyukur dapat cita',
        'Jangan lupa bukan',
      ];
      final r = detectRhyme(lines, 'ABAB');
      expect(r, isA<RhymeOk>());
      expect((r as RhymeOk).warning, isNotNull);
    });
  });

  group('auto-rima', autoRhymeTests);
}

void autoRhymeTests() {
  test('pickRhymeScheme: AAAA menang saat semua akhiran sama', () {
    expect(
      pickRhymeScheme([
        'pagi hari minum kopi',
        'sore hari minum kopi',
        'malam hari minum kopi',
        'besok pagi minum kopi',
      ]),
      'AAAA',
    );
  });

  test('pickRhymeScheme: ABAB untuk pantun klasik', () {
    expect(
      pickRhymeScheme([
        'jalan jauh ke kota sambas',
        'sungai kecil penuh ikan',
        'bawa bekal sekadar sambas',
        'pulang cepat jangan tahan',
      ]),
      'ABAB',
    );
  });

  test('pickRhymeScheme: null bila tak ada yang cocok', () {
    expect(
      pickRhymeScheme([
        'baris satu berakhir kucing',
        'baris dua berakhir meja',
        'baris tiga berakhir kursi',
        'baris empat berakhir lampu',
      ]),
      isNull,
    );
  });
}
