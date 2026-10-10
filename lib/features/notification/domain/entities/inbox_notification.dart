import '../../../activity/domain/entities/feed_activity_item.dart';

class InboxNotification {
  const InboxNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.bodyType = AnnouncementBodyType.plain,
    required this.targetKind,
    required this.targetId,
    required this.createdAt,
    this.readAt,
    this.actionKind,
    this.actionValue,
    this.imageUrl,
  });

  final String id;
  final String type;
  final String title;
  final String body;

  /// Cara render [body] di detail; sama dengan body pengumuman (#124).
  final AnnouncementBodyType bodyType;
  final String targetKind;
  final String targetId;
  final String createdAt;
  final String? readAt;

  /// CTA tap (#19): word | contribution | suggestion | discussion | url
  final String? actionKind;
  final String? actionValue;

  /// Opsional - thumbnail / rich push (campaign).
  final String? imageUrl;

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
      case 'discussion_pending_review':
        return 'Diskusi menunggu';
      case 'discussion_approved':
        return 'Diskusi disetujui';
      case 'discussion_rejected':
        return 'Diskusi ditolak';
      case 'discussion_taken_down':
        return 'Diskusi diturunkan';
      case 'discussion_reply':
        return 'Balasan diskusi';
      case 'campaign':
        return 'Pengumuman';
      case 'word_comment':
        return 'Komentar';
      case 'word_vote':
        return 'Vote';
      case 'verifier_application_approved':
        return 'Disetujui';
      case 'verifier_application_rejected':
        return 'Ditolak';
      default:
        return 'Pembaruan';
    }
  }
}
