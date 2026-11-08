/// Author komentar acara (subset profil publik).
class EventCommentAuthor {
  const EventCommentAuthor({
    required this.userId,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.isVerifier = false,
  });

  factory EventCommentAuthor.fromJson(Map<String, dynamic> json) =>
      EventCommentAuthor(
        userId: (json['user_id'] as String?) ?? '',
        username: json['username'] as String?,
        displayName: json['display_name'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        isVerifier: (json['is_verifier'] as bool?) ?? false,
      );

  final String userId;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final bool isVerifier;
}

/// Komentar acara (wire shape identik komentar ensiklopedia).
class EventComment {
  const EventComment({
    required this.id,
    required this.eventId,
    required this.user,
    required this.body,
    required this.status,
    this.imageUrl,
    this.isEdited = false,
    this.createdAt,
    this.updatedAt,
  });

  factory EventComment.fromJson(Map<String, dynamic> json) => EventComment(
        id: (json['id'] as String?) ?? '',
        eventId: (json['event_id'] as String?) ?? '',
        user: EventCommentAuthor.fromJson(
          (json['user'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
        body: (json['body'] as String?) ?? '',
        status: (json['status'] as String?) ?? '',
        imageUrl: json['image_url'] as String?,
        isEdited: (json['is_edited'] as bool?) ?? false,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
      );

  final String id;
  final String eventId;
  final EventCommentAuthor user;
  final String body;
  final String status;
  final String? imageUrl;
  final bool isEdited;
  final String? createdAt;
  final String? updatedAt;

  bool get isPublished => status == 'published';
  bool get isTakenDown => status == 'taken_down';
  bool get isDeletedByAuthor => status == 'deleted_by_author';
  bool isOwner(String? actorId) =>
      actorId != null && actorId.isNotEmpty && actorId == user.userId;
}

/// Halaman komentar acara (kursor-based).
class EventCommentPage {
  const EventCommentPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  factory EventCommentPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? [
            for (final raw in rawItems.whereType<Map>())
              EventComment.fromJson(raw.cast<String, dynamic>()),
          ]
        : const <EventComment>[];
    return EventCommentPage(
      items: items,
      nextCursor: json['next_cursor'] as String?,
      hasMore: (json['has_more'] as bool?) ?? false,
    );
  }

  final List<EventComment> items;
  final String? nextCursor;
  final bool hasMore;
}
