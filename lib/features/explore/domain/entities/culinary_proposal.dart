/// Satu usulan kuliner milik user. Bentuk mengikuti wire
/// `GET /api/v1/culinary/contributions/mine`.
///
/// `kind`/`status` dibiarkan string mentah supaya kind baru di API tidak
/// memaksa perubahan mobile.
class CulinaryProposal {
  const CulinaryProposal({
    required this.id,
    required this.kind,
    required this.status,
    this.createdAt,
    this.name,
    this.cuisineName,
    this.placeName,
    this.revisionNote,
    this.rejectReasonCode,
    this.rejectReasonText,
  });

  final String id;
  final String kind;
  final String status;
  final DateTime? createdAt;

  /// Nama target hasil join (kuliner/tempat) atau `payload.name` usulan baru.
  final String? name;
  final String? cuisineName;
  final String? placeName;
  final String? revisionNote;
  final String? rejectReasonCode;
  final String? rejectReasonText;

  bool get canCancel => status == 'pending' || status == 'needs_revision';

  String get title => cuisineName ?? placeName ?? name ?? '';
}
