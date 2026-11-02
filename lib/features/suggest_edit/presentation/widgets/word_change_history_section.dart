import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../l10n/app_localizations.dart';

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
String? friendlyChangeValue(String value, AppLocalizations l10n) {
  final v = value.trim();
  if (v.isEmpty) return null;

  // ULID Crockford base32 (26 chars) - case insensitive
  if (RegExp(r'^[0-9A-HJKMNP-TV-Z]{26}$', caseSensitive: false).hasMatch(v)) {
    return null;
  }

  // Coba parse JSON
  try {
    final decoded = jsonDecode(v);
    if (decoded is Map) {
      // relations/variants/images audit format: {added: [...], removed: [...], set_primary: [...]}
      final added = (decoded['added'] is List)
          ? (decoded['added'] as List).length
          : 0;
      final removed = (decoded['removed'] is List)
          ? (decoded['removed'] as List).length
          : 0;
      final setPrimary = (decoded['set_primary'] is List)
          ? (decoded['set_primary'] as List).length
          : 0;
      if (added > 0 || removed > 0 || setPrimary > 0) {
        return [
          if (added > 0) l10n.historyAdded('$added'),
          if (removed > 0) l10n.historyRemoved('$removed'),
          if (setPrimary > 0) l10n.historySetPrimary('$setPrimary'),
        ].join(', ');
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

  String? get actorLabelOrNull => _publicLabel(actorDisplayName, actorUsername);

  String? get suggestedByLabel =>
      _publicLabel(suggestedByDisplayName, suggestedByUsername);
}

String changeHistoryTypeLabel(ChangeHistoryItem item, AppLocalizations l10n) {
  if (item.isDuplicateVote) return l10n.historyDuplicateConfirm;
  if (item.isSuggestEdit) return l10n.historyFromSuggestion;
  return l10n.historyDirectEdit;
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

final changeHistoryProvider = FutureProvider.autoDispose
    .family<List<ChangeHistoryItem>, String>((ref, wordId) async {
      final dio = ref.watch(dioProvider);
      final res = await dio.get<Map<String, dynamic>>(
        '/api/v1/words/$wordId/change-history',
        // ponytail: full page tanpa pagination dulu; naikkan / cursor kalau
        // antrean history mulai panjang.
        queryParameters: {'limit': 50},
      );
      final data = res.data?['data'];
      if (data is! List) return const [];
      return data
          .whereType<Map>()
          .map((raw) {
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
              actorUsername: actor is Map
                  ? _personField(actor, 'username')
                  : null,
              actorDisplayName: actor is Map
                  ? _personField(actor, 'display_name')
                  : null,
              type: map['type']?.toString() ?? 'direct_edit',
              changes: changes,
              reason: source is Map ? source['reason']?.toString() : null,
              suggestedByUsername: source is Map
                  ? _personField(source['suggested_by'] as Map?, 'username')
                  : null,
              suggestedByDisplayName: source is Map
                  ? _personField(source['suggested_by'] as Map?, 'display_name')
                  : null,
              reviewComment: source is Map
                  ? source['review_comment']?.toString()
                  : null,
            );
          })
          .toList(growable: false);
    });

/// Daftar riwayat perubahan kata (halaman penuh via AppBar detail).
class WordChangeHistorySection extends ConsumerWidget {
  const WordChangeHistorySection({super.key, required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
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
            title: l10n.historyWordNotFound,
            subtitle: l10n.historyUnavailable,
          );
        }
        return Column(
          children: [
            _EmptyState(
              icon: FLucideIcons.circleAlert,
              title: l10n.historyLoadFailed,
              subtitle: l10n.historyRetryHint,
            ),
            const Gap(12),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => ref.invalidate(changeHistoryProvider(wordId)),
              child: Text(l10n.historyRetry),
            ),
          ],
        );
      },
      data: (items) {
        if (items.isEmpty) {
          return _EmptyState(
            icon: FLucideIcons.history,
            title: l10n.historyEmpty,
            subtitle: l10n.historyEmptyHint,
          );
        }
        return FTileGroup(
          physics: const NeverScrollableScrollPhysics(),
          children: [for (final item in items) _HistoryTile(item: item)],
        );
      },
    );
  }
}

const _fieldLabelKeys = <String, String>{
  'lemma': 'lemma',
  'notes': 'notes',
  'definition': 'definition',
  'translation': 'translation',
  'translations': 'translation',
  'meaning': 'meaning',
  'meanings': 'meaning',
  'meanings_count': 'meaning',
  'example': 'example',
  'examples': 'example',
  'variant': 'variant',
  'variants': 'variant',
  'category': 'category',
  'categories': 'category',
  'relation': 'relation',
  'relations': 'relation',
  'related_words': 'relation',
  'image': 'image',
  'images': 'image',
  'pronunciation': 'pronunciation',
  'pronunciations': 'pronunciation',
  'word_type': 'wordType',
  'language_id': 'language',
  'is_verified': 'verificationStatus',
  'status': 'status',
  'duplicate_vote': 'support',
  'translation_text': 'translation',
  // Teknis: label hanya untuk fallback, tetap disembunyikan lewat isTechnicalChangeField
  'comment': 'notes',
  'reason_code': 'reason',
  'is_corrected': 'corrected',
  'comma_split': 'commaSeparated',
  'created': 'created',
  'merged_on_create': 'mergedOnCreate',
  'merged_on_update': 'mergedOnEdit',
  'self_applied': 'selfApplied',
  'source_word_id': 'sourceId',
  'split_from_word_id': 'splitOriginId',
  'meaning_ids': 'meaningId',
  'merged_word_ids': 'mergedWordId',
};

String _fieldLabel(String key, AppLocalizations l10n) => switch (key) {
  'lemma' => l10n.historyFieldLemma,
  'notes' => l10n.historyFieldNotes,
  'definition' => l10n.historyFieldDefinition,
  'translation' => l10n.historyFieldTranslation,
  'meaning' => l10n.historyFieldMeaning,
  'example' => l10n.historyFieldExample,
  'variant' => l10n.historyFieldVariant,
  'category' => l10n.historyFieldCategory,
  'relation' => l10n.historyFieldRelation,
  'image' => l10n.historyFieldImage,
  'pronunciation' => l10n.historyFieldPronunciation,
  'wordType' => l10n.historyFieldWordType,
  'language' => l10n.historyFieldLanguage,
  'verificationStatus' => l10n.historyFieldVerificationStatus,
  'status' => l10n.historyFieldStatus,
  'support' => l10n.historyFieldSupport,
  'reason' => l10n.historyFieldReason,
  'corrected' => l10n.historyFieldCorrected,
  'commaSeparated' => l10n.historyFieldCommaSeparated,
  'created' => l10n.historyFieldCreated,
  'mergedOnCreate' => l10n.historyFieldMergedOnCreate,
  'mergedOnEdit' => l10n.historyFieldMergedOnEdit,
  'selfApplied' => l10n.historyFieldSelfApplied,
  'sourceId' => l10n.historyFieldSourceId,
  'splitOriginId' => l10n.historyFieldSplitOriginId,
  'meaningId' => l10n.historyFieldMeaningId,
  'mergedWordId' => l10n.historyFieldMergedWordId,
  _ => key,
};

class _HistoryTile extends StatelessWidget with FTileMixin {
  const _HistoryTile({required this.item});

  final ChangeHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final kind = changeHistoryTypeLabel(item, l10n);
    final summary = _changeSummary(l10n);
    return FTile(
      title: Text(summary.isNotEmpty ? summary : kind),
      subtitle: Text(
        _subtitle(kind, hasSummary: summary.isNotEmpty, l10n: l10n),
      ),
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
        final l10n = AppLocalizations.of(sheetContext);
        final when = item.timestamp.isNotEmpty
            ? formatDateTimeIso(item.timestamp)
            : '-';
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    changeHistoryTypeLabel(item, l10n),
                    style: theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    l10n.historyByActor(
                      item.actorLabelOrNull ?? l10n.historySystem,
                    ),
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  Text(
                    when,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  if (item.reason != null &&
                      item.reason!.trim().isNotEmpty) ...[
                    const Gap(12),
                    Text(
                      l10n.historyReason,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(item.reason!),
                  ],
                  if (item.reviewComment != null &&
                      item.reviewComment!.trim().isNotEmpty) ...[
                    const Gap(12),
                    Text(
                      l10n.historyReviewerNote,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(item.reviewComment!),
                  ],
                  const Gap(16),
                  Text(
                    l10n.historyChanges,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(8),
                  if (item.changes.isEmpty)
                    Text(
                      l10n.historyNoDetail,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    )
                  else
                    ...item.changes.map((diff) {
                      // Sembunyikan field teknis (ID internal, bookkeeping)
                      if (isTechnicalChangeField(diff.field)) {
                        return const SizedBox.shrink();
                      }

                      final label = _labelFor(diff, l10n);

                      // Bersihkan value displayOld / displayNew
                      final oldVal = friendlyChangeValue(diff.displayOld, l10n);
                      final newVal = friendlyChangeValue(diff.displayNew, l10n);

                      // Jika keduanya disembunyikan (mis. ULID), skip baris ini
                      if (oldVal == null && newVal == null) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label.isNotEmpty ? label : diff.field,
                              style: theme.typography.body.sm.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (oldVal != null)
                              Text(
                                l10n.historyBefore(oldVal),
                                style: theme.typography.body.sm.copyWith(
                                  color: theme.colors.mutedForeground,
                                ),
                              ),
                            if (newVal != null)
                              Text(
                                item.isDuplicateVote
                                    ? newVal
                                    : l10n.historyAfter(newVal),
                                style: theme.typography.body.sm,
                              ),
                          ],
                        ),
                      );
                    }),
                  const Gap(8),
                  FButton(
                    variant: FButtonVariant.outline,
                    onPress: () => Navigator.of(sheetContext).pop(),
                    child: Text(l10n.historyClose),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _subtitle(
    String kind, {
    required bool hasSummary,
    required AppLocalizations l10n,
  }) {
    final actor = item.actorLabelOrNull ?? l10n.historySystem;
    final suggested = item.suggestedByLabel ?? '';
    final when = item.timestamp.isNotEmpty
        ? formatDateTimeIso(item.timestamp)
        : '';
    final who = item.isSuggestEdit && suggested.isNotEmpty && suggested != actor
        ? '$suggested → $actor'
        : actor;
    return [if (hasSummary) kind, who, if (when.isNotEmpty) when].join(' · ');
  }

  String _changeSummary(AppLocalizations l10n) {
    final seen = <String>{};
    final labels = <String>[];
    for (final diff in item.changes) {
      // Sembunyikan field teknis dari summary
      if (isTechnicalChangeField(diff.field)) continue;

      final label = _labelFor(diff, l10n);
      if (label.isEmpty || !seen.add(label)) continue;
      if (labels.length < 3) labels.add(label);
    }
    if (seen.length > 3) labels.add('…');
    return labels.join(', ');
  }

  String _labelFor(ChangeHistoryFieldDiff diff, AppLocalizations l10n) {
    final field = diff.field.trim().toLowerCase();
    final entity = diff.entity.trim().toLowerCase();
    final key = _fieldLabelKeys[field] ?? _fieldLabelKeys[entity];
    if (key != null) return _fieldLabel(key, l10n);
    return diff.field.isNotEmpty ? diff.field : diff.entity;
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
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(6),
          Text(
            subtitle,
            style: theme.typography.body.sm.copyWith(
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
