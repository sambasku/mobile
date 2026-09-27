class InboxNotification {
  const InboxNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.targetKind,
    required this.targetId,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final String targetKind;
  final String targetId;
  final String createdAt;
  final String? readAt;

  bool get isUnread => readAt == null || readAt!.isEmpty;

  String get typeLabel {
    switch (type) {
      case 'contribution_approved':
      case 'suggestion_approved':
        return 'Disetujui';
      case 'contribution_rejected':
      case 'suggestion_rejected':
        return 'Ditolak';
      case 'contribution_corrected':
      case 'suggestion_corrected':
        return 'Dikoreksi';
      case 'word_taken_down':
        return 'Ditarik';
      case 'translation_help_approved':
        return 'Bantuan disetujui';
      case 'translation_help_rejected':
        return 'Bantuan ditolak';
      case 'translation_help_taken_down':
        return 'Bantuan diturunkan';
      case 'campaign':
        return 'Pengumuman';
      case 'word_comment':
        return 'Komentar';
      default:
        return 'Pembaruan';
    }
  }
}
