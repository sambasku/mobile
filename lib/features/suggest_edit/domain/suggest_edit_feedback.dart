import '../../review/domain/review_access.dart';

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

/// Ambil `data.status` dari envelope API suggest-edit.
String? suggestEditStatusFromResponse(Object? body) {
  if (body is! Map) return null;
  final data = body['data'];
  if (data is! Map) return null;
  final status = data['status'];
  return status is String ? status : null;
}
