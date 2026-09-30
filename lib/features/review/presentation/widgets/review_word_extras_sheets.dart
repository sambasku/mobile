import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../dictionary/domain/entities/word_summary.dart';
import '../../../dictionary/presentation/providers/word_complete_providers.dart';

/// Relasi kata di form koreksi. Target selalu kata yang sudah ada
/// (server menolak kata baru inline saat koreksi).
class ReviewRelatedWord {
  const ReviewRelatedWord({
    required this.wordId,
    required this.lemma,
    required this.relationType,
  });

  final String wordId;
  final String lemma;

  /// `synonym` atau `antonym`.
  final String relationType;
}

// ponytail: batas lokal, sama dengan validator API (maks 20 bentuk).
const reviewMaxVariants = 20;

/// Sheet sinonim & antonim. Perubahan langsung dikirim ke [onChanged]
/// (tetap baru tersimpan saat form koreksi disimpan).
Future<void> showReviewRelationsSheet(
  BuildContext context, {
  required List<ReviewRelatedWord> initial,
  required String excludeWordId,
  required ValueChanged<List<ReviewRelatedWord>> onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _RelationsSheet(
      initial: initial,
      excludeWordId: excludeWordId,
      onChanged: onChanged,
    ),
  );
}

class _RelationsSheet extends ConsumerStatefulWidget {
  const _RelationsSheet({
    required this.initial,
    required this.excludeWordId,
    required this.onChanged,
  });

  final List<ReviewRelatedWord> initial;
  final String excludeWordId;
  final ValueChanged<List<ReviewRelatedWord>> onChanged;

  @override
  ConsumerState<_RelationsSheet> createState() => _RelationsSheetState();
}

class _RelationsSheetState extends ConsumerState<_RelationsSheet> {
  late final List<ReviewRelatedWord> _items = List.of(widget.initial);
  final _query = TextEditingController();
  String _type = 'synonym';

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<ReviewRelatedWord> _ofType(String type) =>
      _items.where((r) => r.relationType == type).toList();

  void _toggle(String wordId, String lemma) {
    setState(() {
      final existing = _items.indexWhere((r) => r.wordId == wordId);
      if (existing >= 0 && _items[existing].relationType == _type) {
        _items.removeAt(existing);
      } else {
        // Satu kata tidak bisa sekaligus sinonim dan antonim.
        if (existing >= 0) _items.removeAt(existing);
        _items.add(
          ReviewRelatedWord(wordId: wordId, lemma: lemma, relationType: _type),
        );
      }
    });
    widget.onChanged(List.unmodifiable(_items));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final search = ref.watch(wordCompleteProvider);
    final selected = _ofType(_type);
    final results = search.items
        .where((w) => w.id != widget.excludeWordId)
        .toList();
    final media = MediaQuery.of(context);

    return SizedBox(
      height: (media.size.height - media.viewInsets.bottom) * 0.85,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + media.viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Sinonim & antonim',
                    style: theme.typography.lg.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                FButton(
                  size: FButtonSizeVariant.sm,
                  onPress: () => Navigator.pop(context),
                  child: const Text('Selesai'),
                ),
              ],
            ),
            const Gap(12),
            Row(
              children: [
                for (final (type, label) in const [
                  ('synonym', 'Sinonim'),
                  ('antonym', 'Antonim'),
                ]) ...[
                  Expanded(
                    child: FButton(
                      size: FButtonSizeVariant.sm,
                      variant: _type == type
                          ? FButtonVariant.primary
                          : FButtonVariant.outline,
                      onPress: () => setState(() => _type = type),
                      child: Text('$label (${_ofType(type).length})'),
                    ),
                  ),
                  if (type == 'synonym') const Gap(8),
                ],
              ],
            ),
            const Gap(12),
            if (selected.isEmpty)
              Text(
                _type == 'synonym'
                    ? 'Belum ada sinonim. Cari kata di bawah untuk menambah.'
                    : 'Belum ada antonim. Cari kata di bawah untuk menambah.',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              )
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final r in selected)
                    GestureDetector(
                      onTap: () => _toggle(r.wordId, r.lemma),
                      child: FBadge(
                        variant: FBadgeVariant.secondary,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(r.lemma),
                            const Gap(4),
                            Icon(
                              FLucideIcons.x,
                              size: 12,
                              semanticLabel: 'Hapus ${r.lemma}',
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            const Gap(12),
            FTextField(
              control: FTextFieldControl.managed(
                controller: _query,
                onChange: (value) => ref
                    .read(wordCompleteProvider.notifier)
                    .onQueryChanged(value.text),
              ),
              hint: 'Cari kata yang sudah ada...',
              prefixBuilder: (context, style, variants) =>
                  FTextField.prefixIconBuilder(
                    context,
                    style,
                    variants,
                    const Icon(FLucideIcons.search),
                  ),
            ),
            const Gap(8),
            Expanded(
              child: _RelationResults(
                state: search,
                results: results,
                selectedIds: {for (final r in selected) r.wordId},
                onTap: _toggle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RelationResults extends StatelessWidget {
  const _RelationResults({
    required this.state,
    required this.results,
    required this.selectedIds,
    required this.onTap,
  });

  final WordCompleteState state;
  final List<WordSummary> results;
  final Set<String> selectedIds;
  final void Function(String wordId, String lemma) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final muted = theme.typography.sm.copyWith(color: theme.colors.mutedForeground);
    if (!state.isSearching) {
      return Text('Ketik minimal 2 huruf.', style: muted);
    }
    if (state.isLoading) {
      return const Center(child: FCircularProgress());
    }
    if (state.errorMessage != null) {
      return Text(state.errorMessage!, style: muted);
    }
    if (results.isEmpty) {
      return Text(
        'Kata tidak ditemukan. Hanya kata yang sudah ada di kamus yang bisa dipilih.',
        style: muted,
      );
    }
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, _) => const Gap(4),
      itemBuilder: (context, i) {
        final word = results[i];
        final picked = selectedIds.contains(word.id);
        final sense = word.sense;
        return FTile(
          title: Text(word.lemma),
          subtitle: sense == null
              ? null
              : Text(sense, maxLines: 1, overflow: TextOverflow.ellipsis),
          suffix: Icon(
            picked ? FLucideIcons.check : FLucideIcons.plus,
            color: picked ? theme.colors.primary : theme.colors.mutedForeground,
          ),
          onPress: () => onTap(word.id, word.lemma),
        );
      },
    );
  }
}

/// Sheet variasi penulisan. Perubahan langsung dikirim ke [onChanged].
Future<void> showReviewVariantsSheet(
  BuildContext context, {
  required List<String> initial,
  required String lemma,
  required ValueChanged<List<String>> onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) =>
        _VariantsSheet(initial: initial, lemma: lemma, onChanged: onChanged),
  );
}

class _VariantsSheet extends StatefulWidget {
  const _VariantsSheet({
    required this.initial,
    required this.lemma,
    required this.onChanged,
  });

  final List<String> initial;
  final String lemma;
  final ValueChanged<List<String>> onChanged;

  @override
  State<_VariantsSheet> createState() => _VariantsSheetState();
}

class _VariantsSheetState extends State<_VariantsSheet> {
  late final List<String> _items = List.of(widget.initial);
  final _input = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _add() {
    final form = _input.text.trim();
    if (form.isEmpty) return;
    final lower = form.toLowerCase();
    final error = lower == widget.lemma.trim().toLowerCase()
        ? 'Variasi tidak boleh sama dengan lemma'
        : _items.any((v) => v.toLowerCase() == lower)
        ? 'Variasi ini sudah ada'
        : _items.length >= reviewMaxVariants
        ? 'Maksimal $reviewMaxVariants variasi'
        : null;
    setState(() {
      _error = error;
      if (error == null) {
        _items.add(form);
        _input.clear();
      }
    });
    if (error == null) widget.onChanged(List.unmodifiable(_items));
  }

  void _remove(String form) {
    setState(() => _items.remove(form));
    widget.onChanged(List.unmodifiable(_items));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + media.viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Variasi penulisan',
                  style: theme.typography.lg.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              FButton(
                size: FButtonSizeVariant.sm,
                onPress: () => Navigator.pop(context),
                child: const Text('Selesai'),
              ),
            ],
          ),
          const Gap(4),
          Text(
            'Ejaan lain untuk "${widget.lemma}".',
            style: theme.typography.sm.copyWith(color: theme.colors.mutedForeground),
          ),
          const Gap(12),
          if (_items.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final form in _items)
                  GestureDetector(
                    onTap: () => _remove(form),
                    child: FBadge(
                      variant: FBadgeVariant.secondary,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(form),
                          const Gap(4),
                          Icon(
                            FLucideIcons.x,
                            size: 12,
                            semanticLabel: 'Hapus $form',
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const Gap(12),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FTextField(
                  control: FTextFieldControl.managed(controller: _input),
                  hint: 'Tulis variasi, mis. klintiak',
                  textInputAction: TextInputAction.done,
                  onSubmit: (_) => _add(),
                  error: _error == null ? null : Text(_error!),
                ),
              ),
              const Gap(8),
              FButton(
                variant: FButtonVariant.outline,
                onPress: _add,
                child: const Text('Tambah'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
