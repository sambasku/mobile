import '../../../core/utils/format_datetime.dart';
import '../domain/entities/feed_activity_item.dart';

FeedActivityItem? mapFeedActivityItem(Map<String, dynamic> map) {
  final id = map['id']?.toString() ?? '';
  final kind = parseFeedActivityKind(map['kind']?.toString() ?? '');
  if (id.isEmpty || kind == null) return null;

  // `created_at` harus jadi waktu aksi yang masuk akal. Kalau tidak, baris ini
  // dibuang. Server sudah menyaringnya, jadi kemunculan di sini berarti ada
  // jalur tulis lain yang belum dijaga (#47). Membuang lebih baik daripada
  // menampilkan aktivitas salah urutan yang dirender "baru".
  final createdAt = map['created_at']?.toString() ?? '';
  final parsed = DateTime.tryParse(createdAt);
  if (parsed == null || !isPlausibleInstant(parsed)) return null;

  final actorRaw = map['actor'];
  FeedActivityActor? actor;
  if (actorRaw is Map) {
    final m = Map<String, dynamic>.from(actorRaw);
    actor = FeedActivityActor(
      username: m['username']?.toString(),
      displayName: m['display_name']?.toString(),
      avatarUrl: _nonEmptyUrl(m['avatar_url']),
    );
  }

  final targetRaw = map['target'];
  FeedActivityTarget? target;
  if (targetRaw is Map) {
    final m = Map<String, dynamic>.from(targetRaw);
    final type = m['type']?.toString() ?? '';
    final tid = m['id']?.toString() ?? '';
    if (type.isNotEmpty && tid.isNotEmpty) {
      target = FeedActivityTarget(type: type, id: tid);
    }
  }

  // #102: payload pengumuman beku di feed (null = kind lain).
  FeedAnnouncement? announcement;
  final annRaw = map['announcement'];
  if (annRaw is Map && kind == FeedActivityKind.announcement) {
    final m = Map<String, dynamic>.from(annRaw);
    final annId = m['id']?.toString() ?? '';
    final annTitle = m['title']?.toString() ?? '';
    final annBody = m['body']?.toString() ?? '';
    // #124: bodyType eksplisit dari API; tak dikenal = plain (data lama).
    final bodyType = switch (m['bodyType']?.toString() ??
        m['body_type']?.toString()) {
      'html' => AnnouncementBodyType.html,
      'md' => AnnouncementBodyType.md,
      'webview' => AnnouncementBodyType.webview,
      _ => AnnouncementBodyType.plain,
    };
    if (annId.isNotEmpty && annTitle.isNotEmpty) {
      announcement = FeedAnnouncement(
        id: annId,
        title: annTitle,
        body: annBody,
        bodyType: bodyType,
        actionUrl: _nonEmptyUrl(m['action_url']),
        actionLabel: _nonEmptyUrl(m['action_label']),
        expired: m['expired'] == true,
      );
    }
  }

  return FeedActivityItem(
    id: id,
    kind: kind,
    createdAt: createdAt,
    body: map['body']?.toString() ?? '',
    actor: actor,
    subtitle: map['subtitle']?.toString(),
    target: target,
    announcement: announcement,
  );
}

List<FeedActivityItem> mapFeedActivityList(Object? data) {
  if (data is! List) return const [];
  final out = <FeedActivityItem>[];
  for (final row in data) {
    if (row is! Map) continue;
    final item = mapFeedActivityItem(Map<String, dynamic>.from(row));
    if (item != null) out.add(item);
  }
  return out;
}

String? _nonEmptyUrl(Object? raw) {
  if (raw == null) return null;
  final s = raw.toString().trim();
  if (s.isEmpty || s == 'null') return null;
  return s;
}
