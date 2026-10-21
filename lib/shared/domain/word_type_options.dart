/// Jenis entri API `word_type`. Bukan kelas kata.
/// [detail] boleh panjang: ditampilkan di bottom sheet, bukan di chip kartu.
const wordTypeOptions = <({String value, String label, String detail})>[
  (
    value: 'word',
    label: 'Kata',
    detail: 'Satu lema. Bukan frasa.',
  ),
  (
    value: 'idiom',
    label: 'Idiom',
    detail:
        'Frasa yang artinya tidak sama dengan arti tiap katanya. Contoh: tangan besi.',
  ),
  (
    value: 'peribahasa',
    label: 'Peribahasa',
    detail: 'Kalimat kiasan atau nasihat yang sudah lazim.',
  ),
  (
    value: 'ungkapan',
    label: 'Ungkapan',
    detail: 'Kelompok kata yang sudah lazim dipakai bersama.',
  ),
];

String wordTypeOptionLabel(String? code) {
  for (final option in wordTypeOptions) {
    if (option.value == code) return option.label;
  }
  return 'Kata';
}
