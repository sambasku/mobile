import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../shared/reference/reference_data.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../contribution/domain/meaning_source.dart';
import '../../../contribution/presentation/widgets/kbbi_definition_sheet.dart';
import '../../../contribution/presentation/widgets/word_class_picker_sheet.dart';
import '../../../dictionary/domain/entities/word_detail.dart';
import '../../../dictionary/presentation/utils/ensure_microphone_ready.dart';
import '../../../dictionary/presentation/widgets/record_pronunciation_sheet.dart';
import '../../data/review_correct_body.dart';
import '../../domain/entities/review_contribution.dart';
import '../../domain/failures/review_failure.dart';
import '../providers/review_providers.dart';
import 'review_meaning_card.dart';
import 'review_word_extras_sheets.dart';

/// Field id referensi yang diteruskan apa adanya saat submit - bukan input.
const carriedChildKeys = {'dialect_id', 'provider_file_id'};

/// Field yang boleh diedit user per tipe entity. Sengaja allowlist (bukan
/// "semua kunci dari payload") supaya payload baru tidak otomatis jadi input
/// mentah, dan id tidak pernah bisa diketik ulang.
Set<String> editableChildKeys(String entityType) => switch (entityType) {
  'pronunciation' => {'notation', 'value', 'audio_url', 'speaker_name', 'notes'},
  'word_image' => {'url', 'alt_text'},
  'word_audio' => {'speaker_name'},
  _ => {'source_sentence', 'target_sentence', 'source_type', 'notes'},
};

const _childFieldLabels = <String, String>{
  'notation': 'Notasi',
  'value': 'Pelafalan',
  'audio_url': 'URL audio',
  'speaker_name': 'Penutur',
  'notes': 'Catatan',
  'url': 'URL gambar',
  'alt_text': 'Teks alternatif',
  'source_sentence': 'Kalimat sambas',
  'target_sentence': 'Kalimat terjemahan',
  'source_type': 'Jenis sumber',
};

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

/// Kontribusi makna (bukan kata): satu makna + terjemahan lain yang dibawa.
class _MeaningEdit extends ReviewMeaningDraft {
  _MeaningEdit({
    super.definition,
    super.translation,
    this.languageId,
    super.wordClassId,
    super.initialMeaningSource,
    this.carriedTranslations = const [],
  });

  /// Bahasa terjemahan yang diedit form. Id tidak pernah jadi text field.
  final String? languageId;

  /// Terjemahan lain milik makna ini yang tidak diedit form. Wajib dikirim
  /// balik utuh: endpoint koreksi memakai semantik replace, jadi terjemahan
  /// yang tidak dikirim hilang dari makna. `translation_type` ikut dibawa
  /// karena 'direct' vs 'idiomatic' tidak bisa ditebak ulang dari teksnya.
  final List<_CarriedTranslation> carriedTranslations;

  /// Daftar lengkap translations[] untuk payload koreksi makna: yang diedit
  /// dulu, lalu yang dibawa apa adanya.
  List<Map<String, dynamic>> toTranslationPayload() {
    final id = languageId;
    if (id == null) {
      throw StateError('Koreksi makna butuh languageId terjemahan yang diedit');
    }
    return [
      {
        'language_id': id,
        'translation_text': translationCtrl.text.trim(),
        'translation_type': 'direct',
      },
      for (final t in carriedTranslations) t.toPayload(),
    ];
  }
}

/// Terjemahan yang ikut dikoreksi makna tanpa diedit di form.
class _CarriedTranslation {
  const _CarriedTranslation({
    required this.languageId,
    required this.translationText,
    required this.translationType,
    this.translationAllowsComma,
  });

  final String languageId;
  final String translationText;
  final String translationType;
  final bool? translationAllowsComma;

  Map<String, dynamic> toPayload() => {
    'language_id': languageId,
    'translation_text': translationText,
    'translation_type': translationType,
    // Tidak dikirim kalau tidak diketahui - server mempertahankan yang ada.
    if (translationAllowsComma != null)
      'translation_allows_comma': translationAllowsComma,
  };
}

class _ReviewCorrectFormState extends ConsumerState<ReviewCorrectForm> {
  final _lemma = TextEditingController();
  final _notes = TextEditingController();
  final _comment = TextEditingController();
  final _childFields = <String, TextEditingController>{};

  /// Field id referensi yang dibawa apa adanya saat submit. Tidak pernah jadi
  /// text field: kalau user mengetik ULID, nilainya bisa rusak permanen.
  final _carriedChildFields = <String, String>{};

  /// Jalur kata: seluruh makna (lama + baru) beserta contohnya.
  final _meanings = <ReviewMeaningDraft>[];

  /// Jalur kontribusi makna: satu makna.
  _MeaningEdit? _childMeaning;

  /// Semua relasi kata. Sheet hanya mengedit sinonim/antonim; tipe lain
  /// (mis. komponen peribahasa) wajib ikut terkirim karena koreksi = replace.
  var _relations = <ReviewRelatedWord>[];
  var _variants = <String>[];

  /// Rekaman pelafalan yang terkirim dari form ini (langsung tersimpan).
  int _recordedCount = 0;
  String _wordType = 'word';
  final _usageLabels = <String>{};
  bool _publish = true;
  bool _seeded = false;
  bool _busy = false;
  bool _childPrimary = false;
  bool _hasPrimary = false;

  /// Nyala setelah Simpan ditekan dengan field wajib kosong (inline error).
  bool _showErrors = false;

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
    _childMeaning?.dispose();
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
    _carriedChildFields.clear();
    for (final meaning in _meanings) {
      meaning.dispose();
    }
    _meanings.clear();
    _childMeaning?.dispose();
    _childMeaning = null;
    _relations = [];
    _variants = [];
    _recordedCount = 0;
    _usageLabels.clear();
    _lemma.clear();
    _notes.clear();
    _comment.clear();
    _wordType = 'word';
    _publish = true;
    _seeded = false;
    _childPrimary = false;
    _hasPrimary = false;
    _showErrors = false;
    _seed(widget.detail);
  }

  void _seed(ReviewDetail detail) {
    if (_seeded) return;
    _seeded = true;
    if (detail.contribution.entityType == 'word') {
      _lemma.text = detail.entity['lemma']?.toString() ?? '';
      _notes.text = detail.entity['notes']?.toString() ?? '';
      _wordType = detail.entity['wordType']?.toString() ?? 'word';
      _usageLabels
        ..clear()
        ..addAll(knownUsageLabels(detail.entity['usageLabels']));
      final meanings = detail.entity['meanings'];
      if (meanings is List) {
        for (var i = 0; i < meanings.length; i++) {
          final raw = meanings[i];
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
          final examples = <ReviewExampleDraft>[];
          final rawExamples = raw['examples'];
          if (rawExamples is List) {
            for (var e = 0; e < rawExamples.length; e++) {
              final example = rawExamples[e];
              if (example is! Map) continue;
              examples.add(
                ReviewExampleDraft(
                  source: example['sourceSentence']?.toString() ?? '',
                  target: example['targetSentence']?.toString() ?? '',
                  sourceIndex: e,
                ),
              );
            }
          }
          _meanings.add(
            ReviewMeaningDraft(
              definition: raw['definition']?.toString() ?? '',
              translation: first,
              wordClassId: wordClassId,
              initialMeaningSource:
                  raw['meaningSource']?.toString() ??
                  raw['meaning_source']?.toString() ??
                  'manual',
              sourceIndex: i,
              examples: examples,
            ),
          );
        }
      }
      final related = detail.entity['relatedWords'];
      if (related is List) {
        _relations = [
          for (final r in related.whereType<Map>())
            ReviewRelatedWord(
              wordId: r['wordId']?.toString() ?? '',
              lemma: r['lemma']?.toString() ?? '',
              relationType: r['relationType']?.toString() ?? '',
            ),
        ];
      }
      final variants = detail.entity['variants'];
      if (variants is List) {
        _variants = [
          for (final v in variants.whereType<Map>())
            if ((v['form']?.toString().trim() ?? '').isNotEmpty)
              v['form'].toString().trim(),
        ];
      }
      return;
    }
    // Kontribusi makna: payload review memakai snake_case dan hanya berisi
    // makna yang Contribution ini - bukan seluruh makna kata. Satu
    // _MeaningEdit, sisanya jadi terjemahan yang dibawa.
    if (detail.contribution.entityType == 'meaning') {
      final data = detail.entity['data'];
      if (data is! Map) return;
      final translations = <_CarriedTranslation>[];
      String? primaryText;
      String? primaryLanguageId;
      final rawTranslations = data['translations'];
      if (rawTranslations is List) {
        for (final raw in rawTranslations) {
          if (raw is! Map) continue;
          final languageId = raw['language_id']?.toString();
          final text = raw['translation_text']?.toString() ?? '';
          if (languageId == null || languageId.isEmpty) continue;
          if (primaryLanguageId == null) {
            primaryLanguageId = languageId;
            primaryText = text;
            continue;
          }
          final allowsComma = raw['translation_allows_comma'];
          translations.add(
            _CarriedTranslation(
              languageId: languageId,
              translationText: text,
              translationType:
                  raw['translation_type']?.toString() ?? 'direct',
              translationAllowsComma: allowsComma is bool ? allowsComma : null,
            ),
          );
        }
      }
      _childMeaning = _MeaningEdit(
        definition: data['definition']?.toString() ?? '',
        translation: primaryText ?? '',
        languageId: primaryLanguageId,
        wordClassId: data['word_class_id']?.toString(),
        initialMeaningSource: data['meaning_source']?.toString() ?? 'manual',
        carriedTranslations: translations,
      );
      return;
    }
    final data = detail.entity['data'];
    if (data is Map) {
      final editable = editableChildKeys(detail.contribution.entityType);
      for (final entry in data.entries) {
        final key = entry.key.toString();
        if (key == 'is_primary') {
          _hasPrimary = true;
          _childPrimary = entry.value == true;
          continue;
        }
        if (editable.contains(key)) {
          _childFields[key] = TextEditingController(
            text: entry.value?.toString() ?? '',
          );
          continue;
        }
        // Field id (dialect_id, provider_file_id) dan kunci yang tidak dikenal
        // tidak diedit user; id dibawa apa adanya agar tidak bisa rusak.
        if (carriedChildKeys.contains(key)) {
          final raw = entry.value?.toString().trim();
          if (raw != null && raw.isNotEmpty) _carriedChildFields[key] = raw;
        }
      }
    }
  }

  Future<void> _submit() async {
    if (_busy) return;
    final detail = widget.detail;
    final type = detail.contribution.entityType;
    if (type == 'word' && _meanings.any((m) => !m.hasWordClass)) {
      setState(() => _showErrors = true);
      return;
    }
    setState(() => _busy = true);
    final body = type == 'word'
        ? await _wordBody(detail)
        : _childBody(type);
    final result = await ref
        .read(reviewRepositoryProvider)
        .correct(detail.contribution.id, body);
    if (!mounted) return;
    setState(() => _busy = false);
    result.match(widget.onFailure, widget.onSuccess);
  }

  Future<Map<String, dynamic>> _wordBody(ReviewDetail detail) async {
    final languageId = _meanings.any((m) => m.sourceIndex == null)
        ? await _translationLanguageId(detail.entity)
        : null;
    return buildWordCorrectBody(
      entity: detail.entity,
      lemma: _lemma.text,
      notes: _notes.text,
      wordType: _wordType,
      usageLabels: [
        for (final code in kUsageLabels)
          if (_usageLabels.contains(code)) code,
      ],
      meanings: [
        for (final meaning in _meanings)
          meaning.toEdit(
            translationLanguageId: meaning.sourceIndex == null
                ? languageId
                : null,
          ),
      ],
      relatedWords: [
        for (final r in _relations)
          (wordId: r.wordId, relationType: r.relationType),
      ],
      variants: List.of(_variants),
      publish: _publish,
      comment: _comment.text,
    );
  }

  /// Bahasa terjemahan untuk makna baru: ikut terjemahan yang sudah ada di
  /// kata ini, kalau belum ada pakai Bahasa Indonesia dari data referensi.
  Future<String?> _translationLanguageId(Map<String, dynamic> entity) async {
    final meanings = entity['meanings'];
    if (meanings is List) {
      for (final meaning in meanings.whereType<Map>()) {
        final translations = meaning['translations'];
        if (translations is! List) continue;
        for (final t in translations.whereType<Map>()) {
          final id = t['languageId']?.toString();
          if (id != null && id.isNotEmpty) return id;
        }
      }
    }
    try {
      final languages = await ref.read(referenceLanguagesProvider.future);
      return findReferenceItem(languages, 'IDN')?.id;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _childBody(String entityType) {
    String? text(String key) {
      final value = _childFields[key]?.text.trim() ?? '';
      return value.isEmpty ? null : value;
    }

    // Id diteruskan apa adanya - tidak pernah melewati text field.
    String? carried(String key) {
      final value = _carriedChildFields[key];
      return (value == null || value.isEmpty) ? null : value;
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
        if (carried('dialect_id') != null) 'dialect_id': carried('dialect_id'),
        if (text('audio_url') != null) 'audio_url': text('audio_url'),
        if (text('speaker_name') != null) 'speaker_name': text('speaker_name'),
        if (text('notes') != null) 'notes': text('notes'),
      },
      'word_image' => {
        ...shared,
        'url': text('url') ?? '',
        'provider_file_id': carried('provider_file_id') ?? '',
        if (text('alt_text') != null) 'alt_text': text('alt_text'),
        'is_primary': _childPrimary,
      },
      'word_audio' => {
        ...shared,
        'is_primary': _childPrimary,
        if (carried('dialect_id') != null) 'dialect_id': carried('dialect_id'),
        if (text('speaker_name') != null) 'speaker_name': text('speaker_name'),
      },
      // Replace, bukan merge: daftar lengkap wajib dikirim. Terjemahan yang
      // tidak diedit ikut [_MeaningEdit.carriedTranslations].
      'meaning' => {
        ...shared,
        'definition': _childMeaning?.definitionCtrl.text.trim() ?? '',
        'word_class_id': _childMeaning?.wordClassId ?? '',
        'meaning_source': _childMeaning?.resolveSource() ?? 'manual',
        'translations': _childMeaning?.toTranslationPayload() ?? const [],
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
              else if (detail.contribution.entityType == 'meaning')
                ..._meaningChildFields()
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

  void _toggleUsageLabel(String code) {
    if (_busy) return;
    final selected = _usageLabels.contains(code);
    if (!selected) {
      if (hasConflictingUsageLabels({..._usageLabels, code})) {
        showFToast(
          context: context,
          title: const Text('Halus dan Kasar tidak bisa dipilih bersamaan'),
        );
        return;
      }
      setState(() => _usageLabels.add(code));
      return;
    }
    setState(() => _usageLabels.remove(code));
  }

  List<Widget> _wordFields() {
    final theme = context.theme;
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
      const Text('Register'),
      const Gap(4),
      Text(
        'Gaya atau pantangan berbahasa. Halus dan Kasar tidak bisa bersamaan.',
        style: theme.typography.sm.copyWith(color: theme.colors.mutedForeground),
      ),
      const Gap(6),
      _UsageLabelChips(
        options: kRegisterUsageLabels,
        selected: _usageLabels,
        enabled: !_busy,
        onToggle: _toggleUsageLabel,
      ),
      const Gap(12),
      const Text('Peringatan'),
      const Gap(4),
      Text(
        'Sensitivitas isi makna.',
        style: theme.typography.sm.copyWith(color: theme.colors.mutedForeground),
      ),
      const Gap(6),
      _UsageLabelChips(
        options: kWarningUsageLabels,
        selected: _usageLabels,
        enabled: !_busy,
        onToggle: _toggleUsageLabel,
      ),
      const Gap(20),
      const _SectionLabel('Makna'),
      const Gap(8),
      for (var i = 0; i < _meanings.length; i++) ...[
        ReviewMeaningCard(
          key: ObjectKey(_meanings[i]),
          index: i,
          draft: _meanings[i],
          busy: _busy,
          showErrors: _showErrors,
          onPickWordClass: () => _pickWordClass(_meanings[i]),
          onSwap: () => _swapMeaning(_meanings[i]),
          onKbbi: () => _openKbbi(_meanings[i]),
          onAddExample: () =>
              setState(() => _meanings[i].examples.add(ReviewExampleDraft())),
          onRemoveExample: (e) => setState(
            () => _disposeAfterFrame(_meanings[i].examples.removeAt(e).dispose),
          ),
          onRemove: _meanings.length > 1
              ? () => setState(
                  () => _disposeAfterFrame(_meanings.removeAt(i).dispose),
                )
              : null,
        ),
        const Gap(12),
      ],
      if (_meanings.length < _maxMeanings)
        FButton(
          variant: FButtonVariant.outline,
          onPress: _busy ? null : _addMeaning,
          prefix: const Icon(FLucideIcons.plus),
          child: const Text('Tambah makna'),
        ),
      const Gap(20),
      const _SectionLabel('Kelengkapan'),
      const Gap(8),
      FTileGroup(
        enabled: !_busy,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          FTile(
            prefix: const Icon(FLucideIcons.arrowLeftRight),
            title: const Text('Sinonim & antonim'),
            subtitle: Text(_relationSummary()),
            suffix: const Icon(FLucideIcons.chevronRight),
            onPress: _openRelations,
          ),
          FTile(
            prefix: const Icon(FLucideIcons.spellCheck),
            title: const Text('Variasi penulisan'),
            subtitle: Text(
              _variants.isEmpty ? 'Belum ada' : _variants.join(', '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            suffix: const Icon(FLucideIcons.chevronRight),
            onPress: _openVariants,
          ),
          FTile(
            prefix: const Icon(FLucideIcons.mic),
            title: const Text('Rekam pelafalan'),
            subtitle: Text(
              _recordedCount == 0
                  ? 'Langsung tersimpan, tidak menunggu tombol Simpan'
                  : '$_recordedCount rekaman baru terkirim',
            ),
            suffix: const Icon(FLucideIcons.chevronRight),
            onPress: _openRecord,
          ),
        ],
      ),
    ];
  }

  static bool _isSynAnt(ReviewRelatedWord r) =>
      r.relationType == 'synonym' || r.relationType == 'antonym';

  String _relationSummary() {
    final synonyms = _relations.where((r) => r.relationType == 'synonym').length;
    final antonyms = _relations.where((r) => r.relationType == 'antonym').length;
    if (synonyms == 0 && antonyms == 0) return 'Belum ada';
    return [
      if (synonyms > 0) '$synonyms sinonim',
      if (antonyms > 0) '$antonyms antonim',
    ].join(', ');
  }

  Future<void> _openRelations() => showReviewRelationsSheet(
    context,
    initial: _relations.where(_isSynAnt).toList(),
    excludeWordId: widget.detail.contribution.entityId,
    onChanged: (edited) => setState(
      () => _relations = [..._relations.where((r) => !_isSynAnt(r)), ...edited],
    ),
  );

  Future<void> _openVariants() => showReviewVariantsSheet(
    context,
    initial: _variants,
    lemma: _lemma.text,
    onChanged: (edited) => setState(() => _variants = List.of(edited)),
  );

  /// Audio langsung tersimpan lewat endpoint pelafalan (bukan payload koreksi):
  /// server menyimpan word_audios saat koreksi, jadi tidak ikut terhapus.
  Future<void> _openRecord() async {
    final languageId = widget.detail.entity['languageId']?.toString();
    if (languageId == null || languageId.isEmpty) {
      showFToast(context: context, title: const Text('Bahasa kata tidak diketahui'));
      return;
    }
    final micReady = await ensureMicrophoneReady(context);
    if (!mounted || !micReady) return;
    final auth = await ref.read(authStatusProvider.future);
    if (!mounted) return;
    final sent = await showRecordPronunciationSheet(
      context,
      ref: ref,
      wordId: widget.detail.contribution.entityId,
      languageId: languageId,
      defaultSpeakerName: displayPublicAccountLabel(
        displayName: auth.displayName,
        username: auth.username,
      ),
    );
    if (mounted && sent == true) setState(() => _recordedCount++);
  }

  /// Controller masih dipegang field sampai frame berikutnya selesai.
  void _disposeAfterFrame(VoidCallback dispose) =>
      WidgetsBinding.instance.addPostFrameCallback((_) => dispose());

  Future<void> _addMeaning() async {
    final draft = ReviewMeaningDraft();
    setState(() => _meanings.add(draft));
    await _pickWordClass(draft);
  }

  Future<void> _pickWordClass(ReviewMeaningDraft draft) async {
    final List<ReferenceItem> classes;
    try {
      classes = await ref.read(referenceWordClassesProvider.future);
    } catch (_) {
      if (mounted) {
        showFToast(context: context, title: const Text('Gagal memuat kelas kata'));
      }
      return;
    }
    if (!mounted) return;
    final picked = await showWordClassPickerSheet(
      context,
      items: [
        for (final c in classes)
          WordClassPickItem(id: c.id, name: c.name, alias: c.alias),
      ],
      selectedId: draft.wordClassId,
    );
    if (!mounted || picked == null) return;
    setState(() => draft.wordClassId = picked.id);
  }

  /// Kontribusi makna: hanya isi maknanya yang diedit - lemma, jenis entri,
  /// dan catatan kata milik kontribusi kata, bukan milik kartu ini.
  List<Widget> _meaningChildFields() {
    final meaning = _childMeaning;
    if (meaning == null) {
      return [
        const Text('Payload makna tidak memuat definisi atau terjemahan.'),
      ];
    }
    return [
      FTextField(
        control: FTextFieldControl.managed(controller: meaning.definitionCtrl),
        enabled: !_busy,
        label: const Text('Definisi'),
      ),
      const Gap(8),
      FTextField(
        control: FTextFieldControl.managed(controller: meaning.translationCtrl),
        enabled: !_busy,
        label: const Text('Terjemahan'),
        description: meaning.carriedTranslations.isEmpty
            ? const Text('Tekan icon buku untuk mencari definisi di KBBI')
            : Text(
                'Terjemahan lain milik makna ini (${meaning.carriedTranslations.length}) '
                'ikut tersimpan tanpa diubah.',
              ),
        suffixBuilder: (context, style, _) => Padding(
          padding: style.clearButtonPadding,
          // ponytail: ExcludeSemantics - SemanticsNode suffix bawaan
          // MergeSemantics forui 0.22 bisa ber-rect terbalik saat subtree
          // diswap (assert "Invisible SemanticsNodes",
          // duobaseio/forui#1160). Makna tombol ada di description field.
          child: ExcludeSemantics(
            child: FButton.icon(
              style: style.clearButtonStyle,
              onPress: _busy ? null : () => _openKbbi(meaning),
              child: const Icon(FLucideIcons.bookOpen),
            ),
          ),
        ),
      ),
      const Gap(12),
    ];
  }

  void _swapMeaning(ReviewMeaningDraft meaning) {
    final definition = meaning.definitionCtrl.text.trim();
    final translation = meaning.translationCtrl.text.trim();
    final definitionIsReal = definition.isNotEmpty && definition != '-';
    final translationIsReal = translation.isNotEmpty && translation != '-';
    meaning.definitionCtrl.text = translationIsReal ? translation : '-';
    meaning.translationCtrl.text = definitionIsReal ? definition : '';
    setState(() {});
  }

  Future<void> _openKbbi(ReviewMeaningDraft meaning) async {
    final current = meaning.translationCtrl.text.trim();
    final picked = await showKbbiDefinitionSheet(
      context,
      dio: ref.read(dioProvider),
      initialLemma: current == '-' ? '' : current,
    );
    if (!mounted || picked == null) return;
    final classes = await ref.read(referenceWordClassesProvider.future);
    if (!mounted) return;
    var matched = _matchReviewWordClass(classes, picked.wordClassCode);
    if (matched == null && (picked.wordClassLabel?.trim().isNotEmpty ?? false)) {
      matched = findReferenceItem(classes, picked.wordClassLabel)?.id;
    }
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

  List<Widget> _childForm() {
    return [
      for (final entry in _childFields.entries) ...[
        FTextField(
          control: FTextFieldControl.managed(controller: entry.value),
          enabled: !_busy,
          // Kunci tak dikenal tidak akan muncul: _childFields dibangun dari
          // allowlist, dan label selalu ada untuk tiap kunci therein.
          label: Text(_childFieldLabels[entry.key] ?? entry.key),
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

// ponytail: batas lokal supaya form tidak tak berujung; API tidak membatasi.
const _maxMeanings = 10;

/// Judul section form koreksi kata (Makna, Kelengkapan).
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Text(
      text,
      style: theme.typography.sm.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colors.foreground,
      ),
    );
  }
}

class _UsageLabelChips extends StatelessWidget {
  const _UsageLabelChips({
    required this.options,
    required this.selected,
    required this.enabled,
    required this.onToggle,
  });

  final List<String> options;
  final Set<String> selected;
  final bool enabled;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final code in options)
          GestureDetector(
            onTap: enabled ? () => onToggle(code) : null,
            child: FBadge(
              variant: selected.contains(code)
                  ? FBadgeVariant.primary
                  : FBadgeVariant.secondary,
              child: Text(usageLabelLabel(code)),
            ),
          ),
      ],
    );
  }
}

const _reviewWordTypes = <({String value, String label})>[
  (value: 'word', label: 'Kata'),
  (value: 'idiom', label: 'Idiom'),
  (value: 'peribahasa', label: 'Peribahasa'),
  (value: 'ungkapan', label: 'Ungkapan'),
];

/// KBBI menulis adjektiva sebagai "a", sedangkan kode internal memakai "adj".
String? _matchReviewWordClass(List<ReferenceItem> classes, String? code) {
  final normalized = code?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) return null;
  final direct = findReferenceItem(classes, normalized);
  if (direct != null) return direct.id;
  if (normalized == 'a') return findReferenceItem(classes, 'adj')?.id;
  return null;
}
