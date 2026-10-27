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
}
