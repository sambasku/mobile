import '../domain/entities/feed_activity_item.dart';

FeedActivityItem? mapFeedActivityItem(Map<String, dynamic> map) {
  final id = map['id']?.toString() ?? '';
  final kind = parseFeedActivityKind(map['kind']?.toString() ?? '');
  if (id.isEmpty || kind == null) return null;

  final actorRaw = map['actor'];
  FeedActivityActor? actor;
  if (actorRaw is Map) {
    final m = Map<String, dynamic>.from(actorRaw);
    actor = FeedActivityActor(
      username: m['username']?.toString(),
      displayName: m['display_name']?.toString(),
      avatarUrl: m['avatar_url']?.toString(),
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

  return FeedActivityItem(
    id: id,
    kind: kind,
    createdAt: map['created_at']?.toString() ?? '',
    body: map['body']?.toString() ?? '',
    actor: actor,
    subtitle: map['subtitle']?.toString(),
    target: target,
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
