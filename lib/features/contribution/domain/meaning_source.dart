/// Provenance padanan/definisi untuk API `meanings[].meaning_source`.
enum MeaningSource {
  manual,
  kbbi,
  kbbiEdited;

  String get apiValue => switch (this) {
    MeaningSource.manual => 'manual',
    MeaningSource.kbbi => 'kbbi',
    MeaningSource.kbbiEdited => 'kbbi_edited',
  };

  static MeaningSource? tryParse(String? raw) {
    switch (raw?.trim()) {
      case 'kbbi':
        return MeaningSource.kbbi;
      case 'kbbi_edited':
        return MeaningSource.kbbiEdited;
      case 'manual':
        return MeaningSource.manual;
      default:
        return null;
    }
  }
}

/// Snapshot field yang diisi dari satu pilihan sense KBBI.
class KbbiMeaningSnapshot {
  const KbbiMeaningSnapshot({
    required this.padanan,
    required this.definition,
    this.wordClassId,
  });

  final String padanan;
  final String definition;
  final String? wordClassId;
}

bool _isEmptyDefinition(String definition) {
  final t = definition.trim();
  return t.isEmpty || t == '-';
}

/// Hitung `meaning_source` dari snapshot sesi + isi form saat ini.
MeaningSource resolveMeaningSource({
  required KbbiMeaningSnapshot? snapshot,
  required String padanan,
  required String definition,
  required String? wordClassId,
}) {
  if (snapshot == null) return MeaningSource.manual;

  final p = padanan.trim();
  final d = definition.trim();
  final wc = wordClassId;
  final snapP = snapshot.padanan.trim();
  final snapD = snapshot.definition.trim();
  final snapWc = snapshot.wordClassId;

  // Semua jejak KBBI hilang → mulai ulang.
  final noPadanan = p.isEmpty;
  final noDefinition = _isEmptyDefinition(d);
  final noWordClass = wc == null || wc.isEmpty;
  if (noPadanan && noDefinition && noWordClass) {
    return MeaningSource.manual;
  }

  final padananMatch = p == snapP;
  final definitionMatch = d == snapD;
  final wordClassMatch = (wc ?? '') == (snapWc ?? '');
  if (padananMatch && definitionMatch && wordClassMatch) {
    return MeaningSource.kbbi;
  }
  return MeaningSource.kbbiEdited;
}

/// Label ringkas untuk verifikator di preview review.
String meaningSourceReviewLabel(String? raw) {
  switch (MeaningSource.tryParse(raw) ?? MeaningSource.manual) {
    case MeaningSource.kbbi:
      return 'Dari KBBI';
    case MeaningSource.kbbiEdited:
      return 'Dari KBBI (diubah)';
    case MeaningSource.manual:
      return 'Ketik manual';
  }
}
