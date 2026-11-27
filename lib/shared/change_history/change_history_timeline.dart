import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/utils/format_datetime.dart';
import '../../l10n/app_localizations.dart';
import 'change_history_controller.dart';
import 'change_history_models.dart';
import 'change_history_values.dart';

/// Timeline riwayat perubahan (dot + garis + kartu isi) untuk data apa pun
/// yang punya endpoint `change-history`. Tidak scroll sendiri: taruh di dalam
/// `ListView` halaman.
class ChangeHistoryTimeline extends ConsumerWidget {
  const ChangeHistoryTimeline({
    super.key,
    required this.path,
    required this.notFoundTitle,
    required this.emptyHint,
  });

  /// Path endpoint (`wordChangeHistoryPath`, `placeChangeHistoryPath`, dst).
  final String path;
  final String notFoundTitle;
  final String emptyHint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = changeHistoryControllerProvider(path);
    final async = ref.watch(provider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: FCircularProgress()),
      ),
      error: (e, _) {
        if (e is DioException && e.response?.statusCode == 404) {
          return _StateMessage(
            icon: FLucideIcons.searchX,
            title: notFoundTitle,
            subtitle: l10n.historyUnavailable,
          );
        }
        return Column(
          children: [
            _StateMessage(
              icon: FLucideIcons.circleAlert,
              title: l10n.historyLoadFailed,
              subtitle: l10n.historyRetryHint,
            ),
            const Gap(12),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => ref.invalidate(provider),
              child: Text(l10n.historyRetry),
            ),
          ],
        );
      },
      data: (state) {
        if (state.items.isEmpty) {
          return _StateMessage(
            icon: FLucideIcons.history,
            title: l10n.historyEmpty,
            subtitle: emptyHint,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < state.items.length; i++)
              _TimelineRow(
                key: ValueKey(state.items[i].id),
                entry: state.items[i],
                isLast: i == state.items.length - 1 && !state.hasMore,
              ),
            if (state.hasMore)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: FButton(
                  variant: FButtonVariant.outline,
                  onPress: state.isLoadingMore
                      ? null
                      : () => ref.read(provider.notifier).loadMore(),
                  prefix: state.isLoadingMore
                      ? const FCircularProgress(size: .sm)
                      : null,
                  child: Text(l10n.historyLoadMore),
                ),
              ),
          ],
        );
      },
    );
  }
}

const _maxInlineFields = 3;

class _TimelineRow extends StatefulWidget {
  const _TimelineRow({super.key, required this.entry, required this.isLast});

  final ChangeHistoryEntry entry;
  final bool isLast;

  @override
  State<_TimelineRow> createState() => _TimelineRowState();
}

class _TimelineRowState extends State<_TimelineRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final entry = widget.entry;
    final visual = _visualFor(entry);
    final fields = _visibleFields(entry, l10n);
    final shown = _expanded ? fields : fields.take(_maxInlineFields).toList();
    final hidden = fields.length - shown.length;

    final actor = entry.actorLabel ?? l10n.historySystem;
    final ago = formatRelativeAgo(entry.when);
    final meta = [
      l10n.historyByActor(actor),
      if (ago.isNotEmpty) ago else formatDateTimeIso(entry.timestamp),
    ].join(' · ');

    final title = entry.actionLabel.isNotEmpty
        ? entry.actionLabel
        : _fallbackTitle(entry, l10n);
    final suggestedBy = entry.suggestedByLabel;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: visual.destructive
                        ? theme.colors.destructive.withValues(alpha: 0.12)
                        : theme.colors.secondary,
                  ),
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: Icon(
                      visual.icon,
                      size: 14,
                      color: visual.destructive
                          ? theme.colors.destructive
                          : theme.colors.secondaryForeground,
                    ),
                  ),
                ),
                if (!widget.isLast)
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: 2,
                        child: ColoredBox(color: theme.colors.border),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Gap(8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      title,
                      style: theme.typography.body.md.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Gap(2),
                  Text(
                    meta,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  if (entry.fromSuggestion) ...[
                    const Gap(6),
                    FBadge(
                      variant: FBadgeVariant.secondary,
                      child: Text(
                        suggestedBy != null && suggestedBy != actor
                            ? l10n.historySuggestedBy(suggestedBy)
                            : l10n.historyFromSuggestion,
                      ),
                    ),
                  ],
                  if (entry.reason != null) ...[
                    const Gap(8),
                    Text(
                      l10n.historyReasonLine(entry.reason!),
                      style: theme.typography.body.sm,
                    ),
                  ],
                  if (entry.reviewComment != null) ...[
                    const Gap(4),
                    Text(
                      l10n.historyReviewerNoteLine(entry.reviewComment!),
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                  for (final f in shown) _FieldDiff(field: f, entry: entry),
                  if (fields.length > _maxInlineFields)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: FButton(
                        variant: FButtonVariant.ghost,
                        size: FButtonSizeVariant.sm,
                        onPress: () => setState(() => _expanded = !_expanded),
                        child: Text(
                          _expanded
                              ? l10n.historyShowLess
                              : l10n.historyShowMoreChanges(hidden),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hanya field yang bermakna untuk pembaca: bukan ID teknis, nilai tidak
  /// kosong setelah dibersihkan.
  List<_ResolvedField> _visibleFields(
    ChangeHistoryEntry entry,
    AppLocalizations l10n,
  ) {
    final out = <_ResolvedField>[];
    for (final f in entry.fields) {
      if (isTechnicalChangeField(f.field)) continue;
      final oldValue = friendlyChangeValue(f.displayOld, l10n);
      final newValue = friendlyChangeValue(f.displayNew, l10n);
      if (oldValue == null && newValue == null) continue;
      out.add(
        _ResolvedField(
          label: changeHistoryFieldLabel(
            field: f.field,
            entity: f.entity,
            serverLabel: f.label,
            l10n: l10n,
          ),
          // "-" = tidak ada nilai sebelumnya (data baru): tampil nilai akhir saja.
          oldValue: (oldValue == null || oldValue == '-') ? null : oldValue,
          newValue: newValue,
        ),
      );
    }
    return out;
  }

  String _fallbackTitle(ChangeHistoryEntry entry, AppLocalizations l10n) {
    if (entry.isDuplicateVote) return l10n.historyDuplicateConfirm;
    if (entry.fromSuggestion) return l10n.historyFromSuggestion;
    return l10n.historyDirectEdit;
  }
}

class _ResolvedField {
  const _ResolvedField({
    required this.label,
    required this.oldValue,
    required this.newValue,
  });

  final String label;
  final String? oldValue;
  final String? newValue;
}

class _FieldDiff extends StatelessWidget {
  const _FieldDiff({required this.field, required this.entry});

  final _ResolvedField field;
  final ChangeHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final oldValue = field.oldValue;
    final newValue = field.newValue;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.secondary,
          borderRadius: theme.style.borderRadius.md,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.label,
                style: theme.typography.body.xs.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colors.mutedForeground,
                ),
              ),
              if (oldValue != null) ...[
                const Gap(4),
                Text(
                  l10n.historyBefore(oldValue),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
              if (newValue != null) ...[
                const Gap(4),
                Text(
                  // Data baru / dukungan duplikat: nilai apa adanya, tanpa "Sesudah".
                  oldValue == null || entry.isDuplicateVote
                      ? newValue
                      : l10n.historyAfter(newValue),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.body.sm,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Visual {
  const _Visual(this.icon, {this.destructive = false});

  final IconData icon;
  final bool destructive;
}

_Visual _visualFor(ChangeHistoryEntry entry) {
  switch (entry.action) {
    case 'create':
      return switch (entry.entity) {
        'word_image' => const _Visual(FLucideIcons.imagePlus),
        'word_audio' || 'pronunciation' => const _Visual(FLucideIcons.mic),
        _ => const _Visual(FLucideIcons.plus),
      };
    case 'publish':
    case 'restore':
      return const _Visual(FLucideIcons.circleCheck);
    case 'verify':
      return const _Visual(FLucideIcons.badgeCheck);
    case 'photo_add':
      return const _Visual(FLucideIcons.imagePlus);
    case 'unpublish':
      return const _Visual(FLucideIcons.eyeOff, destructive: true);
    case 'unverify':
    case 'unverify_by_vote_quorum':
    case 'reject':
      return const _Visual(FLucideIcons.circleX, destructive: true);
    case 'photo_remove':
      return const _Visual(FLucideIcons.image, destructive: true);
    case 'takedown':
    case 'delete':
      return const _Visual(FLucideIcons.trash2, destructive: true);
    default:
      return const _Visual(FLucideIcons.pencil);
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
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
