/// Model riwayat perubahan bersama (kata, wisata, kuliner, dst).
///
/// Dua bentuk respons API dipetakan ke model yang sama:
/// - kata: `type`, `source.{suggested_by, reason, review_comment}`
/// - eksplorasi: `source.{contribution_id}`; `changes[].label` dari server
library;

class ChangeHistoryField {
  const ChangeHistoryField({
    required this.entity,
    required this.field,
    required this.displayOld,
    required this.displayNew,
    this.label,
  });

  final String entity;
  final String field;

  /// Label dari server (eksplorasi). Null untuk riwayat kata.
  final String? label;
  final String displayOld;
  final String displayNew;

  factory ChangeHistoryField.fromJson(Map<String, dynamic> json) {
    return ChangeHistoryField(
      entity: json['entity']?.toString() ?? '',
      field: json['field']?.toString() ?? '',
      label: json['label']?.toString(),
      displayOld: json['display_old']?.toString() ?? '',
      displayNew: json['display_new']?.toString() ?? '',
    );
  }
}

class ChangeHistoryEntry {
  const ChangeHistoryEntry({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.actionLabel,
    required this.entity,
    required this.type,
    required this.fields,
    this.actorLabel,
    this.fromSuggestion = false,
    this.suggestedByLabel,
    this.reason,
    this.reviewComment,
  });

  final String id;
  final String timestamp;

  /// Aksi audit mentah (`create`, `verify`, `photo_add`, ...).
  final String action;

  /// Judul siap tampil dari server. Kosong = pakai label tipe.
  final String actionLabel;

  /// Jenis data: `word`, `meaning`, `place`, ...
  final String entity;

  /// `direct_edit` | `suggest_edit` | `duplicate_vote` (hanya kata).
  final String type;
  final List<ChangeHistoryField> fields;
  final String? actorLabel;
  final bool fromSuggestion;
  final String? suggestedByLabel;
  final String? reason;
  final String? reviewComment;

  bool get isDuplicateVote => type == 'duplicate_vote';

  DateTime? get when => DateTime.tryParse(timestamp);

  factory ChangeHistoryEntry.fromJson(Map<String, dynamic> json) {
    final actor = json['actor'];
    final source = json['source'];
    final type = json['type']?.toString() ?? '';
    final suggestedBy = source is Map ? source['suggested_by'] : null;
    final rawChanges = json['changes'];
    return ChangeHistoryEntry(
      id: json['id']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      actionLabel: json['action_label']?.toString() ?? '',
      entity: json['entity']?.toString() ?? '',
      type: type,
      actorLabel: actor is Map ? _personLabel(actor) : null,
      fromSuggestion: type == 'suggest_edit' || source is Map,
      suggestedByLabel: suggestedBy is Map ? _personLabel(suggestedBy) : null,
      reason: source is Map ? _clean(source['reason']) : null,
      reviewComment: source is Map ? _clean(source['review_comment']) : null,
      fields: rawChanges is List
          ? [
              for (final c in rawChanges.whereType<Map>())
                ChangeHistoryField.fromJson(Map<String, dynamic>.from(c)),
            ]
          : const [],
    );
  }
}

class ChangeHistoryPageData {
  const ChangeHistoryPageData({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<ChangeHistoryEntry> items;
  final String? nextCursor;
  final bool hasMore;

  factory ChangeHistoryPageData.fromResponse(Map<String, dynamic>? body) {
    final data = body?['data'];
    final meta = body?['meta'];
    return ChangeHistoryPageData(
      items: data is List
          ? [
              for (final raw in data.whereType<Map>())
                ChangeHistoryEntry.fromJson(Map<String, dynamic>.from(raw)),
            ]
          : const [],
      nextCursor: meta is Map ? meta['next_cursor']?.toString() : null,
      hasMore: meta is Map && meta['has_more'] == true,
    );
  }
}

String? _clean(Object? value) {
  final s = value?.toString().trim();
  return (s == null || s.isEmpty) ? null : s;
}

/// Nama tampilan, fallback username; null kalau keduanya kosong.
String? _personLabel(Map person) =>
    _clean(person['display_name']) ?? _clean(person['username']);
