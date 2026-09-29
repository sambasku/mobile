/// Status satu baris di halaman Usulkan banyak.
enum BulkRowSubmitStatus {
  idle,
  sending,
  sent,
  failed,
}

/// Satu baris lemma + terjemahan.
class BulkContributeRow {
  const BulkContributeRow({
    required this.id,
    this.lemma = '',
    this.translation = '',
    this.status = BulkRowSubmitStatus.idle,
    this.errorMessage,
    this.wordId,
  });

  final String id;
  final String lemma;
  final String translation;
  final BulkRowSubmitStatus status;
  final String? errorMessage;
  final String? wordId;

  bool get isComplete =>
      lemma.trim().isNotEmpty && translation.trim().isNotEmpty;

  bool get isEditable =>
      status == BulkRowSubmitStatus.idle || status == BulkRowSubmitStatus.failed;

  bool get canRemove => status != BulkRowSubmitStatus.sent;

  bool get shouldSubmit =>
      isComplete && status != BulkRowSubmitStatus.sent;

  BulkContributeRow copyWith({
    String? lemma,
    String? translation,
    BulkRowSubmitStatus? status,
    String? errorMessage,
    String? wordId,
    bool clearError = false,
    bool clearWordId = false,
  }) {
    return BulkContributeRow(
      id: id,
      lemma: lemma ?? this.lemma,
      translation: translation ?? this.translation,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      wordId: clearWordId ? null : (wordId ?? this.wordId),
    );
  }
}

/// State halaman `/contribute/bulk`.
class BulkSubmitWordState {
  const BulkSubmitWordState({
    required this.rows,
    this.isSubmitting = false,
    this.progressDone = 0,
    this.progressTotal = 0,
    this.errorMessage,
    this.batchFinished = false,
  });

  static const maxRows = 10;
  static const initialRowCount = 3;

  final List<BulkContributeRow> rows;
  final bool isSubmitting;
  final int progressDone;
  final int progressTotal;

  /// Error form-level (bukan per baris), mis. referensi belum termuat.
  final String? errorMessage;

  /// True setelah satu putaran submit selesai (sukses penuh / partial).
  final bool batchFinished;

  int get sentCount =>
      rows.where((r) => r.status == BulkRowSubmitStatus.sent).length;

  int get failedCount =>
      rows.where((r) => r.status == BulkRowSubmitStatus.failed).length;

  bool get hasPendingSendable => rows.any((r) => r.shouldSubmit);

  bool get hasAnySent => sentCount > 0;

  bool get allSendableSucceeded {
    final sendable = rows.where((r) => r.isComplete).toList(growable: false);
    if (sendable.isEmpty) return false;
    return sendable.every((r) => r.status == BulkRowSubmitStatus.sent);
  }

  /// Setelah ada yang terkirim / gagal, CTA footer jadi "kirim ulang".
  bool get isRetryMode =>
      hasAnySent || failedCount > 0;

  BulkSubmitWordState copyWith({
    List<BulkContributeRow>? rows,
    bool? isSubmitting,
    int? progressDone,
    int? progressTotal,
    String? errorMessage,
    bool? batchFinished,
    bool clearErrorMessage = false,
    bool clearBatchFinished = false,
  }) {
    return BulkSubmitWordState(
      rows: rows ?? this.rows,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      progressDone: progressDone ?? this.progressDone,
      progressTotal: progressTotal ?? this.progressTotal,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      batchFinished: clearBatchFinished
          ? false
          : (batchFinished ?? this.batchFinished),
    );
  }
}
