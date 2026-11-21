/// Kartu tautan lintas fitur dari `content_links` (wire `related`).
class ContentRelatedLink {
  const ContentRelatedLink({
    required this.kind,
    required this.id,
    required this.title,
    this.slug,
    this.coverUrl,
  });

  final String kind;
  final String id;
  final String title;
  final String? slug;
  final String? coverUrl;

  Map<String, dynamic> toRefJson() => {
        'kind': kind,
        'id': id,
        if (slug != null && slug!.isNotEmpty) 'slug': slug,
      };

  static ContentRelatedLink? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final kind = map['kind']?.toString().trim() ?? '';
    final id = map['id']?.toString().trim() ?? '';
    final title = map['title']?.toString().trim() ?? '';
    if (kind.isEmpty || id.isEmpty || title.isEmpty) return null;
    final slug = map['slug']?.toString().trim();
    final cover = map['cover_url']?.toString().trim();
    return ContentRelatedLink(
      kind: kind,
      id: id,
      title: title,
      slug: (slug == null || slug.isEmpty) ? null : slug,
      coverUrl: (cover == null || cover.isEmpty) ? null : cover,
    );
  }

  static List<ContentRelatedLink> listFromJson(Object? raw) {
    if (raw is! List) return const [];
    final out = <ContentRelatedLink>[];
    for (final item in raw) {
      final parsed = tryParse(item);
      if (parsed != null) out.add(parsed);
    }
    return out;
  }
}
