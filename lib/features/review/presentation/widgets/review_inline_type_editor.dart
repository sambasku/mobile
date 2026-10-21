import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/gestures/swipe_exempt.dart';
import '../../../../shared/domain/word_type_options.dart';
import '../../../../shared/reference/reference_data.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/word_type_picker_sheet.dart';
import '../../../contribution/presentation/widgets/word_class_picker_sheet.dart';
import '../../data/review_correct_body.dart';
import '../../domain/entities/review_contribution.dart';
import '../providers/review_providers.dart';

/// Pilih jenis entri dan kelas Umum. Ketuk item langsung menyimpan.
class ReviewInlineTypeEditor extends ConsumerStatefulWidget {
  const ReviewInlineTypeEditor({super.key, required this.detail});

  final ReviewDetail detail;

  @override
  ConsumerState<ReviewInlineTypeEditor> createState() =>
      _ReviewInlineTypeEditorState();
}

class _ReviewInlineTypeEditorState
    extends ConsumerState<ReviewInlineTypeEditor> {
  late String _wordType;
  late String _savedType;
  final _classByIndex = <int, String>{};
  final _savedClass = <int, String>{};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant ReviewInlineTypeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detail.contribution.id != widget.detail.contribution.id ||
        oldWidget.detail.entity['wordType'] != widget.detail.entity['wordType']) {
      _sync();
    }
  }

  void _sync() {
    _wordType = widget.detail.entity['wordType']?.toString() ?? 'word';
    _savedType = _wordType;
    _classByIndex.clear();
    _savedClass.clear();
  }

  List<_MeaningClass> _meaningClasses() {
    final raw = widget.detail.entity['meanings'];
    if (raw is! List) return const [];
    final rows = <_MeaningClass>[];
    for (var i = 0; i < raw.length; i++) {
      final item = raw[i];
      if (item is! Map) continue;
      final wordClass = item['wordClass'];
      final map = wordClass is Map ? wordClass : const <String, dynamic>{};
      final id = map['id']?.toString() ?? '';
      final alias = map['alias']?.toString().trim() ?? '';
      final name = map['name']?.toString().trim() ?? '';
      rows.add(
        _MeaningClass(
          index: i,
          classId: id,
          definition: item['definition']?.toString() ?? '',
          fallbackLabel: alias.isNotEmpty
              ? alias
              : (name.isNotEmpty ? name : 'Umum'),
        ),
      );
    }
    return rows;
  }

  bool get _dirty {
    if (_wordType != _savedType) return true;
    if (_classByIndex.length != _savedClass.length) return true;
    for (final entry in _classByIndex.entries) {
      if (_savedClass[entry.key] != entry.value) return true;
    }
    return false;
  }

  Future<void> _pickType() async {
    final picked = await showWordTypePickerSheet(context, selected: _wordType);
    if (!mounted || picked == null || picked == _wordType) return;
    final currentType = widget.detail.entity['wordType']?.toString() ?? 'word';
    if (picked == 'word' &&
        currentType != 'word' &&
        _hasComponent(widget.detail.entity)) {
      await showAppErrorSheet(
        context,
        title: 'Jenis tidak bisa diubah',
        message: 'has_component hanya untuk entri idiom/peribahasa/ungkapan',
      );
      return;
    }
    final previous = _wordType;
    setState(() => _wordType = picked);
    final saved = await _save();
    if (!saved && mounted) setState(() => _wordType = previous);
  }

  Future<void> _pickClass(_MeaningClass meaning) async {
    final List<ReferenceItem> classes;
    try {
      classes = await ref.read(referenceWordClassesProvider.future);
    } catch (_) {
      if (mounted) {
        showFToast(
          context: context,
          title: const Text('Gagal memuat kelas kata'),
        );
      }
      return;
    }
    if (!mounted) return;
    final current = _classByIndex[meaning.index] ?? meaning.classId;
    final picked = await showWordClassPickerSheet(
      context,
      items: [
        for (final item in classes)
          WordClassPickItem(
            id: item.id,
            name: item.name,
            alias: item.alias,
            code: item.code,
          ),
      ],
      selectedId: current,
    );
    if (!mounted || picked == null) return;
    final previous = _classByIndex[meaning.index];
    final hadPrevious = _classByIndex.containsKey(meaning.index);
    setState(() {
      if (picked.id == meaning.classId) {
        _classByIndex.remove(meaning.index);
      } else {
        _classByIndex[meaning.index] = picked.id;
      }
    });
    final saved = await _save();
    if (!saved && mounted) {
      setState(() {
        if (hadPrevious && previous != null) {
          _classByIndex[meaning.index] = previous;
        } else {
          _classByIndex.remove(meaning.index);
        }
      });
    }
  }

  String _classLabel(List<ReferenceItem> classes, _MeaningClass meaning) {
    final id = _classByIndex[meaning.index] ?? meaning.classId;
    for (final item in classes) {
      if (item.id != id) continue;
      final alias = item.alias?.trim();
      if (alias != null && alias.isNotEmpty) return alias;
      return item.name;
    }
    return meaning.fallbackLabel;
  }

  Future<bool> _save() async {
    if (_busy || !_dirty) return !_busy;
    setState(() => _busy = true);
    var ok = false;
    final body = buildInlineWordCorrectBody(
      entity: widget.detail.entity,
      wordType: _wordType,
      wordClassByMeaningIndex: Map<int, String>.from(_classByIndex),
    );
    final result = await ref
        .read(reviewRepositoryProvider)
        .correct(widget.detail.contribution.id, body);
    if (!mounted) return false;
    setState(() => _busy = false);
    result.match(
      (failure) {
        showAppErrorSheet(context, message: failure.message);
      },
      (decision) {
        _savedType = _wordType;
        _savedClass
          ..clear()
          ..addAll(_classByIndex);
        ok = true;
        if (decision.status == 'pending') {
          ref.invalidate(reviewDetailProvider(widget.detail.contribution.id));
          showFToast(
            context: context,
            title: const Text('Koreksi disimpan. Usulan tetap menunggu.'),
          );
          return;
        }
        showFToast(
          context: context,
          title: const Text('Koreksi disimpan dan usulan ditutup.'),
        );
      },
    );
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final classes =
        ref.watch(referenceWordClassesProvider).asData?.value ?? const [];
    final meanings = _meaningClasses();

    return SwipeExemptRegion(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FTileGroup(
            children: [
              FTile(
                title: const Text('Jenis entri'),
                details: Text(wordTypeOptionLabel(_wordType)),
                suffix: Icon(
                  FLucideIcons.chevronRight,
                  color: theme.colors.mutedForeground,
                ),
                onPress: _busy ? null : _pickType,
              ),
              for (final meaning in meanings)
                FTile(
                  title: const Text('Kelas kata'),
                  subtitle:
                      meanings.length < 2 || meaning.definition.trim().isEmpty
                      ? null
                      : Text(meaning.definition.trim()),
                  details: Text(_classLabel(classes, meaning)),
                  suffix: Icon(
                    FLucideIcons.chevronRight,
                    color: theme.colors.mutedForeground,
                  ),
                  onPress: _busy ? null : () => _pickClass(meaning),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MeaningClass {
  const _MeaningClass({
    required this.index,
    required this.classId,
    required this.definition,
    required this.fallbackLabel,
  });

  final int index;
  final String classId;
  final String definition;
  final String fallbackLabel;
}

bool _hasComponent(Map<String, dynamic> entity) {
  final related = entity['relatedWords'];
  if (related is! List) return false;
  for (final raw in related) {
    if (raw is Map && raw['relationType'] == 'has_component') return true;
  }
  return false;
}
