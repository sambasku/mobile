import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/utils/format_datetime.dart';

/// Cek apakah field berisi metadata teknis yang tidak perlu ditampilkan ke user.
bool isTechnicalChangeField(String field) {
  final f = field.trim().toLowerCase();
  if (f.endsWith('_id') || f.endsWith('_ids') || f.endsWith('_by')) return true;
  const bookkeeping = {
    'comma_split',
    'created',
    'merged_on_create',
    'merged_on_update',
    'self_applied',
    'source_word_id',
    'split_from_word_id',
    'meaning_ids',
    'merged_word_ids',
    'reopened_by',
  };
  return bookkeeping.contains(f);
}

/// Bersihkan value mentah agar user-friendly.
/// - ULID polos → null (sembunyikan)
/// - JSON dengan kunci added/removed → "Ditambah N, dihapus M"
/// - JSON object lain → null (sembunyikan dump teknis)
/// - JSON array/primitive → null (sembunyikan)
/// - Selain itu (string biasa) → kembalikan apa adanya
String? friendlyChangeValue(String value) {
  final v = value.trim();
  if (v.isEmpty) return null;

  // ULID Crockford base32 (26 chars) - case insensitive
  if (RegExp(r'^[0-9A-HJKMNP-TV-Z]{26}$', caseSensitive: false).hasMatch(v)) return null;

  // Coba parse JSON
  try {
    final decoded = jsonDecode(v);
    if (decoded is Map) {
      // relations/variants/images audit format: {added: [...], removed: [...], set_primary: [...]}
      final added = (decoded['added'] is List) ? (decoded['added'] as List).length : 0;
      final removed = (decoded['removed'] is List) ? (decoded['removed'] as List).length : 0;
      final setPrimary = (decoded['set_primary'] is List) ? (decoded['set_primary'] as List).length : 0;
      if (added > 0 || removed > 0 || setPrimary > 0) {
        final parts = <String>[];
        if (added > 0) parts.add('Ditambah $added');
        if (removed > 0) parts.add('Dihapus $removed');
        if (setPrimary > 0) parts.add('Dijadikan utama $setPrimary');
        return parts.join(', ');
      }
      // JSON object lain (contoh: {status: "published", reason_code: "spam"}) → sembunyikan
      return null;
    }
    // JSON array atau primitive lain (boolean, number) → sembunyikan
    return null;
  } catch (_) {
    // Bukan JSON valid → biarkan apa adanya (string biasa)
  }
  return v;
}

class ChangeHistoryFieldDiff {
  const ChangeHistoryFieldDiff({
    required this.entity,
    required this.field,
    required this.displayOld,
    required this.displayNew,
  });

  final String entity;
  final String field;
  final String displayOld;
  final String displayNew;
}

class ChangeHistoryItem {
  const ChangeHistoryItem({
    required this.id,
    required this.timestamp,
    required this.actorUsername,
    required this.actorDisplayName,
    required this.type,
    required this.changes,
    this.reason,
    this.suggestedByUsername,
    this.suggestedByDisplayName,
    this.reviewComment,
  });

  final String id;
  final String timestamp;
  final String? actorUsername;
  final String? actorDisplayName;
  final String type;
  final List<ChangeHistoryFieldDiff> changes;
  final String? reason;
  final String? suggestedByUsername;
  final String? suggestedByDisplayName;
  final String? reviewComment;

  bool get isSuggestEdit => type == 'suggest_edit';

  bool get isDuplicateVote => type == 'duplicate_vote';

  String get typeLabel {
    if (isDuplicateVote) return 'Konfirmasi duplikat';
    if (isSuggestEdit) return 'Dari usulan';
    return 'Edit langsung';
  }

  String get actorLabel => _publicLabel(actorDisplayName, actorUsername) ?? 'Sistem';

  String? get suggestedByLabel => _publicLabel(suggestedByDisplayName, suggestedByUsername);
}

String? _publicLabel(String? displayName, String? username) {
  final name = displayName?.trim();
  if (name != null && name.isNotEmpty) return name;
  final handle = username?.trim();
  if (handle != null && handle.isNotEmpty) return handle;
  return null;
}

String? _personField(Map? person, String key) {
  if (person == null) return null;
  final value = person[key]?.toString().trim();
  return (value != null && value.isNotEmpty) ? value : null;
}

final changeHistoryProvider = FutureProvider.autoDispose.family<List<ChangeHistoryItem>, String>((
  ref,
  wordId,
) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get<Map<String, dynamic>>(
    '/api/v1/words/$wordId/change-history',
    // ponytail: full page tanpa pagination dulu; naikkan / cursor kalau
    // antrean history mulai panjang.
    queryParameters: {'limit': 50},
  );
  final data = res.data?['data'];
  if (data is! List) return const [];
  return data.whereType<Map>().map((raw) {
    final map = Map<String, dynamic>.from(raw);
    final actor = map['actor'];
    final source = map['source'];
    final changesRaw = map['changes'];
    final changes = <ChangeHistoryFieldDiff>[];
    if (changesRaw is List) {
      for (final c in changesRaw.whereType<Map>()) {
        final cm = Map<String, dynamic>.from(c);
        changes.add(
          ChangeHistoryFieldDiff(
            entity: cm['entity']?.toString() ?? '',
            field: cm['field']?.toString() ?? '',
            displayOld: cm['display_old']?.toString() ?? '',
            displayNew: cm['display_new']?.toString() ?? '',
          ),
        );
      }
    }
    return ChangeHistoryItem(
      id: map['id']?.toString() ?? '',
      timestamp: map['timestamp']?.toString() ?? '',
      actorUsername: actor is Map ? _personField(actor, 'username') : null,
      actorDisplayName: actor is Map ? _personField(actor, 'display_name') : null,
      type: map['type']?.toString() ?? 'direct_edit',
      changes: changes,
      reason: source is Map ? source['reason']?.toString() : null,
      suggestedByUsername: source is Map
          ? _personField(source['suggested_by'] as Map?, 'username')
          : null,
      suggestedByDisplayName: source is Map
          ? _personField(source['suggested_by'] as Map?, 'display_name')
          : null,
      reviewComment: source is Map ? source['review_comment']?.toString() : null,
    );
  }).toList(growable: false);
});

/// Daftar riwayat perubahan kata (halaman penuh via AppBar detail).
class WordChangeHistorySection extends ConsumerWidget {
  const WordChangeHistorySection({super.key, required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(changeHistoryProvider(wordId));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: FCircularProgress()),
      ),
      error: (e, _) {
        if (e is DioException && e.response?.statusCode == 404) {
          return _EmptyState(
            icon: FLucideIcons.searchX,
            title: 'Kata tidak ditemukan',
            subtitle: 'Riwayat tidak tersedia untuk entri ini.',
          );
        }
        return Column(
          children: [
            _EmptyState(
              icon: FLucideIcons.circleAlert,
              title: 'Gagal memuat riwayat',
              subtitle: 'Coba lagi sebentar.',
            ),
            const Gap(12),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => ref.invalidate(changeHistoryProvider(wordId)),
              child: const Text('Coba lagi'),
            ),
          ],
        );
      },
      data: (items) {
        if (items.isEmpty) {
          return const _EmptyState(
            icon: FLucideIcons.history,
            title: 'Belum ada riwayat',
            subtitle: 'Perubahan yang diterapkan ke kata ini akan muncul di sini.',
          );
        }
        return FTileGroup(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final item in items) _HistoryTile(item: item),
          ],
        );
      },
    );
  }
}

const _fieldLabels = <String, String>{
  'lemma': 'Lemma',
  'notes': 'Catatan',
  'definition': 'Definisi',
  'translation': 'Terjemahan',
  'translations': 'Terjemahan',
  'meaning': 'Makna',
  'meanings': 'Makna',
  'meanings_count': 'Makna',
  'example': 'Contoh',
  'examples': 'Contoh',
  'variant': 'Variasi',
  'variants': 'Variasi',
  'category': 'Kategori',
  'categories': 'Kategori',
  'relation': 'Relasi',
  'relations': 'Relasi',
  'related_words': 'Relasi',
  'image': 'Gambar',
  'images': 'Gambar',
  'pronunciation': 'Pengucapan',
  'pronunciations': 'Pengucapan',
  'word_type': 'Jenis kata',
  'language_id': 'Bahasa',
  'is_verified': 'Status verifikasi',
  'status': 'Status',
  'duplicate_vote': 'Dukungan',
  'translation_text': 'Terjemahan',
  // Teknis: label hanya untuk fallback, tetap disembunyikan lewat isTechnicalChangeField
  'comment': 'Catatan',
  'reason_code': 'Alasan',
  'is_corrected': 'Dikoreksi',
  'comma_split': 'Pisah koma',
  'created': 'Dibuat',
  'merged_on_create': 'Digabung saat buat',
  'merged_on_update': 'Digabung saat edit',
  'self_applied': 'Terapkan sendiri',
  'source_word_id': 'ID sumber',
  'split_from_word_id': 'ID asal pisah',
  'meaning_ids': 'ID makna',
  'merged_word_ids': 'ID kata digabung',
};

class _HistoryTile extends StatelessWidget with FTileMixin {
  const _HistoryTile({required this.item});

  final ChangeHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final kind = item.typeLabel;
    final summary = _changeSummary();
    return FTile(
      title: Text(summary.isNotEmpty ? summary : kind),
      subtitle: Text(_subtitle(kind, hasSummary: summary.isNotEmpty)),
      onPress: () => _showDetailSheet(context),
    );
  }

  void _showDetailSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = sheetContext.theme;
        final when = item.timestamp.isNotEmpty ? formatDateTimeIso(item.timestamp) : '-';
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    item.typeLabel,
                    style: theme.typography.lg.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Oleh ${item.actorLabel}',
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  Text(
                    when,
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  if (item.reason != null && item.reason!.trim().isNotEmpty) ...[
                    const Gap(12),
                    Text('Alasan', style: theme.typography.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                    Text(item.reason!),
                  ],
                  if (item.reviewComment != null &&
                      item.reviewComment!.trim().isNotEmpty) ...[
                    const Gap(12),
                    Text('Catatan reviewer', style: theme.typography.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                    Text(item.reviewComment!),
                  ],
                  const Gap(16),
                  Text(
                    'Perubahan',
                    style: theme.typography.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(8),
                  if (item.changes.isEmpty)
                    Text(
                      'Tidak ada detail perubahan.',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    )
                  else
                    ...item.changes.map((diff) {
                      // Sembunyikan field teknis (ID internal, bookkeeping)
                      if (isTechnicalChangeField(diff.field)) return const SizedBox.shrink();

                      final label = _labelFor(diff);

                      // Bersihkan value displayOld / displayNew
                      final oldVal = friendlyChangeValue(diff.displayOld);
                      final newVal = friendlyChangeValue(diff.displayNew);

                      // Jika keduanya disembunyikan (mis. ULID), skip baris ini
                      if (oldVal == null && newVal == null) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label.isNotEmpty ? label : diff.field,
                              style: theme.typography.sm.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (oldVal != null)
                              Text(
                                'Sebelum: $oldVal',
                                style: theme.typography.sm.copyWith(
                                  color: theme.colors.mutedForeground,
                                ),
                              ),
                            if (newVal != null)
                              Text(
                                item.isDuplicateVote ? newVal : 'Sesudah: $newVal',
                                style: theme.typography.sm,
                              ),
                          ],
                        ),
                      );
                    }),
                  const Gap(8),
                  FButton(
                    variant: FButtonVariant.outline,
                    onPress: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _subtitle(String kind, {required bool hasSummary}) {
    final actor = item.actorLabel;
    final suggested = item.suggestedByLabel ?? '';
    final when = item.timestamp.isNotEmpty
        ? formatDateTimeIso(item.timestamp)
        : '';
    final who = item.isSuggestEdit &&
            suggested.isNotEmpty &&
            suggested != actor
        ? '$suggested → $actor'
        : actor;
    return [
      if (hasSummary) kind,
      who,
      if (when.isNotEmpty) when,
    ].join(' · ');
  }

  String _changeSummary() {
    final seen = <String>{};
    final labels = <String>[];
    for (final diff in item.changes) {
      // Sembunyikan field teknis dari summary
      if (isTechnicalChangeField(diff.field)) continue;

      final label = _labelFor(diff);
      if (label.isEmpty || !seen.add(label)) continue;
      if (labels.length < 3) labels.add(label);
    }
    if (seen.length > 3) labels.add('…');
    return labels.join(', ');
  }

  String _labelFor(ChangeHistoryFieldDiff diff) {
    final field = diff.field.trim().toLowerCase();
    final entity = diff.entity.trim().toLowerCase();
    return _fieldLabels[field] ??
        _fieldLabels[entity] ??
        (diff.field.isNotEmpty ? diff.field : diff.entity);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, size: 36, color: theme.colors.mutedForeground),
          const Gap(12),
          Text(
            title,
            style: theme.typography.md.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const Gap(6),
          Text(
            subtitle,
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}