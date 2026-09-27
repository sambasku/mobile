import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/utils/format_datetime.dart';

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

  String get actorLabel => _publicLabel(actorDisplayName, actorUsername) ?? 'Sistem';

  String? get suggestedByLabel =>
      _publicLabel(suggestedByDisplayName, suggestedByUsername);
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

final changeHistoryProvider =
    FutureProvider.autoDispose.family<List<ChangeHistoryItem>, String>((
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
          ? _personField(
              source['suggested_by'] is Map
                  ? source['suggested_by'] as Map
                  : null,
              'username',
            )
          : null,
      suggestedByDisplayName: source is Map
          ? _personField(
              source['suggested_by'] is Map
                  ? source['suggested_by'] as Map
                  : null,
              'display_name',
            )
          : null,
      reviewComment:
          source is Map ? source['review_comment']?.toString() : null,
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
  'word_type': 'Jenis',
  'language_id': 'Bahasa',
  'is_verified': 'Verifikasi',
  'status': 'Status',
};

class _HistoryTile extends StatelessWidget with FTileMixin {
  const _HistoryTile({required this.item});

  final ChangeHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final kind = item.isSuggestEdit ? 'Dari usulan' : 'Edit langsung';
    final summary = _changeSummary();
    return FTile(
      title: Text(summary.isNotEmpty ? summary : kind),
      subtitle: Text(_subtitle(kind, hasSummary: summary.isNotEmpty)),
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
