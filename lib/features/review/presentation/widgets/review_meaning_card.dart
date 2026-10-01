import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../shared/reference/reference_data.dart';
import '../../../contribution/domain/meaning_source.dart';
import '../../data/review_correct_body.dart';

/// Contoh kalimat yang diedit di kartu makna.
class ReviewExampleDraft {
  ReviewExampleDraft({String source = '', String target = '', this.sourceIndex})
    : sourceCtrl = TextEditingController(text: source),
      targetCtrl = TextEditingController(text: target);

  final TextEditingController sourceCtrl;
  final TextEditingController targetCtrl;

  /// Posisi contoh asal di entity; null = contoh baru.
  final int? sourceIndex;

  CorrectExampleEdit toEdit() => (
    source: sourceCtrl.text,
    target: targetCtrl.text,
    sourceIndex: sourceIndex,
  );

  void dispose() {
    sourceCtrl.dispose();
    targetCtrl.dispose();
  }
}

/// Satu makna di form koreksi (definisi, terjemahan, kelas kata, contoh).
class ReviewMeaningDraft {
  ReviewMeaningDraft({
    String definition = '',
    String translation = '',
    this.wordClassId,
    this.initialMeaningSource = 'manual',
    this.sourceIndex,
    List<ReviewExampleDraft>? examples,
  }) : definitionCtrl = TextEditingController(text: definition),
       translationCtrl = TextEditingController(text: translation),
       examples = examples ?? [];

  final TextEditingController definitionCtrl;
  final TextEditingController translationCtrl;
  String? wordClassId;

  /// Source tersimpan di server (pertahankan jika tidak sentuh KBBI).
  final String initialMeaningSource;
  KbbiMeaningSnapshot? kbbiSnapshot;

  /// Posisi makna asal di entity; null = makna baru dari verifikator.
  final int? sourceIndex;
  final List<ReviewExampleDraft> examples;

  bool get hasWordClass => wordClassId?.trim().isNotEmpty ?? false;

  String resolveSource() {
    if (kbbiSnapshot == null) return initialMeaningSource;
    return resolveMeaningSource(
      snapshot: kbbiSnapshot,
      padanan: translationCtrl.text,
      definition: definitionCtrl.text,
      wordClassId: wordClassId,
    ).apiValue;
  }

  CorrectMeaningEdit toEdit({String? translationLanguageId}) => (
    sourceIndex: sourceIndex,
    definition: definitionCtrl.text,
    translation: translationCtrl.text,
    translationLanguageId: translationLanguageId,
    wordClassId: wordClassId,
    meaningSource: resolveSource(),
    examples: [for (final e in examples) e.toEdit()],
  );

  void dispose() {
    definitionCtrl.dispose();
    translationCtrl.dispose();
    for (final e in examples) {
      e.dispose();
    }
  }
}

/// Kartu satu makna: header (nomor, kelas kata, tukar, hapus), definisi,
/// terjemahan + KBBI, lalu daftar contoh kalimat.
class ReviewMeaningCard extends ConsumerWidget {
  const ReviewMeaningCard({
    super.key,
    required this.index,
    required this.draft,
    required this.busy,
    required this.showErrors,
    required this.onPickWordClass,
    required this.onSwap,
    required this.onKbbi,
    required this.onAddExample,
    required this.onRemoveExample,
    this.onRemove,
  });

  final int index;
  final ReviewMeaningDraft draft;
  final bool busy;
  final bool showErrors;
  final VoidCallback onPickWordClass;
  final VoidCallback onSwap;
  final VoidCallback onKbbi;
  final VoidCallback onAddExample;
  final void Function(int exampleIndex) onRemoveExample;

  /// null = makna terakhir (API mewajibkan minimal satu makna).
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final classes = ref.watch(referenceWordClassesProvider).asData?.value;
    final classLabel = classes == null
        ? null
        : wordClassNameFrom(classes, draft.wordClassId);
    final missingClass = showErrors && !draft.hasWordClass;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: missingClass ? theme.colors.destructive : theme.colors.border,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Makna ${index + 1}',
                  style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600),
                ),
                const Gap(8),
                Flexible(
                  child: GestureDetector(
                    onTap: busy ? null : onPickWordClass,
                    child: FBadge(
                      variant: draft.hasWordClass
                          ? FBadgeVariant.secondary
                          : FBadgeVariant.destructive,
                      child: Text(
                        draft.hasWordClass
                            ? (classLabel ?? 'Kelas kata')
                            : 'Pilih kelas kata',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                FButton.icon(
                  variant: FButtonVariant.ghost,
                  size: FButtonSizeVariant.sm,
                  semanticsLabel: 'Tukar definisi dan terjemahan',
                  onPress: busy ? null : onSwap,
                  child: const Icon(FLucideIcons.arrowUpDown),
                ),
                if (onRemove != null)
                  FButton.icon(
                    variant: FButtonVariant.ghost,
                    size: FButtonSizeVariant.sm,
                    semanticsLabel: 'Hapus makna ${index + 1}',
                    onPress: busy ? null : onRemove,
                    child: Icon(
                      FLucideIcons.trash2,
                      color: theme.colors.destructive,
                    ),
                  ),
              ],
            ),
            if (missingClass) ...[
              const Gap(4),
              Text(
                'Kelas kata wajib dipilih',
                style: theme.typography.xs.copyWith(color: theme.colors.destructive),
              ),
            ],
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Gap(8),
                  FTextField(
                    control: FTextFieldControl.managed(
                      controller: draft.definitionCtrl,
                    ),
                    enabled: !busy,
                    label: const Text('Definisi'),
                  ),
                  const Gap(8),
                  FTextField(
                    control: FTextFieldControl.managed(
                      controller: draft.translationCtrl,
                    ),
                    enabled: !busy,
                    label: const Text('Terjemahan'),
                    description: const Text(
                      'Tekan icon buku untuk mencari definisi di KBBI',
                    ),
                    // Label aksesibilitas ada di description field. Node tombol
                    // sendiri, saat kartu masih di bawah lipatan, dapat rect
                    // terbalik dari clip viewport dan menjatuhkan tes semantik.
                    suffixBuilder: (context, style, _) => ExcludeSemantics(
                      child: Padding(
                        padding: style.clearButtonPadding,
                        child: FButton.icon(
                          style: style.clearButtonStyle,
                          onPress: busy ? null : onKbbi,
                          child: const Icon(FLucideIcons.bookOpen),
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Text(
                    'Contoh kalimat',
                    style: theme.typography.xs.copyWith(
                      color: theme.colors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  for (var e = 0; e < draft.examples.length; e++) ...[
                    const Gap(8),
                    _ExampleRow(
                      draft: draft.examples[e],
                      busy: busy,
                      onRemove: () => onRemoveExample(e),
                    ),
                  ],
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: FButton(
                variant: FButtonVariant.ghost,
                size: FButtonSizeVariant.sm,
                onPress: busy ? null : onAddExample,
                prefix: const Icon(FLucideIcons.plus),
                child: const Text('Tambah contoh'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExampleRow extends StatelessWidget {
  const _ExampleRow({
    required this.draft,
    required this.busy,
    required this.onRemove,
  });

  final ReviewExampleDraft draft;
  final bool busy;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FTextField(
                control: FTextFieldControl.managed(controller: draft.sourceCtrl),
                enabled: !busy,
                hint: 'Kalimat Sambas',
                minLines: 1,
                maxLines: 3,
              ),
              const Gap(6),
              FTextField(
                control: FTextFieldControl.managed(controller: draft.targetCtrl),
                enabled: !busy,
                hint: 'Terjemahan (opsional)',
                minLines: 1,
                maxLines: 3,
              ),
            ],
          ),
        ),
        FButton.icon(
          variant: FButtonVariant.ghost,
          size: FButtonSizeVariant.sm,
          semanticsLabel: 'Hapus contoh',
          onPress: busy ? null : onRemove,
          child: const Icon(FLucideIcons.x),
        ),
      ],
    );
  }
}
