import '../../review/domain/review_access.dart';

/// Copy tile di detail kata - berdasarkan role lokal.
({String title, String subtitle}) suggestEditEntryTileCopy(String? role) {
  if (isVerifierRole(role)) {
    return (
      title: 'Ubah kata',
      subtitle: 'Perubahan langsung diterapkan, tanpa antrean',
    );
  }
  return (
    title: 'Usulkan perubahan',
    subtitle: 'Perbaikan kata yang sudah dicek menunggu persetujuan',
  );
}

/// Copy form sebelum submit - berdasarkan role lokal.
({String banner, String cta, String ctaBusy}) suggestEditPreSubmitCopy(
  String? role,
) {
  if (isVerifierRole(role)) {
    return (
      banner:
          'Ubah yang perlu saja. Perubahan langsung diterapkan, tanpa antrean.',
      cta: 'Simpan perubahan',
      ctaBusy: 'Menyimpan...',
    );
  }
  return (
    banner: 'Ubah yang perlu saja. Admin mereview sebelum tayang.',
    cta: 'Kirim Usulan',
    ctaBusy: 'Mengirim...',
  );
}

/// Apakah response self-apply (tayang langsung).
/// Status API adalah sumber kebenaran; role lokal hanya fallback.
bool suggestEditWasSelfApplied({
  required String? responseStatus,
  required String? actorRole,
}) {
  if (responseStatus == 'approved') return true;
  if (responseStatus == 'pending') return false;
  return isVerifierRole(actorRole);
}

/// Toast setelah submit sukses.
String suggestEditSuccessToast({
  required bool selfApplied,
  required bool wordVerified,
  required String lemma,
}) {
  final label = lemma.isEmpty ? 'kata ini' : lemma;
  if (selfApplied) {
    return 'Perubahan langsung diterapkan pada "$label".';
  }
  if (wordVerified) {
    return 'Usulan untuk "$label" masuk antrean. Isi yang sedang tayang belum berubah.';
  }
  return 'Perubahan sudah tayang di "$label". Statusnya tetap menunggu pengecekan.';
}

/// Ambil `data.status` dari envelope API suggest-edit.
String? suggestEditStatusFromResponse(Object? body) {
  if (body is! Map) return null;
  final data = body['data'];
  if (data is! Map) return null;
  final status = data['status'];
  return status is String ? status : null;
}
