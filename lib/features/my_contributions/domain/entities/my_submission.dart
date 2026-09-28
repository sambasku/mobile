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

  String get kindLabel {
    switch (entityType) {
      case 'meaning':
        return 'Usul makna';
      case 'pronunciation':
        return 'Usul pengucapan';
      case 'word_image':
        return 'Usul gambar';
      case 'word_audio':
        return 'Usul audio';
      case 'example':
        return 'Usul contoh';
      case 'word_suggestion':
        return 'Usul perubahan';
      default:
        return 'Usul kata baru';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'corrected':
        return 'Dikoreksi';
      default:
        return 'Menunggu pengecekan';
    }
  }

  bool get isPendingReview =>
      status != 'approved' && status != 'rejected' && status != 'corrected';

  bool get canOpenWord => wordId != null && wordId!.isNotEmpty;

  String get displayTitle {
    final value = lemma?.trim();
    if (value != null && value.isNotEmpty) return value;
    return kindLabel;
  }

  /// Subtitle tile list: jenis · status · tanggal, plus cuplikan
  /// catatan reviewer jika ditolak.
  String listSubtitle(String formattedDate) {
    final parts = <String>[
      kindLabel,
      statusLabel,
      if (formattedDate.isNotEmpty) formattedDate,
    ];
    var text = parts.join(' · ');
    if (status == 'rejected') {
      final comment = reviewComment?.trim() ?? '';
      if (comment.isNotEmpty) {
        final short = comment.length > 60
            ? '${comment.substring(0, 60)}...'
            : comment;
        text = '$text · $short';
      }
    }
    return text;
  }
}
