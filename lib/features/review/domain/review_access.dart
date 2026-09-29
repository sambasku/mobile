/// Peran yang boleh membuka antrean review. `editor` tidak termasuk:
/// mereka hanya menandai karya sendiri, bukan meninjau usulan orang lain.
bool canReviewQueue(String? role) =>
    role == 'admin' || role == 'root' || role == 'reviewer';

/// Moderasi Ruang Diskusi (parity API admin/discussions + console).
bool canModerateDiscussions(String? role) =>
    role == 'admin' ||
    role == 'root' ||
    role == 'reviewer' ||
    role == 'editor';

/// Hub Area Verifikator: kontribusi dan/atau tinjauan diskusi.
bool canAccessReviewHome(String? role) =>
    canReviewQueue(role) || canModerateDiscussions(role);

/// Role verifikator (parity API `isVerifierRole`): auto-apply usulan edit.
/// Termasuk `editor` - mereka self-verify karya sendiri, bukan antrean orang lain.
bool isVerifierRole(String? role) =>
    role == 'admin' ||
    role == 'editor' ||
    role == 'root' ||
    role == 'reviewer';

const reviewEntityLabels = <String, String>{
  'word': 'Kata',
  'pronunciation': 'Pelafalan',
  'word_image': 'Gambar',
  'word_audio': 'Audio',
  'example': 'Contoh kalimat',
  'meaning': 'Makna',
};

String reviewEntityLabel(String entityType) =>
    reviewEntityLabels[entityType] ?? entityType;
