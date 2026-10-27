class MySubmission {
  const MySubmission({
    required this.id,
    required this.kind,
    required this.entityType,
    required this.status,
    required this.createdAt,
    this.lemma,
    this.reviewComment,
    this.wordId,
    this.action,
    this.reason,
    this.reasonCode,
    this.reviewedAt,
  });

  final String id;
  final String kind;
  final String entityType;
  final String? lemma;
  final String status;
  final String createdAt;
  final String? reviewComment;
  final String? wordId;
  final String? action;
  final String? reason;
  final String? reasonCode;
  final String? reviewedAt;

  bool get isSuggestion => kind == 'suggestion';

  bool get isPendingReview =>
      status != 'approved' && status != 'rejected' && status != 'corrected';

  bool get canOpenWord => wordId != null && wordId!.isNotEmpty;
}
