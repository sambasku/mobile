import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../my_contributions/presentation/providers/my_contributions_providers.dart';
import '../../../contribution/presentation/widgets/contribute_images_field.dart';
import '../../../contribution/presentation/widgets/kbbi_definition_sheet.dart';
import '../../../contribution/presentation/widgets/word_class_picker_sheet.dart';
import '../../../dictionary/domain/entities/word_detail.dart';
import '../../../dictionary/presentation/providers/word_detail_providers.dart';
import '../../domain/suggest_category.dart';
import '../../domain/suggest_edit_feedback.dart';
import '../widgets/word_change_history_section.dart';

/// Form usul perubahan: pilih kategori dulu, lalu isi field kategori itu saja.
/// Draft tiap kategori tetap di memori selama halaman terbuka.
class SuggestEditPage extends ConsumerStatefulWidget {
  const SuggestEditPage({
    super.key,
    required this.wordId,
    this.initialCategory,
  });

  final String wordId;

  /// Kategori yang langsung terpilih, mis. saat dibuka dari form tinjau
  /// dengan `?category=add_meaning`. Kalau kategori ini tidak tersedia untuk
  /// kata tersebut, daftar kategori tetap ditampilkan.
  final SuggestCategory? initialCategory;

  @override
  ConsumerState<SuggestEditPage> createState() => _SuggestEditPageState();
}

class _SuggestEditPageState extends ConsumerState<SuggestEditPage> {
  SuggestCategory? _category;
  String? _meaningId;
  bool _prefilled = false;
  bool _submitting = false;
  Map<String, String> _fieldErrors = const {};

  // Ubah makna / kelas kata (makna terpilih).
  final _definitionCtrl = TextEditingController();
  final _padananCtrl = TextEditingController();
  String? _wordClassId;

  // Tambah makna.
  final _addDefinitionCtrl = TextEditingController();
  final _addPadananCtrl = TextEditingController();
  String? _addWordClassId;

  // Tambah contoh.
  final _sentenceCtrl = TextEditingController();
  final _sentenceTranslationCtrl = TextEditingController();

  // Foto.
  List<ContributeImageSlot> _addImages = [];
  List<ContributeImageSlot> _replacementImages = [];
  final Set<String> _removeImageIds = {};
  String? _setPrimaryImageId;

  // Relasi + variasi.
  final _synonymCtrl = TextEditingController();
  final _antonymCtrl = TextEditingController();
  final Set<String> _removeRelationIds = {};
  final _variantCtrl = TextEditingController();
  final Map<String, String> _removeVariants = {};

  // Lainnya.
  final _lemmaCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  final _reasonTextCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _definitionCtrl,
      _padananCtrl,
      _addDefinitionCtrl,
      _addPadananCtrl,
      _sentenceCtrl,
      _sentenceTranslationCtrl,
      _synonymCtrl,
      _antonymCtrl,
      _variantCtrl,
      _lemmaCtrl,
      _notesCtrl,
      _reasonTextCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  WordMeaning? _meaningOf(WordDetail detail) =>
      detail.meanings.where((m) => m.id == _meaningId).firstOrNull ??
      detail.meanings.firstOrNull;

  static String _padananOf(WordMeaning m) => m.translations.firstOrNull?.text ?? '';

  void _selectMeaning(WordMeaning m) {
    _meaningId = m.id;
    _definitionCtrl.text = m.definition ?? '';
    _padananCtrl.text = _padananOf(m);
    _wordClassId = m.wordClassId;
  }

  void _prefillOnce(WordDetail detail) {
    if (_prefilled) return;
    _prefilled = true;
    _lemmaCtrl.text = detail.lemma;
    _notesCtrl.text = detail.notes ?? '';
    final first = detail.meanings.firstOrNull;
    if (first != null) _selectMeaning(first);
    _applyInitialCategory(detail);
  }

  void _applyInitialCategory(WordDetail detail) {
    final requested = widget.initialCategory;
    if (requested == null) return;
    // Kalau kategori tidak punya sasaran di kata ini (mis. "Ubah foto"
    // pada kata tanpa foto), tetap tampilkan daftar - jangan buka form
    // yang tidak pernah bisa dipilih dari daftar.
    final available = availableSuggestCategories(
      hasMeaning: detail.meanings.isNotEmpty,
      hasImage: detail.images.isNotEmpty,
    );
    if (!available.contains(requested)) return;
    _category = requested;
  }

  Future<String?> _resolveLemmaId(Dio dio, String lemma, String excludeId) async {
    final res = await dio.get<Map<String, dynamic>>(
      '/api/v1/words/search',
      queryParameters: {'q': lemma, 'limit': 10},
    );
    final data = res.data?['data'];
    if (data is! List) return null;
    for (final item in data) {
      if (item is! Map) continue;
      final id = item['id'] as String?;
      final l = (item['lemma'] as String?)?.trim().toLowerCase();
      if (id != null && id != excludeId && l == lemma.trim().toLowerCase()) {
        return id;
      }
    }
    return null;
  }

  Future<String?> _resolveIdnLanguageId(Dio dio, WordMeaning? meaning) async {
    final known = meaning?.translations.firstOrNull?.languageId;
    if (known != null && known.isNotEmpty) return known;
    final res = await dio.get<Map<String, dynamic>>(
      '/api/v1/languages',
      queryParameters: {'is_active': true},
    );
    final data = res.data?['data'];
    if (data is! List) return null;
    for (final item in data) {
      if (item is! Map) continue;
      if (item['code']?.toString().toUpperCase() == 'IDN') return item['id']?.toString();
    }
    return null;
  }

  Future<void> _pickWordClass(List<_RefItem> items, {required bool forAdd}) async {
    final picked = await showWordClassPickerSheet(
      context,
      items: [
        for (final e in items) WordClassPickItem(id: e.id, name: e.name, alias: e.alias),
      ],
      selectedId: forAdd ? _addWordClassId : _wordClassId,
    );
    if (!mounted || picked == null) return;
    setState(() => forAdd ? _addWordClassId = picked.id : _wordClassId = picked.id);
  }

  Future<void> _pickMeaning(WordDetail detail) async {
    final picked = await showModalBottomSheet<WordMeaning>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: FTileGroup(
            label: const Text('Pilih makna'),
            children: [
              for (final m in detail.meanings)
                FTile(
                  title: Text(_meaningLabel(m), maxLines: 2, overflow: TextOverflow.ellipsis),
                  suffix: m.id == _meaningOf(detail)?.id ? const Icon(FLucideIcons.check, size: 18) : null,
                  onPress: () => Navigator.of(sheetContext).pop(m),
                ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || picked == null) return;
    setState(() => _selectMeaning(picked));
  }

  static String _meaningLabel(WordMeaning m) {
    final code = m.wordClassCode?.trim();
    final text = _padananOf(m).isNotEmpty ? _padananOf(m) : (m.definition ?? '-');
    return (code == null || code.isEmpty) ? text : '$code. $text';
  }

  Future<void> _openKbbiSheet({required bool forAdd}) async {
    final dio = ref.read(dioProvider);
    final padCtrl = forAdd ? _addPadananCtrl : _padananCtrl;
    final picked = await showKbbiDefinitionSheet(
      context,
      dio: dio,
      initialLemma: padCtrl.text.trim().isNotEmpty ? padCtrl.text.trim() : _lemmaCtrl.text.trim(),
    );
    if (!mounted || picked == null) return;
    final classes = ref.read(_suggestWordClassesProvider).value ?? const <_RefItem>[];
    // Ubah makna tidak boleh membawa kelas kata (kategori sendiri).
    final matched = forAdd ? _matchWordClassId(classes, picked.wordClassCode, picked.wordClassLabel) : null;
    setState(() {
      (forAdd ? _addDefinitionCtrl : _definitionCtrl).text = picked.definition;
      if (picked.lemma.trim().isNotEmpty) padCtrl.text = picked.lemma.trim();
      if (matched != null) _addWordClassId = matched;
    });
  }

  Future<void> _showError(String message, {String title = 'Terjadi kesalahan'}) =>
      showAppErrorSheet(context, message: message, title: title);

  /// Susun proposed_changes kategori aktif. `null` = belum ada perubahan;
  /// [StateError] = isian tidak bisa dipakai (pesan untuk user).
  Future<Map<String, dynamic>?> _buildProposed(WordDetail detail, Dio dio) async {
    final meaning = _meaningOf(detail);
    switch (_category!) {
      case SuggestCategory.changeMeaning:
        final padChanged = _padananCtrl.text.trim() != _padananOf(meaning!);
        return buildChangeMeaning(
          meaningId: meaning.id,
          originalDefinition: meaning.definition ?? '',
          definition: _definitionCtrl.text,
          originalPadanan: _padananOf(meaning),
          padanan: _padananCtrl.text,
          padananLanguageId: padChanged ? await _resolveIdnLanguageId(dio, meaning) : null,
        );
      case SuggestCategory.changeWordClass:
        return buildChangeWordClass(
          meaningId: meaning!.id,
          originalWordClassId: meaning.wordClassId,
          wordClassId: _wordClassId,
        );
      case SuggestCategory.addMeaning:
        return buildAddMeaning(
          wordClassId: _addWordClassId,
          definition: _addDefinitionCtrl.text,
          padanan: _addPadananCtrl.text,
          padananLanguageId: _addPadananCtrl.text.trim().isEmpty
              ? null
              : await _resolveIdnLanguageId(dio, meaning),
        );
      case SuggestCategory.addPhoto:
        final images = _imageAdds(_addImages);
        return images.isEmpty ? null : {'images': images};
      case SuggestCategory.changePhoto:
        final images = [
          for (final id in _removeImageIds) {'action': 'remove', 'image_id': id},
          if (_setPrimaryImageId != null && !_removeImageIds.contains(_setPrimaryImageId))
            {'action': 'set_primary', 'image_id': _setPrimaryImageId},
          ..._imageAdds(_replacementImages),
        ];
        final touchesExisting = images.any((i) => i['action'] != 'add');
        return touchesExisting ? {'images': images} : null;
      case SuggestCategory.synonym:
      case SuggestCategory.antonym:
        final type = _category!.code;
        final ctrl = type == 'synonym' ? _synonymCtrl : _antonymCtrl;
        final ids = <String>[];
        for (final lemma in splitCsv(ctrl.text)) {
          final id = await _resolveLemmaId(dio, lemma, detail.id);
          if (id == null) {
            throw StateError('"$lemma" belum ada di kamus. Tulis lemma kata yang sudah ada.');
          }
          ids.add(id);
        }
        return buildRelations(
          relationType: type,
          addWordIds: ids,
          removeWordIds: _removeRelationIds
              .where((k) => k.startsWith('$type|'))
              .map((k) => k.substring(type.length + 1)),
        );
      case SuggestCategory.spellingVariant:
        return buildVariants(
          lemma: detail.lemma,
          existingForms: detail.variants.map((v) => v.form),
          addForms: splitCsv(_variantCtrl.text),
          removeFormTypes: _removeVariants,
        );
      case SuggestCategory.lemmaNotes:
        return buildLemmaNotes(
          originalLemma: detail.lemma,
          lemma: _lemmaCtrl.text,
          originalNotes: detail.notes ?? '',
          notes: _notesCtrl.text,
        );
      case SuggestCategory.addExample:
        throw StateError('Tambah contoh tidak lewat suggest-edit');
    }
  }

  List<Map<String, dynamic>> _imageAdds(List<ContributeImageSlot> slots) => [
        for (final slot in slots)
          if (slot.isReady && slot.uploaded != null)
            {
              'action': 'add',
              'url': slot.uploaded!.url,
              'provider_file_id': slot.uploaded!.providerFileId,
              'provider': ?slot.uploaded!.provider,
              'sha': ?slot.uploaded!.sha,
              'alt_text': slot.uploaded!.altText,
              'is_primary': slot.uploaded!.isPrimary,
            },
      ];

  Future<void> _submit(WordDetail detail) async {
    if (_submitting || _category == null) return;
    setState(() {
      _submitting = true;
      _fieldErrors = const {};
    });
    final dio = ref.read(dioProvider);
    try {
      if (_category == SuggestCategory.addExample) {
        await _submitExample(detail, dio);
        return;
      }
      final proposed = await _buildProposed(detail, dio);
      if (!mounted) return;
      if (proposed == null) {
        await _showError(
          'Belum ada yang diubah untuk ${_category!.label.toLowerCase()}.',
          title: 'Belum ada perubahan',
        );
        return;
      }
      final reasonText = _reasonTextCtrl.text.trim();
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/words/${widget.wordId}/suggest-edit',
        data: {
          'proposed_changes': proposed,
          'reason_code': _category!.code,
          if (reasonText.isNotEmpty) 'reason_text': reasonText,
        },
      );
      if (!mounted) return;
      AnalyticsService.instance.log(
        AnalyticsEvents.suggestEditSubmit,
        params: {'word_id': widget.wordId, 'category': _category!.code},
      );
      final selfApplied = suggestEditWasSelfApplied(
        responseStatus: suggestEditStatusFromResponse(response.data),
        actorRole: ref.read(authStatusProvider).value?.role,
      );
      showFToast(
        context: context,
        title: Text(
          suggestEditSuccessToast(
            selfApplied: selfApplied,
            wordVerified: detail.isVerified,
            lemma: detail.lemma,
          ),
        ),
      );
      ref.invalidate(wordDetailProvider(widget.wordId));
      ref.invalidate(changeHistoryProvider(widget.wordId));
      final router = GoRouter.of(context);
      router.pop();
      if (!selfApplied) {
        ref.invalidate(myContributionsListControllerProvider);
        router.push('/contributions');
      }
    } on DioException catch (e) {
      await _handleDioError(e);
    } on StateError catch (e) {
      if (mounted) await _showError(e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submitExample(WordDetail detail, Dio dio) async {
    final meaning = _meaningOf(detail)!;
    final sentence = _sentenceCtrl.text.trim();
    final translation = _sentenceTranslationCtrl.text.trim();
    if (sentence.isEmpty) {
      setState(() => _fieldErrors = {'sentence': 'Contoh kalimat wajib diisi'});
      return;
    }
    final targetLang = translation.isEmpty ? null : await _resolveIdnLanguageId(dio, meaning);
    final res = await dio.post<Map<String, dynamic>>(
      '/api/v1/meanings/${meaning.id}/examples',
      data: {
        'source_language_id': detail.languageId,
        'source_sentence': sentence,
        if (targetLang != null) ...{
          'target_language_id': targetLang,
          'target_sentence': translation,
        },
      },
    );
    if (!mounted) return;
    final status = (res.data?['data'] as Map?)?['status'];
    showFToast(
      context: context,
      title: Text(
        status == 'published'
            ? 'Contoh kalimat sudah tayang.'
            : 'Contoh kalimat masuk antrean pengecekan.',
      ),
    );
    ref.invalidate(wordDetailProvider(widget.wordId));
    GoRouter.of(context).pop();
  }

  Future<void> _handleDioError(DioException e) async {
    if (!mounted) return;
    final data = e.response?.data;
    final code = data is Map ? data['error_code'] as String? : null;
    final message = data is Map && data['message'] is String
        ? data['message'] as String
        : 'Gagal mengirim usulan. Periksa koneksi lalu coba lagi.';

    if (code == 'RATE_LIMITED') {
      showFToast(context: context, title: Text(message));
      return;
    }
    if (code == 'VALIDATION_ERROR' && data is Map && data['details'] is List) {
      final inline = <String, String>{};
      String? unmapped;
      for (final d in (data['details'] as List).whereType<Map>()) {
        final key = suggestFieldKey(d['field']?.toString() ?? '');
        final msg = d['message']?.toString() ?? message;
        if (key == null) {
          unmapped ??= msg;
        } else {
          inline.putIfAbsent(key, () => msg);
        }
      }
      setState(() => _fieldErrors = inline);
      if (unmapped != null) await _showError(unmapped, title: 'Periksa lagi isian');
      return;
    }
    if (code == 'SUGGESTION_STALE_DATA') {
      // Foto/makna yang ditandai bisa sudah hilang: muat ulang, kosongkan tanda.
      setState(() {
        _removeImageIds.clear();
        _setPrimaryImageId = null;
        _removeRelationIds.clear();
        _removeVariants.clear();
      });
      ref.invalidate(wordDetailProvider(widget.wordId));
    }
    await _showError(
      message,
      title: code == 'SUGGESTION_ALREADY_PENDING' ? 'Usulan masih menunggu' : 'Terjadi kesalahan',
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStatusProvider).value;
    final detailAsync = ref.watch(wordDetailProvider(widget.wordId));

    if (auth?.isAuth != true) {
      return FScaffold(
        header: FHeader.nested(
          title: const Text('Usulkan Perubahan'),
          prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        ),
        child: Center(
          child: FButton(
            onPress: () => context.push('/login'),
            child: const Text('Masuk dulu untuk mengusulkan'),
          ),
        ),
      );
    }

    final preSubmit = suggestEditPreSubmitCopy(auth?.role);
    // Judul halaman ikut tile detail kata - satu sumber, supaya "Lengkapi
    // kata" di tile tidak membuka halaman bertajuk "Ubah Kata".
    final headerTitle = suggestEditEntryTileCopy(auth?.role).title;
    final isExample = _category == SuggestCategory.addExample;

    return FScaffold(
      header: FHeader.nested(
        title: Text(headerTitle),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      footer: _category == null
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: FButton(
                  onPress: _submitting
                      ? null
                      : () {
                          final d = detailAsync.asData?.value;
                          if (d != null) _submit(d);
                        },
                  prefix: _submitting ? const FCircularProgress() : null,
                  child: Text(
                    _submitting
                        ? preSubmit.ctaBusy
                        : (isExample ? 'Kirim contoh' : preSubmit.cta),
                  ),
                ),
              ),
            ),
      child: detailAsync.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (e, _) => Center(child: Text('$e')),
        data: (detail) {
          _prefillOnce(detail);
          return _category == null
              ? _buildCategoryList(detail, preSubmit.banner)
              : _buildCategoryForm(detail);
        },
      ),
    );
  }

  Widget _buildCategoryList(WordDetail detail, String banner) {
    final theme = context.theme;
    final categories = availableSuggestCategories(
      hasMeaning: detail.meanings.isNotEmpty,
      hasImage: detail.images.isNotEmpty,
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      children: [
        Text(banner, style: theme.typography.sm.copyWith(color: theme.colors.mutedForeground)),
        const Gap(12),
        FTileGroup(
          label: const Text('Apa yang ingin diubah?'),
          children: [
            for (final c in categories)
              FTile(
                title: Text(c.label),
                subtitle: Text(c.description),
                suffix: Icon(FLucideIcons.chevronRight, size: 16, color: theme.colors.mutedForeground),
                onPress: () => setState(() {
                  _category = c;
                  _fieldErrors = const {};
                }),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryForm(WordDetail detail) {
    final theme = context.theme;
    final category = _category!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      children: [
        FTile(
          title: Text(category.label),
          subtitle: const Text('Ketuk untuk ganti jenis usulan'),
          suffix: Icon(FLucideIcons.chevronsUpDown, size: 16, color: theme.colors.mutedForeground),
          onPress: () => setState(() => _category = null),
        ),
        const Gap(12),
        if (category.needsMeaning && detail.meanings.length > 1) ...[
          const _FieldCaption('Makna'),
          _SelectField(
            selectedLabel: _meaningLabel(_meaningOf(detail)!),
            hint: 'Pilih makna',
            onTap: () => _pickMeaning(detail),
          ),
          const Gap(12),
        ],
        ..._sectionFor(category, detail),
        if (category != SuggestCategory.addExample) ...[
          const Gap(12),
          FTextField(
            control: FTextFieldControl.managed(controller: _reasonTextCtrl),
            label: const Text('Alasan (opsional)'),
            hint: 'Contoh: sumber, penutur asli, atau KBBI',
            error: _errorText('reason'),
            maxLines: 3,
            minLines: 2,
          ),
        ],
      ],
    );
  }

  Widget? _errorText(String key) {
    final msg = _fieldErrors[key];
    return msg == null ? null : Text(msg);
  }

  List<Widget> _sectionFor(SuggestCategory category, WordDetail detail) {
    switch (category) {
      case SuggestCategory.changeMeaning:
        return [
          _padananField(_padananCtrl, forAdd: false),
          const Gap(8),
          _definitionField(_definitionCtrl),
        ];
      case SuggestCategory.changeWordClass:
        return [_wordClassField(forAdd: false)];
      case SuggestCategory.addMeaning:
        return [
          _wordClassField(forAdd: true),
          const Gap(8),
          _padananField(_addPadananCtrl, forAdd: true),
          const Gap(8),
          _definitionField(_addDefinitionCtrl),
        ];
      case SuggestCategory.addExample:
        return [
          FTextField(
            control: FTextFieldControl.managed(controller: _sentenceCtrl),
            label: Text('Contoh kalimat (${detail.lemma})'),
            hint: 'Kalimat dalam bahasa Sambas',
            error: _errorText('sentence'),
            maxLines: 3,
            minLines: 2,
          ),
          const Gap(8),
          FTextField(
            control: FTextFieldControl.managed(controller: _sentenceTranslationCtrl),
            label: const Text('Artinya (opsional)'),
            hint: 'Terjemahan bahasa Indonesia',
            error: _errorText('sentence_translation'),
            maxLines: 3,
            minLines: 2,
          ),
        ];
      case SuggestCategory.addPhoto:
        return [
          ContributeImagesField(
            enabled: true,
            images: _addImages,
            onChanged: (next) => setState(() => _addImages = next),
          ),
        ];
      case SuggestCategory.changePhoto:
        return [
          const _FieldCaption('Foto yang ada'),
          for (final img in detail.images) _existingImageRow(img),
          const Gap(8),
          const _FieldCaption(
            'Foto pengganti (opsional)',
            info: 'Tambahkan bila foto yang dihapus perlu diganti.',
          ),
          ContributeImagesField(
            enabled: true,
            images: _replacementImages,
            onChanged: (next) => setState(() => _replacementImages = next),
          ),
        ];
      case SuggestCategory.synonym:
      case SuggestCategory.antonym:
        final type = category.code;
        final existing = detail.relatedWords.where((r) => r.relationType == type).toList();
        return [
          FTextField(
            control: FTextFieldControl.managed(
              controller: type == 'synonym' ? _synonymCtrl : _antonymCtrl,
            ),
            label: Text('Tambah ${category.label.toLowerCase()}'),
            hint: 'Lemma yang sudah ada, pisahkan dengan koma',
          ),
          if (existing.isNotEmpty) ...[
            const Gap(12),
            _FieldCaption('Hapus ${category.label.toLowerCase()} yang ada'),
            for (final r in existing)
              _removeCheckbox(
                label: r.lemma,
                value: _removeRelationIds.contains('$type|${r.wordId}'),
                onChange: (v) => setState(() => v
                    ? _removeRelationIds.add('$type|${r.wordId}')
                    : _removeRelationIds.remove('$type|${r.wordId}')),
              ),
          ],
        ];
      case SuggestCategory.spellingVariant:
        return [
          FTextField(
            control: FTextFieldControl.managed(controller: _variantCtrl),
            label: const Text('Tambah variasi'),
            hint: 'Contoh: kate, katee (pisahkan dengan koma)',
          ),
          if (detail.variants.isNotEmpty) ...[
            const Gap(12),
            const _FieldCaption('Hapus variasi yang ada'),
            for (final v in detail.variants)
              _removeCheckbox(
                label: v.form,
                value: _removeVariants.containsKey(v.form),
                onChange: (on) => setState(() =>
                    on ? _removeVariants[v.form] = v.variantType : _removeVariants.remove(v.form)),
              ),
          ],
        ];
      case SuggestCategory.lemmaNotes:
        return [
          FTextField(
            control: FTextFieldControl.managed(controller: _lemmaCtrl),
            label: const Text('Lemma'),
            error: _errorText('lemma'),
          ),
          const Gap(8),
          FTextField(
            control: FTextFieldControl.managed(controller: _notesCtrl),
            label: const Text('Catatan'),
            hint: 'Asal kata, pemakaian, atau keterangan lain',
            error: _errorText('notes'),
            maxLines: 4,
            minLines: 2,
          ),
        ];
    }
  }

  Widget _padananField(TextEditingController ctrl, {required bool forAdd}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _FieldCaption(
          'Terjemahan Indonesia',
          info: 'Satu kata/frasa setara dengan lemma.\n\nContoh: "makan". Beda dari definisi.',
        ),
        FTextField(
          control: FTextFieldControl.managed(controller: ctrl),
          hint: 'Satu kata/frasa setara di Indonesia',
          description: const Text('Tekan ikon buku untuk mencari definisi di KBBI'),
          error: _errorText('padanan'),
          suffixBuilder: (context, style, _) => Padding(
            padding: style.clearButtonPadding,
            child: FButton.icon(
              style: style.clearButtonStyle,
              onPress: () => _openKbbiSheet(forAdd: forAdd),
              child: const Icon(FLucideIcons.bookOpen, semanticLabel: 'Ambil dari KBBI'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _definitionField(TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _FieldCaption(
          'Definisi',
          info: 'Uraian makna berbahasa Indonesia - bukan terjemahan satu kata.',
        ),
        FTextField(
          control: FTextFieldControl.managed(controller: ctrl),
          hint: 'Jelaskan makna kata ini',
          error: _errorText('definition'),
          maxLines: 3,
          minLines: 2,
        ),
      ],
    );
  }

  Widget _wordClassField({required bool forAdd}) {
    final selectedId = forAdd ? _addWordClassId : _wordClassId;
    return ref.watch(_suggestWordClassesProvider).when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: FCircularProgress()),
          ),
          error: (_, _) => FButton(
            variant: .outline,
            onPress: () => ref.invalidate(_suggestWordClassesProvider),
            child: const Text('Gagal muat kelas kata - coba lagi'),
          ),
          data: (items) {
            final selected = items.where((e) => e.id == selectedId).firstOrNull;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FieldCaption(
                  forAdd ? 'Kelas kata (opsional)' : 'Kelas kata',
                  info: 'Nomina, verba, adjektiva, dsb.',
                ),
                _SelectField(
                  selectedLabel: selected?.displayLabel,
                  hint: 'Pilih kelas kata',
                  onTap: () => _pickWordClass(items, forAdd: forAdd),
                ),
                if (_fieldErrors['word_class'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _fieldErrors['word_class']!,
                      style: context.theme.typography.sm.copyWith(color: context.theme.colors.error),
                    ),
                  ),
              ],
            );
          },
        );
  }

  Widget _existingImageRow(WordImage img) {
    final removed = _removeImageIds.contains(img.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 40,
              height: 40,
              child: CachedNetworkImageWithFallback(imageUrl: img.url, fit: BoxFit.cover),
            ),
          ),
          const Gap(10),
          Expanded(
            child: FCheckbox(
              value: removed,
              label: Text(img.isPrimary ? 'Hapus (utama)' : 'Hapus'),
              onChange: (val) => setState(() {
                if (val) {
                  _removeImageIds.add(img.id);
                  if (_setPrimaryImageId == img.id) _setPrimaryImageId = null;
                } else {
                  _removeImageIds.remove(img.id);
                }
              }),
            ),
          ),
          if (!removed && !img.isPrimary)
            FButton(
              variant: .outline,
              onPress: () => setState(() => _setPrimaryImageId = img.id),
              child: Text(_setPrimaryImageId == img.id ? 'Utama ✓' : 'Jadikan utama'),
            ),
        ],
      ),
    );
  }

  Widget _removeCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool> onChange,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: FCheckbox(value: value, label: Text(label), onChange: onChange),
    );
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.selectedLabel,
    required this.hint,
    required this.onTap,
  });

  final String? selectedLabel;
  final String hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final hasValue = selectedLabel != null && selectedLabel!.isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hasValue ? selectedLabel! : hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.sm.copyWith(
                    color: hasValue ? theme.colors.foreground : theme.colors.mutedForeground,
                  ),
                ),
              ),
              Icon(FLucideIcons.chevronsUpDown, size: 16, color: theme.colors.mutedForeground),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldCaption extends StatelessWidget {
  const _FieldCaption(this.text, {this.info});

  final String text;
  final String? info;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Flexible(
            child: Text(
              text,
              style: theme.typography.sm.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colors.foreground,
              ),
            ),
          ),
          if (info != null) ...[const Gap(4), _InfoTip(message: info!)],
        ],
      ),
    );
  }
}

class _InfoTip extends StatelessWidget {
  const _InfoTip({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FPopover(
      constraints: const FPortalConstraints(maxWidth: 280),
      popoverBuilder: (context, _) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Text(message, style: theme.typography.sm.copyWith(height: 1.35)),
      ),
      builder: (context, controller, child) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: controller.toggle,
        child: child,
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(FLucideIcons.info, size: 14, color: theme.colors.mutedForeground),
      ),
    );
  }
}

class _RefItem {
  const _RefItem({
    required this.id,
    required this.name,
    required this.code,
    this.alias,
  });

  final String id;
  final String name;
  final String code;
  final String? alias;

  String get displayLabel => (alias == null || alias!.isEmpty) ? name : '$name ($alias)';
}

final _suggestWordClassesProvider = FutureProvider<List<_RefItem>>((ref) async {
  final dio = ref.watch(dioProvider);
  final resp = await dio.get<dynamic>('/api/v1/word-classes');
  final data = resp.data;
  if (data is! Map<String, dynamic>) return [];
  final arr = data['data'];
  if (arr is! List) return [];
  return arr
      .whereType<Map<String, dynamic>>()
      .map(
        (e) => _RefItem(
          id: e['id']?.toString() ?? '',
          name: e['name']?.toString() ?? '(?)',
          code: e['code']?.toString() ?? '',
          alias: e['alias']?.toString(),
        ),
      )
      .where((e) => e.id.isNotEmpty)
      .toList(growable: false);
});

String? _matchWordClassId(List<_RefItem> classes, String? code, String? label) {
  final normalizedCode = code?.trim().toLowerCase();
  if (normalizedCode != null && normalizedCode.isNotEmpty) {
    final byCode = classes.where((c) => c.code.toLowerCase() == normalizedCode).firstOrNull;
    if (byCode != null) return byCode.id;
    if (normalizedCode == 'a') {
      final adj = classes.where((c) => c.code.toLowerCase() == 'adj').firstOrNull;
      if (adj != null) return adj.id;
    }
  }
  final normalizedLabel = label?.trim().toLowerCase();
  if (normalizedLabel != null && normalizedLabel.isNotEmpty) {
    return classes.where((c) => c.name.toLowerCase() == normalizedLabel).firstOrNull?.id;
  }
  return null;
}
