import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

/// Hasil bottomsheet kelengkapan opsional (variasi / sinonim / antonim / catatan).
class ContributeRelationsDraft {
  const ContributeRelationsDraft({
    this.variantsText = '',
    this.synonymsText = '',
    this.antonymsText = '',
    this.notesText = '',
  });

  final String variantsText;
  final String synonymsText;
  final String antonymsText;
  final String notesText;

  bool get isEmpty =>
      variantsText.trim().isEmpty &&
      synonymsText.trim().isEmpty &&
      antonymsText.trim().isEmpty &&
      notesText.trim().isEmpty;

  /// Ringkasan singkat untuk chip di form utama.
  String get summaryLabel {
    final parts = <String>[];
    final v = _commaCount(variantsText);
    final s = _commaCount(synonymsText);
    final a = _commaCount(antonymsText);
    if (v > 0) parts.add('$v variasi');
    if (s > 0) parts.add('$s sinonim');
    if (a > 0) parts.add('$a antonim');
    if (notesText.trim().isNotEmpty) parts.add('catatan');
    return parts.isEmpty ? 'Belum ada' : parts.join(' · ');
  }

  static int _commaCount(String raw) =>
      raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).length;
}

/// Bottom sheet isi kelengkapan opsional - form utama tetap slim (required only).
Future<ContributeRelationsDraft?> showContributeRelationsSheet(
  BuildContext context, {
  required ContributeRelationsDraft initial,
  required String lemma,
}) {
  return showModalBottomSheet<ContributeRelationsDraft>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      return _ContributeRelationsSheetBody(initial: initial, lemma: lemma);
    },
  );
}

class _ContributeRelationsSheetBody extends StatefulWidget {
  const _ContributeRelationsSheetBody({
    required this.initial,
    required this.lemma,
  });

  final ContributeRelationsDraft initial;
  final String lemma;

  @override
  State<_ContributeRelationsSheetBody> createState() =>
      _ContributeRelationsSheetBodyState();
}

class _ContributeRelationsSheetBodyState
    extends State<_ContributeRelationsSheetBody> {
  late final TextEditingController _variantsCtrl;
  late final TextEditingController _synonymsCtrl;
  late final TextEditingController _antonymsCtrl;
  late final TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _variantsCtrl = TextEditingController(text: widget.initial.variantsText);
    _synonymsCtrl = TextEditingController(text: widget.initial.synonymsText);
    _antonymsCtrl = TextEditingController(text: widget.initial.antonymsText);
    _notesCtrl = TextEditingController(text: widget.initial.notesText);
    _variantsCtrl.addListener(_onEdited);
    _synonymsCtrl.addListener(_onEdited);
    _antonymsCtrl.addListener(_onEdited);
  }

  void _onEdited() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _variantsCtrl.removeListener(_onEdited);
    _synonymsCtrl.removeListener(_onEdited);
    _antonymsCtrl.removeListener(_onEdited);
    _variantsCtrl.dispose();
    _synonymsCtrl.dispose();
    _antonymsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  List<String> _parseCsv(String raw) => raw
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);

  List<String> _fieldErrors({
    required String label,
    required String raw,
    required int maxItems,
  }) {
    final errors = <String>[];
    final items = _parseCsv(raw);
    if (items.length > maxItems) {
      errors.add('Maksimal $maxItems $label');
    }
    final lemma = widget.lemma.trim().toLowerCase();
    final seen = <String>{};
    for (final item in items) {
      final lower = item.toLowerCase();
      if (lemma.isNotEmpty && lower == lemma) {
        errors.add('"$item" sama dengan kata yang diusulkan');
      }
      if (!seen.add(lower)) {
        errors.add('"$item" tertulis lebih dari sekali');
      }
    }
    return errors;
  }

  List<String> _allErrors() {
    final errors = <String>[
      ..._fieldErrors(label: 'variasi', raw: _variantsCtrl.text, maxItems: 10),
      ..._fieldErrors(label: 'sinonim', raw: _synonymsCtrl.text, maxItems: 5),
      ..._fieldErrors(label: 'antonim', raw: _antonymsCtrl.text, maxItems: 5),
    ];
    final relatedTotal =
        _parseCsv(_synonymsCtrl.text).length +
        _parseCsv(_antonymsCtrl.text).length;
    if (relatedTotal > 5) {
      errors.add('Sinonim + antonim maksimal 5 total');
    }
    // Cross-duplikat antar sinonim/antonim
    final syn = _parseCsv(
      _synonymsCtrl.text,
    ).map((e) => e.toLowerCase()).toSet();
    for (final a in _parseCsv(_antonymsCtrl.text)) {
      if (syn.contains(a.toLowerCase())) {
        errors.add('"$a" tidak boleh sinonim dan antonim sekaligus');
      }
    }
    return errors;
  }

  void _save() {
    final errors = _allErrors();
    if (errors.isNotEmpty) {
      setState(() {});
      return;
    }
    Navigator.of(context).pop(
      ContributeRelationsDraft(
        variantsText: _variantsCtrl.text,
        synonymsText: _synonymsCtrl.text,
        antonymsText: _antonymsCtrl.text,
        notesText: _notesCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final media = MediaQuery.of(context);
    final height = (media.size.height - media.viewInsets.bottom) * 0.85;
    final errors = _allErrors();

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SizedBox(
        height: height.clamp(320.0, media.size.height),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  Icon(
                    FLucideIcons.link,
                    size: 18,
                    color: theme.colors.primary,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      'Kelengkapan opsional',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.lg.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                'Beberapa item: pisahkan dengan koma. Contoh: ketex, kettek, kete\'',
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  FTextField(
                    control: FTextFieldControl.managed(
                      controller: _variantsCtrl,
                    ),
                    label: const Text('Variasi penulisan'),
                    hint: "ketex, kettek, kete' - dipisah koma",
                    textInputAction: TextInputAction.next,
                  ),
                  const Gap(12),
                  FTextField(
                    control: FTextFieldControl.managed(
                      controller: _synonymsCtrl,
                    ),
                    label: const Text('Sinonim'),
                    hint: 'kata1, kata2 - dipisah koma',
                    textInputAction: TextInputAction.next,
                  ),
                  const Gap(12),
                  FTextField(
                    control: FTextFieldControl.managed(
                      controller: _antonymsCtrl,
                    ),
                    label: const Text('Antonim'),
                    hint: 'kata1, kata2 - dipisah koma',
                    textInputAction: TextInputAction.next,
                  ),
                  const Gap(12),
                  FTextField(
                    control: FTextFieldControl.managed(controller: _notesCtrl),
                    label: const Text('Catatan'),
                    hint: 'Contoh pemakaian, etimologi, dll.',
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    minLines: 1,
                  ),
                  if (errors.isNotEmpty) ...[
                    const Gap(12),
                    for (final e in errors)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          e,
                          style: theme.typography.body.sm.copyWith(
                            color: theme.colors.error,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: FButton(
                  onPress: errors.isEmpty ? _save : null,
                  child: const Text('Simpan'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
