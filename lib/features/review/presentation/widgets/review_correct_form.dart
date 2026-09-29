import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../contribution/domain/meaning_source.dart';
import '../../../contribution/presentation/widgets/kbbi_definition_sheet.dart';
import '../../data/review_correct_body.dart';
import '../../domain/entities/review_contribution.dart';
import '../../domain/failures/review_failure.dart';
import '../providers/review_providers.dart';

/// Form koreksi inline (dipakai di sesi review, bukan halaman terpisah).
class ReviewCorrectForm extends ConsumerStatefulWidget {
  const ReviewCorrectForm({
    super.key,
    required this.detail,
    required this.onSuccess,
    required this.onCancel,
    required this.onFailure,
  });

  final ReviewDetail detail;
  final void Function(ReviewDecisionResult decision) onSuccess;
  final VoidCallback onCancel;
  final void Function(ReviewFailure failure) onFailure;

  @override
  ConsumerState<ReviewCorrectForm> createState() => _ReviewCorrectFormState();
}

class _MeaningEdit {
  _MeaningEdit({
    required String definition,
    required String translation,
    this.wordClassId,
    this.initialMeaningSource = 'manual',
  }) : definitionCtrl = TextEditingController(text: definition),
       translationCtrl = TextEditingController(text: translation);

  final TextEditingController definitionCtrl;
  final TextEditingController translationCtrl;
  String? wordClassId;
  /// Source tersimpan di server (pertahankan jika tidak sentuh KBBI).
  final String initialMeaningSource;
  KbbiMeaningSnapshot? kbbiSnapshot;

  void dispose() {
    definitionCtrl.dispose();
    translationCtrl.dispose();
  }

  String resolveSource() {
    if (kbbiSnapshot == null) return initialMeaningSource;
    return resolveMeaningSource(
      snapshot: kbbiSnapshot,
      padanan: translationCtrl.text,
      definition: definitionCtrl.text,
      wordClassId: wordClassId,
    ).apiValue;
  }
}

class _ReviewCorrectFormState extends ConsumerState<ReviewCorrectForm> {
  final _lemma = TextEditingController();
  final _notes = TextEditingController();
  final _comment = TextEditingController();
  final _childFields = <String, TextEditingController>{};
  final _meanings = <_MeaningEdit>[];
  String _wordType = 'word';
  bool _publish = true;
  bool _seeded = false;
  bool _busy = false;
  bool _childPrimary = false;
  bool _hasPrimary = false;

  @override
  void dispose() {
    _lemma.dispose();
    _notes.dispose();
    _comment.dispose();
    for (final controller in _childFields.values) {
      controller.dispose();
    }
    for (final meaning in _meanings) {
      meaning.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ReviewCorrectForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detail.contribution.id != widget.detail.contribution.id) {
      _resetForNewDetail();
    }
  }

  void _resetForNewDetail() {
    for (final controller in _childFields.values) {
      controller.dispose();
    }
    _childFields.clear();
    for (final meaning in _meanings) {
      meaning.dispose();
    }
    _meanings.clear();
    _lemma.clear();
    _notes.clear();
    _comment.clear();
    _wordType = 'word';
    _publish = true;
    _seeded = false;
    _childPrimary = false;
    _hasPrimary = false;
    _seed(widget.detail);
  }

  void _seed(ReviewDetail detail) {
    if (_seeded) return;
    _seeded = true;
    if (detail.contribution.entityType == 'word') {
      _lemma.text = detail.entity['lemma']?.toString() ?? '';
      _notes.text = detail.entity['notes']?.toString() ?? '';
      _wordType = detail.entity['wordType']?.toString() ?? 'word';
      final meanings = detail.entity['meanings'];
      if (meanings is List) {
        for (final raw in meanings) {
          if (raw is! Map) continue;
          final translations = raw['translations'];
          final first =
              translations is List &&
                  translations.isNotEmpty &&
                  translations.first is Map
              ? translations.first['translationText']?.toString() ?? ''
              : '';
          final wordClass = raw['wordClass'];
          final wordClassId = wordClass is Map
              ? wordClass['id']?.toString()
              : null;
          _meanings.add(
            _MeaningEdit(
              definition: raw['definition']?.toString() ?? '',
              translation: first,
              wordClassId: wordClassId,
              initialMeaningSource:
                  raw['meaningSource']?.toString() ??
                  raw['meaning_source']?.toString() ??
                  'manual',
            ),
          );
        }
      }
      return;
    }
    final data = detail.entity['data'];
    if (data is Map) {
      for (final entry in data.entries) {
        if (entry.key == 'is_primary') {
          _hasPrimary = true;
          _childPrimary = entry.value == true;
          continue;
        }
        _childFields[entry.key.toString()] = TextEditingController(
          text: entry.value?.toString() ?? '',
        );
      }
    }
  }

  Future<void> _submit() async {
    if (_busy) return;
    final detail = widget.detail;
    final type = detail.contribution.entityType;
    if (type == 'meaning') return;
    setState(() => _busy = true);
    final body = type == 'word' ? _wordBody(detail) : _childBody(type);
    final result = await ref
        .read(reviewRepositoryProvider)
        .correct(detail.contribution.id, body);
    if (!mounted) return;
    setState(() => _busy = false);
    result.match(widget.onFailure, widget.onSuccess);
  }

  Map<String, dynamic> _wordBody(ReviewDetail detail) {
    return buildWordCorrectBody(
      entity: detail.entity,
      lemma: _lemma.text,
      notes: _notes.text,
      wordType: _wordType,
      meaningEdits: [
        for (final meaning in _meanings)
          (
            definition: meaning.definitionCtrl.text,
            translation: meaning.translationCtrl.text,
            wordClassId: meaning.wordClassId,
            meaningSource: meaning.resolveSource(),
          ),
      ],
      publish: _publish,
      comment: _comment.text,
    );
  }

  Map<String, dynamic> _childBody(String entityType) {
    String? text(String key) {
      final value = _childFields[key]?.text.trim() ?? '';
      return value.isEmpty ? null : value;
    }

    final comment = _comment.text.trim();
    final shared = <String, dynamic>{
      'entity_type': entityType,
      'publish': _publish,
      if (comment.isNotEmpty) 'comment': comment,
    };
    return switch (entityType) {
      'pronunciation' => {
        ...shared,
        'notation': text('notation') ?? 'ipa',
        'value': text('value') ?? '',
        if (text('dialect_id') != null) 'dialect_id': text('dialect_id'),
        if (text('audio_url') != null) 'audio_url': text('audio_url'),
        if (text('speaker_name') != null) 'speaker_name': text('speaker_name'),
        if (text('notes') != null) 'notes': text('notes'),
      },
      'word_image' => {
        ...shared,
        'url': text('url') ?? '',
        'provider_file_id': text('provider_file_id') ?? '',
        if (text('alt_text') != null) 'alt_text': text('alt_text'),
        'is_primary': _childPrimary,
      },
      'word_audio' => {
        ...shared,
        'is_primary': _childPrimary,
        if (text('dialect_id') != null) 'dialect_id': text('dialect_id'),
        if (text('speaker_name') != null) 'speaker_name': text('speaker_name'),
      },
      _ => {
        ...shared,
        'source_sentence': text('source_sentence') ?? '',
        if (text('target_sentence') != null)
          'target_sentence': text('target_sentence'),
        if (text('source_type') != null) 'source_type': text('source_type'),
        if (text('notes') != null) 'notes': text('notes'),
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    _seed(widget.detail);
    final detail = widget.detail;
    if (detail.contribution.entityType == 'meaning') {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Koreksi langsung tidak didukung untuk makna. Tolak usulan ini, lalu minta pengirim mengusulkan ulang.',
        ),
      );
    }

    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
            children: [
              if (detail.contribution.entityType == 'word')
                ..._wordFields()
              else
                ..._childForm(),
              const Gap(12),
              FTextField(
                control: FTextFieldControl.managed(controller: _comment),
                enabled: !_busy,
                label: const Text('Catatan (opsional)'),
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.background,
            border: Border(top: BorderSide(color: theme.colors.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Langsung terbitkan dan verifikasi'),
                      ),
                      FSwitch(
                        semanticsLabel: 'Langsung terbitkan dan verifikasi',
                        value: _publish,
                        enabled: !_busy,
                        onChange: (value) => setState(() => _publish = value),
                      ),
                    ],
                  ),
                  const Gap(12),
                  FButton(
                    onPress: _busy ? null : _submit,
                    prefix: _busy ? const FCircularProgress() : null,
                    child: Text(
                      _busy
                          ? 'Memproses…'
                          : _publish
                              ? 'Simpan dan terbitkan'
                              : 'Simpan, tetap menunggu',
                    ),
                  ),
                  const Gap(8),
                  FButton(
                    variant: FButtonVariant.outline,
                    onPress: _busy ? null : widget.onCancel,
                    child: const Text('Batal koreksi'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _wordFields() {
    return [
      FTextField(
        control: FTextFieldControl.managed(controller: _lemma),
        enabled: !_busy,
        label: const Text('Lemma'),
      ),
      const Gap(12),
      const Text('Jenis entri'),
      const Gap(6),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final opt in _reviewWordTypes)
            GestureDetector(
              onTap: _busy ? null : () => setState(() => _wordType = opt.value),
              child: FBadge(
                variant: _wordType == opt.value
                    ? FBadgeVariant.primary
                    : FBadgeVariant.secondary,
                child: Text(opt.label),
              ),
            ),
        ],
      ),
      const Gap(12),
      FTextField(
        control: FTextFieldControl.managed(controller: _notes),
        enabled: !_busy,
        label: const Text('Catatan kata'),
      ),
      const Gap(12),
      for (var i = 0; i < _meanings.length; i++) ...[
        Text('Makna ${i + 1}'),
        const Gap(6),
        FButton(
          variant: FButtonVariant.outline,
          onPress: _busy ? null : () => _swapMeaning(i),
          child: const Text('Tukar definisi dan terjemahan'),
        ),
        const Gap(8),
        FTextField(
          control: FTextFieldControl.managed(
            controller: _meanings[i].definitionCtrl,
          ),
          enabled: !_busy,
          label: const Text('Definisi'),
        ),
        const Gap(8),
        FTextField(
          control: FTextFieldControl.managed(
            controller: _meanings[i].translationCtrl,
          ),
          enabled: !_busy,
          label: const Text('Padanan'),
          description: const Text(
            'Tekan icon buku untuk mencari definisi di KBBI',
          ),
          suffixBuilder: (context, style, _) => Padding(
            padding: style.clearButtonPadding,
            child: FButton.icon(
              style: style.clearButtonStyle,
              onPress: _busy ? null : () => _openKbbi(i),
              child: Icon(
                FLucideIcons.bookOpen,
                semanticLabel: 'Ambil dari KBBI',
              ),
            ),
          ),
        ),
        const Gap(12),
      ],
    ];
  }

  void _swapMeaning(int index) {
    final meaning = _meanings[index];
    final definition = meaning.definitionCtrl.text.trim();
    final translation = meaning.translationCtrl.text.trim();
    final definitionIsReal = definition.isNotEmpty && definition != '-';
    final translationIsReal = translation.isNotEmpty && translation != '-';
    meaning.definitionCtrl.text = translationIsReal ? translation : '-';
    meaning.translationCtrl.text = definitionIsReal ? definition : '';
    setState(() {});
  }

  Future<void> _openKbbi(int index) async {
    final meaning = _meanings[index];
    final current = meaning.translationCtrl.text.trim();
    final picked = await showKbbiDefinitionSheet(
      context,
      dio: ref.read(dioProvider),
      initialLemma: current == '-' ? '' : current,
    );
    if (!mounted || picked == null) return;
    final classes = await _loadWordClasses();
    if (!mounted) return;
    final matched = _matchReviewWordClass(
      classes,
      picked.wordClassCode,
      picked.wordClassLabel,
    );
    setState(() {
      meaning.definitionCtrl.text = picked.definition;
      final lemma = picked.lemma.trim();
      if (lemma.isNotEmpty) meaning.translationCtrl.text = lemma;
      if (matched != null) meaning.wordClassId = matched;
      meaning.kbbiSnapshot = KbbiMeaningSnapshot(
        padanan: lemma,
        definition: picked.definition.trim(),
        wordClassId: matched,
      );
    });
    showFToast(
      context: context,
      title: const Text('Definisi diisi dari KBBI'),
    );
  }

  Future<List<_ReviewWordClass>> _loadWordClasses() async {
    final dio = ref.read(dioProvider);
    final resp = await dio.get<dynamic>('/api/v1/word-classes');
    final data = resp.data;
    if (data is! Map) return const [];
    final arr = data['data'];
    if (arr is! List) return const [];
    return [
      for (final raw in arr)
        if (raw is Map)
          _ReviewWordClass(
            id: raw['id']?.toString() ?? '',
            code: raw['code']?.toString() ?? '',
            name: raw['name']?.toString() ?? '',
          ),
    ].where((item) => item.id.isNotEmpty).toList(growable: false);
  }

  List<Widget> _childForm() {
    const labels = <String, String>{
      'notation': 'Notasi',
      'value': 'Pelafalan',
      'dialect_id': 'Dialek',
      'audio_url': 'URL audio',
      'speaker_name': 'Penutur',
      'notes': 'Catatan',
      'url': 'URL gambar',
      'provider_file_id': 'Berkas gambar',
      'alt_text': 'Teks alternatif',
      'source_sentence': 'Kalimat sumber',
      'target_sentence': 'Kalimat terjemahan',
      'source_type': 'Sumber',
    };
    return [
      for (final entry in _childFields.entries) ...[
        FTextField(
          control: FTextFieldControl.managed(controller: entry.value),
          enabled: !_busy,
          label: Text(labels[entry.key] ?? entry.key),
        ),
        const Gap(12),
      ],
      if (_hasPrimary)
        Row(
          children: [
            const Expanded(child: Text('Utama')),
            FSwitch(
              semanticsLabel: 'Utama',
              value: _childPrimary,
              enabled: !_busy,
              onChange: (value) => setState(() => _childPrimary = value),
            ),
          ],
        ),
    ];
  }
}

const _reviewWordTypes = <({String value, String label})>[
  (value: 'word', label: 'Kata'),
  (value: 'idiom', label: 'Idiom'),
  (value: 'peribahasa', label: 'Peribahasa'),
  (value: 'ungkapan', label: 'Ungkapan'),
];

class _ReviewWordClass {
  const _ReviewWordClass({
    required this.id,
    required this.code,
    required this.name,
  });

  final String id;
  final String code;
  final String name;
}

String? _matchReviewWordClass(
  List<_ReviewWordClass> classes,
  String? code,
  String? label,
) {
  final normalizedCode = code?.trim().toLowerCase();
  if (normalizedCode != null && normalizedCode.isNotEmpty) {
    final byCode = classes
        .where((item) => item.code.toLowerCase() == normalizedCode)
        .firstOrNull;
    if (byCode != null) return byCode.id;
    if (normalizedCode == 'a') {
      final adj = classes
          .where((item) => item.code.toLowerCase() == 'adj')
          .firstOrNull;
      if (adj != null) return adj.id;
    }
  }
  final normalizedLabel = label?.trim().toLowerCase();
  if (normalizedLabel == null || normalizedLabel.isEmpty) return null;
  return classes
      .where((item) => item.name.toLowerCase() == normalizedLabel)
      .firstOrNull
      ?.id;
}
