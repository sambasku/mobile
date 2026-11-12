import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../shared/domain/word_type_options.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/kbbi_source_notice.dart';
import '../../../../shared/widgets/word_type_picker_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../my_contributions/presentation/providers/my_contributions_providers.dart';
import '../../../contribution/presentation/utils/invalidate_word_detail.dart';
import '../../../contribution/presentation/widgets/contribute_images_field.dart';
import '../../../contribution/presentation/widgets/kbbi_definition_sheet.dart';
import '../../../contribution/presentation/widgets/kbbi_translation_field.dart';
import '../../../contribution/presentation/widgets/word_class_picker_sheet.dart';
import '../../../dictionary/domain/entities/word_detail.dart';
import '../../../dictionary/presentation/providers/word_detail_providers.dart';
import '../../domain/meaning_edit_order.dart';
import '../../domain/suggest_category.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/suggest_edit_feedback.dart';
import '../suggest_edit_labels.dart';
import '../widgets/lemma_picker_field.dart';
import '../widgets/word_change_history_section.dart';

/// Form usul perubahan: pilih kategori dulu, lalu isi field kategori itu saja.
/// Draft tiap kategori tetap di memori selama halaman terbuka.
class SuggestEditPage extends ConsumerStatefulWidget {
  const SuggestEditPage({
    super.key,
    required this.wordId,
    this.initialCategory,
    this.initialMeaningId,
  });

  final String wordId;

  /// Kategori yang langsung terpilih, mis. saat dibuka dari form tinjau
  /// dengan `?category=add_meaning`. Kalau kategori ini tidak tersedia untuk
  /// kata tersebut, daftar kategori tetap ditampilkan.
  final SuggestCategory? initialCategory;

  /// Makna kartu voting deck (`?meaning=`). Dipakai untuk prefill kategori
  /// yang butuh satu makna, dan ditaruh di atas section "Ubah makna".
  /// ID yang tidak ada di detail diabaikan.
  final String? initialMeaningId;

  @override
  ConsumerState<SuggestEditPage> createState() => _SuggestEditPageState();
}

class _SuggestEditPageState extends ConsumerState<SuggestEditPage> {
  AppLocalizations get _l10n => AppLocalizations.of(context);

  SuggestCategory? _category;
  String? _meaningId;
  bool _prefilled = false;
  bool _submitting = false;
  Map<String, String> _fieldErrors = const {};

  // #230: Ubah makna - draft per makna, semua makna bisa diubah sekaligus.
  final Map<String, ({TextEditingController def, TextEditingController pad})>
  _meaningDrafts = {};

  // Ubah kelas kata (makna terpilih).
  String? _wordClassId;

  // Ubah jenis entri (kata / idiom / peribahasa / ungkapan).
  String _wordType = 'word';
  String _originalWordType = 'word';

  // Tambah makna.
  final _addDefinitionCtrl = TextEditingController();
  final _addPadananCtrl = TextEditingController();
  String? _addWordClassId;

  // Tambah / ubah contoh (#244).
  final _sentenceCtrl = TextEditingController();
  final _sentenceTranslationCtrl = TextEditingController();
  String? _exampleId;
  String _originalExampleSentence = '';
  String? _originalExampleTranslation;

  // Foto.
  List<ContributeImageSlot> _addImages = [];
  List<ContributeImageSlot> _replacementImages = [];
  final Set<String> _removeImageIds = {};
  String? _setPrimaryImageId;

  // Relasi + variasi.
  final _synonymCtrl = TextEditingController();
  final _antonymCtrl = TextEditingController();
  // PRD relasi-lemma: relasi bentuk/akar memakai satu controller (satu
  // kategori = satu tipe, cermin _synonymCtrl/_antonymCtrl).
  final _relationCtrl = TextEditingController();
  final Set<String> _removeRelationIds = {};
  final _variantCtrl = TextEditingController();
  final Map<String, String> _removeVariants = {};

  // Kelompok makna: usul grup baru atau gabung grup yang sudah ada.
  final _groupNameCtrl = TextEditingController();
  final _groupMembersCtrl = TextEditingController();
  final Set<String> _leaveGroupIds = {};

  // Lainnya.
  final _lemmaCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  final _reasonTextCtrl = TextEditingController();

  @override
  void dispose() {
    for (final d in _meaningDrafts.values) {
      d.def.dispose();
      d.pad.dispose();
    }
    for (final c in [
      _addDefinitionCtrl,
      _addPadananCtrl,
      _sentenceCtrl,
      _sentenceTranslationCtrl,
      _synonymCtrl,
      _antonymCtrl,
      _relationCtrl,
      _variantCtrl,
      _groupNameCtrl,
      _groupMembersCtrl,
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

  static String _padananOf(WordMeaning m) =>
      m.translations.firstOrNull?.text ?? '';

  void _selectMeaning(WordMeaning m) {
    _meaningId = m.id;
    _wordClassId = m.wordClassId;
  }

  /// Lazy: makna baru setelah detail di-refetch tetap dapat draft.
  ({TextEditingController def, TextEditingController pad}) _draftFor(
    WordMeaning m,
  ) => _meaningDrafts.putIfAbsent(
    m.id,
    () => (
      def: TextEditingController(text: m.definition ?? ''),
      pad: TextEditingController(text: _padananOf(m)),
    ),
  );

  void _prefillOnce(WordDetail detail) {
    if (_prefilled) return;
    _prefilled = true;
    _lemmaCtrl.text = detail.lemma;
    _notesCtrl.text = detail.notes ?? '';
    _originalWordType = detail.wordType;
    _wordType = detail.wordType;
    final preferred = meaningsPreferredFirst(
      detail.meanings,
      widget.initialMeaningId,
      idOf: (m) => m.id,
    ).firstOrNull;
    if (preferred != null) _selectMeaning(preferred);
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
      hasExample: detail.meanings.any((m) => m.examples.isNotEmpty),
    );
    if (!available.contains(requested)) return;
    _category = requested;
  }

  List<({WordMeaning meaning, WordExample example})> _flatExamples(
    WordDetail detail,
  ) => [
    for (final m in detail.meanings)
      for (final ex in m.examples) (meaning: m, example: ex),
  ];

  void _selectExample(WordExample example) {
    setState(() {
      _exampleId = example.id;
      _originalExampleSentence = example.sourceSentence;
      _originalExampleTranslation = example.targetSentence;
      _sentenceCtrl.text = example.sourceSentence;
      _sentenceTranslationCtrl.text = example.targetSentence ?? '';
      _fieldErrors = const {};
    });
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
      if (item['code']?.toString().toUpperCase() == 'IDN') {
        return item['id']?.toString();
      }
    }
    return null;
  }

  Future<void> _pickWordClass(
    List<_RefItem> items, {
    required bool forAdd,
  }) async {
    final picked = await showWordClassPickerSheet(
      context,
      items: [
        for (final e in items)
          WordClassPickItem(id: e.id, name: e.name, alias: e.alias),
      ],
      selectedId: forAdd ? _addWordClassId : _wordClassId,
    );
    if (!mounted || picked == null) return;
    setState(
      () => forAdd ? _addWordClassId = picked.id : _wordClassId = picked.id,
    );
  }

  Future<void> _pickWordType() async {
    final picked = await showWordTypePickerSheet(context, selected: _wordType);
    if (!mounted || picked == null) return;
    setState(() => _wordType = picked);
  }

  Future<void> _pickMeaning(WordDetail detail) async {
    final picked = await showModalBottomSheet<WordMeaning>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: FTileGroup(
            label: Text(_l10n.suggestPickMeaning),
            children: [
              for (final m in detail.meanings)
                FTile(
                  title: Text(
                    _meaningLabel(m),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  suffix: m.id == _meaningOf(detail)?.id
                      ? const Icon(FLucideIcons.check, size: 18)
                      : null,
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
    final text = _padananOf(m).isNotEmpty
        ? _padananOf(m)
        : (m.definition ?? '-');
    return (code == null || code.isEmpty) ? text : '$code. $text';
  }

  Future<void> _openKbbiSheet({
    required bool forAdd,
    ({TextEditingController def, TextEditingController pad})? draft,
  }) async {
    final dio = ref.read(dioProvider);
    final padCtrl = forAdd ? _addPadananCtrl : draft!.pad;
    final picked = await showKbbiDefinitionSheet(
      context,
      dio: dio,
      initialLemma: padCtrl.text.trim().isNotEmpty
          ? padCtrl.text.trim()
          : _lemmaCtrl.text.trim(),
    );
    if (!mounted || picked == null) return;
    final classes =
        ref.read(_suggestWordClassesProvider).value ?? const <_RefItem>[];
    // Ubah makna tidak boleh membawa kelas kata (kategori sendiri).
    final matched = forAdd
        ? _matchWordClassId(
            classes,
            picked.wordClassCode,
            picked.wordClassLabel,
          )
        : null;
    setState(() {
      (forAdd ? _addDefinitionCtrl : draft!.def).text = picked.definition;
      if (picked.lemma.trim().isNotEmpty) padCtrl.text = picked.lemma.trim();
      if (matched != null) _addWordClassId = matched;
    });
  }

  Future<void> _showError(String message, {String? title}) => showAppErrorSheet(
    context,
    message: message,
    title: title ?? AppLocalizations.of(context).suggestUnexpectedError,
  );

  /// Susun proposed_changes kategori aktif. `null` = belum ada perubahan;
  /// [StateError] = isian tidak bisa dipakai (pesan untuk user).
  Future<Map<String, dynamic>?> _buildProposed(
    WordDetail detail,
    Dio dio,
  ) async {
    final meaning = _meaningOf(detail);
    switch (_category!) {
      case SuggestCategory.changeMeaning:
        // #230: kirim semua makna yang berubah, bukan cuma yang terpilih.
        final anyPadChanged = detail.meanings.any(
          (m) => _draftFor(m).pad.text.trim() != _padananOf(m),
        );
        return buildChangeMeaning(
          meanings: [
            for (final m in detail.meanings)
              (
                meaningId: m.id,
                originalDefinition: m.definition ?? '',
                definition: _draftFor(m).def.text,
                originalPadanan: _padananOf(m),
                padanan: _draftFor(m).pad.text,
              ),
          ],
          padananLanguageId: anyPadChanged
              ? await _resolveIdnLanguageId(dio, detail.meanings.firstOrNull)
              : null,
        );
      case SuggestCategory.changeWordClass:
        return buildChangeWordClass(
          meaningId: meaning!.id,
          originalWordClassId: meaning.wordClassId,
          wordClassId: _wordClassId,
        );
      case SuggestCategory.changeWordType:
        return buildChangeWordType(
          originalWordType: _originalWordType,
          wordType: _wordType,
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
          for (final id in _removeImageIds)
            {'action': 'remove', 'image_id': id},
          if (_setPrimaryImageId != null &&
              !_removeImageIds.contains(_setPrimaryImageId))
            {'action': 'set_primary', 'image_id': _setPrimaryImageId},
          ..._imageAdds(_replacementImages),
        ];
        final touchesExisting = images.any((i) => i['action'] != 'add');
        return touchesExisting ? {'images': images} : null;
      case SuggestCategory.synonym:
      case SuggestCategory.antonym:
      // PRD relasi-lemma: kategori relasi baru - satu kategori satu tipe.
      case SuggestCategory.variantOf:
      case SuggestCategory.nonstandardOf:
      case SuggestCategory.derivedFrom:
        final type = _category!.code;
        final ctrl = switch (_category!) {
          SuggestCategory.synonym => _synonymCtrl,
          SuggestCategory.antonym => _antonymCtrl,
          _ => _relationCtrl,
        };
        // Lemma dikirim apa adanya; API resolve (kata yang belum ada
        // dibuat sebagai kata baru saat usulan disetujui verifikator).
        return buildRelations(
          relationType: type,
          addLemmas: splitCsv(ctrl.text),
          removeWordIds: _removeRelationIds
              .where((k) => k.startsWith('$type|'))
              .map((k) => k.substring(type.length + 1)),
        );
      case SuggestCategory.meaningGroup:
        return buildGroups(
          newGroupName: _groupNameCtrl.text,
          newGroupLemmas: splitCsv(_groupMembersCtrl.text),
          leaveGroupIds: _leaveGroupIds,
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
      case SuggestCategory.changeExample:
        final id = _exampleId;
        if (id == null) {
          throw StateError(_l10n.suggestPickExample);
        }
        final sentence = _sentenceCtrl.text.trim();
        if (sentence.isEmpty) {
          throw StateError(_l10n.suggestExampleFirst);
        }
        return buildChangeExample(
          exampleId: id,
          originalSourceSentence: _originalExampleSentence,
          sourceSentence: sentence,
          originalTargetSentence: _originalExampleTranslation,
          targetSentence: _sentenceTranslationCtrl.text,
        );
      case SuggestCategory.addExample:
        throw StateError(_l10n.suggestExampleFirst);
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
          'alt_text': ?slot.uploaded!.altText,
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
          _l10n.suggestNothingChangedFor(
            suggestCategoryLabel(_category!, _l10n).toLowerCase(),
          ),
          title: _l10n.suggestNothingChanged,
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
            l10n: AppLocalizations.of(context),
          ),
        ),
      );
      // Issue #159: flush L1 + Riverpod, kalau tidak detail refetch data basi.
      await invalidateWordDetailCaches(ref, widget.wordId, detail.lemma);
      if (!mounted) return;
      ref.invalidate(changeHistoryProvider(widget.wordId));
      // #264: ganti form di stack (bukan pop+push) supaya back tidak
      // membuka lagi form usulan yang sudah terkirim.
      if (!selfApplied) {
        ref.invalidate(myContributionsListControllerProvider);
        context.pushReplacement('/contributions');
      } else {
        context.pop();
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
      setState(() => _fieldErrors = {'sentence': _l10n.suggestExampleFirst});
      return;
    }
    final targetLang = translation.isEmpty
        ? null
        : await _resolveIdnLanguageId(dio, meaning);
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
            ? _l10n.suggestExamplePublishedToast
            : _l10n.suggestExampleQueuedToast,
      ),
    );
    await invalidateWordDetailCaches(ref, widget.wordId, detail.lemma);
    if (!mounted) return;
    GoRouter.of(context).pop();
  }

  Future<void> _handleDioError(DioException e) async {
    if (!mounted) return;
    final data = e.response?.data;
    final code = data is Map ? data['error_code'] as String? : null;
    final message = data is Map && data['message'] is String
        ? data['message'] as String
        : _l10n.suggestSubmitFailed;

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
      if (unmapped != null) {
        await _showError(unmapped, title: _l10n.suggestReviewForm);
      }
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
      await invalidateWordDetailCaches(
        ref,
        widget.wordId,
        ref.read(wordDetailProvider(widget.wordId)).value?.lemma ?? '',
      );
      if (!mounted) return;
    }
    await _showError(
      message,
      title: code == 'SUGGESTION_ALREADY_PENDING'
          ? _l10n.suggestStillPendingTitle
          : _l10n.suggestUnexpectedError,
    );
  }

  /// #264: dari form kategori → listing opsi dulu; dari listing → keluar.
  /// Jangan pushReplacement antar opsi - state lokal `_category` saja.
  void _onBack() {
    if (_category != null) {
      setState(() => _category = null);
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStatusProvider).value;
    final detailAsync = ref.watch(wordDetailProvider(widget.wordId));

    if (auth?.isAuth != true) {
      return FScaffold(
        header: FHeader.nested(
          title: Text(_l10n.suggestSuggestChangeCta),
          prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        ),
        child: Center(
          child: FButton(
            onPress: () => context.push('/login'),
            child: Text(_l10n.suggestLoginPrompt),
          ),
        ),
      );
    }

    final preSubmit = suggestEditPreSubmitCopy(auth?.role, _l10n);
    // Judul halaman ikut tile detail kata - satu sumber, supaya "Lengkapi
    // kata" di tile tidak membuka halaman bertajuk "Ubah Kata".
    final headerTitle = suggestEditEntryTileCopy(auth?.role, _l10n).title;
    final isExample = _category == SuggestCategory.addExample;
    final onCategoryForm = _category != null;

    // #264: system back sama dengan header - form → listing, bukan keluar.
    return PopScope(
      canPop: !onCategoryForm,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _category != null) {
          setState(() => _category = null);
        }
      },
      child: FScaffold(
        header: FHeader.nested(
          title: Text(headerTitle),
          prefixes: [FHeaderAction.back(onPress: _onBack)],
        ),
        footer: !onCategoryForm
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
                          : (isExample
                                ? _l10n.suggestSendExample
                                : preSubmit.cta),
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
      ),
    );
  }

  Widget _buildCategoryList(WordDetail detail, String banner) {
    final theme = context.theme;
    final categories = availableSuggestCategories(
      hasMeaning: detail.meanings.isNotEmpty,
      hasImage: detail.images.isNotEmpty,
      hasExample: detail.meanings.any((m) => m.examples.isNotEmpty),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      children: [
        Text(
          banner,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        const Gap(12),
        FTileGroup(
          label: Text(_l10n.suggestWhatToChange),
          children: [
            for (final c in categories)
              FTile(
                title: Text(suggestCategoryLabel(c, _l10n)),
                subtitle: Text(suggestCategoryDescription(c, _l10n)),
                suffix: Icon(
                  FLucideIcons.chevronRight,
                  size: 16,
                  color: theme.colors.mutedForeground,
                ),
                onPress: () => setState(() {
                  _category = c;
                  _fieldErrors = const {};
                  _exampleId = null;
                  _originalExampleSentence = '';
                  _originalExampleTranslation = null;
                  if (c == SuggestCategory.changeExample) {
                    _sentenceCtrl.clear();
                    _sentenceTranslationCtrl.clear();
                  }
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
        // Lemma kata yang sedang diusulkan - highlight supaya jelas konteks.
        Align(
          alignment: Alignment.centerLeft,
          child: Semantics(
            label: _l10n.suggestEditingLemmaSemantics(detail.lemma),
            child: FBadge(
              variant: FBadgeVariant.primary,
              child: Text(detail.lemma),
            ),
          ),
        ),
        const Gap(12),
        FTile(
          title: Text(suggestCategoryLabel(category, _l10n)),
          subtitle: Text(_l10n.suggestChangeTypeSemantics),
          suffix: Icon(
            FLucideIcons.chevronsUpDown,
            size: 16,
            color: theme.colors.mutedForeground,
          ),
          onPress: () => setState(() => _category = null),
        ),
        const Gap(12),
        // #230: Ubah makna menampilkan semua makna sekaligus - picker
        // makna hanya untuk kategori lain yang butuh satu makna.
        if (category.needsMeaning &&
            category != SuggestCategory.changeMeaning &&
            detail.meanings.length > 1) ...[
          _FieldCaption(_l10n.suggestMeaningSection),
          _SelectField(
            selectedLabel: _meaningLabel(_meaningOf(detail)!),
            hint: _l10n.suggestPickMeaning,
            onTap: () => _pickMeaning(detail),
          ),
          const Gap(12),
        ],
        ..._sectionFor(category, detail),
        if (category != SuggestCategory.addExample) ...[
          const Gap(12),
          FTextField(
            control: FTextFieldControl.managed(controller: _reasonTextCtrl),
            label: Text(_l10n.suggestReasonLabel),
            hint: _l10n.suggestReasonHint,
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
        // #230: semua makna tampil sebagai section, masing-masing bisa
        // diubah. Tanpa picker makna tunggal. #232: makna ?meaning=
        // (kartu deck) di section pertama; urutan tidak ikut picker lain.
        return [
          for (final m in meaningsPreferredFirst(
            detail.meanings,
            widget.initialMeaningId,
            idOf: (m) => m.id,
          )) ...[
            _FieldCaption(_meaningLabel(m)),
            _padananField(_draftFor(m).pad, forAdd: false, draft: _draftFor(m)),
            const Gap(8),
            _definitionField(_draftFor(m).def),
            const Gap(16),
          ],
        ];
      case SuggestCategory.changeWordClass:
        return [_wordClassField(forAdd: false)];
      case SuggestCategory.changeWordType:
        return [_wordTypeField()];
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
            label: Text(_l10n.suggestExampleSection(detail.lemma)),
            hint: _l10n.suggestExampleLangHint,
            error: _errorText('sentence'),
            maxLines: 3,
            minLines: 2,
          ),
          const Gap(8),
          FTextField(
            control: FTextFieldControl.managed(
              controller: _sentenceTranslationCtrl,
            ),
            label: Text(_l10n.suggestExampleTranslationLabel),
            hint: _l10n.suggestExampleTranslationHint,
            error: _errorText('sentence_translation'),
            maxLines: 3,
            minLines: 2,
          ),
        ];
      case SuggestCategory.changeExample:
        final items = _flatExamples(detail);
        return [
          _FieldCaption(_l10n.suggestPickExample),
          FTileGroup(
            children: [
              for (final item in items)
                FTile(
                  title: Text(item.example.sourceSentence),
                  subtitle:
                      item.example.targetSentence == null ||
                          item.example.targetSentence!.trim().isEmpty
                      ? null
                      : Text(item.example.targetSentence!),
                  suffix: _exampleId == item.example.id
                      ? Icon(
                          FLucideIcons.check,
                          size: 16,
                          color: context.theme.colors.primary,
                        )
                      : null,
                  onPress: () => _selectExample(item.example),
                ),
            ],
          ),
          if (_exampleId != null) ...[
            const Gap(12),
            _FieldCaption(_l10n.suggestExampleSelected),
            FTextField(
              control: FTextFieldControl.managed(controller: _sentenceCtrl),
              label: Text(_l10n.suggestExampleSection(detail.lemma)),
              hint: _l10n.suggestExampleLangHint,
              error: _errorText('sentence'),
              maxLines: 3,
              minLines: 2,
            ),
            const Gap(8),
            FTextField(
              control: FTextFieldControl.managed(
                controller: _sentenceTranslationCtrl,
              ),
              label: Text(_l10n.suggestExampleTranslationLabel),
              hint: _l10n.suggestExampleTranslationHint,
              error: _errorText('sentence_translation'),
              maxLines: 3,
              minLines: 2,
            ),
          ],
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
          _FieldCaption(_l10n.suggestExistingPhotos),
          for (final img in detail.images) _existingImageRow(img),
          const Gap(8),
          _FieldCaption(
            _l10n.suggestReplacementPhotos,
            info: _l10n.suggestReplacementPhotosHint,
          ),
          ContributeImagesField(
            enabled: true,
            images: _replacementImages,
            onChanged: (next) => setState(() => _replacementImages = next),
          ),
        ];
      case SuggestCategory.synonym:
      case SuggestCategory.antonym:
      // PRD relasi-lemma: pola form sama dengan sinonim/antonim - teks
      // CSV lemma + hapus relasi yang ada; beda hanya tipe relasinya.
      case SuggestCategory.variantOf:
      case SuggestCategory.nonstandardOf:
      case SuggestCategory.derivedFrom:
        final type = category.code;
        final existing = detail.relatedWords
            .where((r) => r.relationType == type)
            .toList();
        final ctrl = switch (category) {
          SuggestCategory.synonym => _synonymCtrl,
          SuggestCategory.antonym => _antonymCtrl,
          _ => _relationCtrl,
        };
        final targetLabel = switch (category) {
          SuggestCategory.derivedFrom => _l10n.suggestDerivedFromLabel,
          _ => _l10n.suggestReferenceLabel,
        };
        return [
          LemmaPickerField(
            controller: ctrl,
            label: _l10n.suggestAddRelation(
              suggestCategoryLabel(category, _l10n).toLowerCase(),
            ),
            hint: _l10n.suggestRelationPickHint,
            error: _errorText('relation_lemma'),
            excludeLemmas: {detail.lemma},
          ),
          const Gap(12),
          _FieldCaption(
            switch (category) {
              SuggestCategory.derivedFrom => _l10n.suggestDerivedHint(
                targetLabel,
              ),
              SuggestCategory.nonstandardOf => _l10n.suggestNonstandardOfHint,
              _ => _l10n.suggestVariantOfHint,
            },
            info: switch (category) {
              SuggestCategory.derivedFrom => _l10n.suggestDerivedExample,
              SuggestCategory.nonstandardOf => _l10n.suggestNonstandardExample,
              _ => _l10n.suggestVariantExample,
            },
          ),
          if (existing.isNotEmpty) ...[
            const Gap(12),
            _FieldCaption(
              _l10n.suggestRemoveRelation(
                suggestCategoryLabel(category, _l10n).toLowerCase(),
              ),
            ),
            for (final r in existing)
              _removeCheckbox(
                label: r.lemma,
                value: _removeRelationIds.contains('$type|${r.wordId}'),
                onChange: (v) => setState(
                  () => v
                      ? _removeRelationIds.add('$type|${r.wordId}')
                      : _removeRelationIds.remove('$type|${r.wordId}'),
                ),
              ),
          ],
        ];
      case SuggestCategory.meaningGroup:
        final leaveTargets = detail.meaningGroups;
        return [
          FTextField(
            control: FTextFieldControl.managed(controller: _groupNameCtrl),
            label: Text(_l10n.suggestNewGroupName),
            hint: _l10n.suggestNewGroupNameHint,
            error: _errorText('name'),
          ),
          const Gap(8),
          LemmaPickerField(
            controller: _groupMembersCtrl,
            label: _l10n.suggestOtherMembers,
            hint: _l10n.suggestRelationPickHint,
            error: _errorText('group_lemma'),
            excludeLemmas: {detail.lemma},
          ),
          const Gap(12),
          _FieldCaption(
            _l10n.suggestGroupExplainer,
            info:
                '${_l10n.suggestGroupExample}\n\n${_l10n.suggestGroupSeparateNote}',
          ),
          if (leaveTargets.isNotEmpty) ...[
            const Gap(12),
            _FieldCaption(_l10n.suggestLeaveGroup),
            for (final g in leaveTargets)
              _removeCheckbox(
                label: g.name,
                value: _leaveGroupIds.contains(g.groupId),
                onChange: (v) => setState(
                  () => v
                      ? _leaveGroupIds.add(g.groupId)
                      : _leaveGroupIds.remove(g.groupId),
                ),
              ),
          ],
        ];
      case SuggestCategory.spellingVariant:
        return [
          FTextField(
            control: FTextFieldControl.managed(controller: _variantCtrl),
            label: Text(_l10n.suggestAddVariant),
            hint: _l10n.suggestAddVariantHint,
          ),
          if (detail.variants.isNotEmpty) ...[
            const Gap(12),
            _FieldCaption(_l10n.suggestRemoveVariant),
            for (final v in detail.variants)
              _removeCheckbox(
                label: v.form,
                value: _removeVariants.containsKey(v.form),
                onChange: (on) => setState(
                  () => on
                      ? _removeVariants[v.form] = v.variantType
                      : _removeVariants.remove(v.form),
                ),
              ),
          ],
        ];
      case SuggestCategory.lemmaNotes:
        return [
          FTextField(
            control: FTextFieldControl.managed(controller: _lemmaCtrl),
            label: Text(_l10n.suggestLemmaLabel),
            error: _errorText('lemma'),
          ),
          const Gap(8),
          FTextField(
            control: FTextFieldControl.managed(controller: _notesCtrl),
            label: Text(_l10n.suggestNotesLabel),
            hint: _l10n.suggestNotesHint,
            error: _errorText('notes'),
            maxLines: 4,
            minLines: 2,
          ),
        ];
    }
  }

  Widget _padananField(
    TextEditingController ctrl, {
    required bool forAdd,
    ({TextEditingController def, TextEditingController pad})? draft,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldCaption(
          _l10n.suggestTranslationField,
          info: _l10n.suggestTranslationHint,
        ),
        KbbiTranslationField(
          controller: ctrl,
          onOpenKbbi: () => _openKbbiSheet(forAdd: forAdd, draft: draft),
          hint: _l10n.suggestTranslationSemanticsHint,
          description: Text(_l10n.suggestKbbiSemantics),
          error: _errorText('padanan'),
        ),
        const Gap(8),
        const KbbiSourceNotice(),
      ],
    );
  }

  Widget _definitionField(TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldCaption(
          _l10n.suggestDefinitionLabel,
          info: _l10n.suggestDefinitionHint,
        ),
        FTextField.multiline(
          control: FTextFieldControl.managed(controller: ctrl),
          hint: _l10n.suggestDefinitionPlaceholder,
          error: _errorText('definition'),
          minLines: 4,
          maxLines: 8,
        ),
      ],
    );
  }

  Widget _wordTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldCaption(_l10n.suggestWordTypeLabel),
        _SelectField(
          selectedLabel: wordTypeOptionLabel(_wordType),
          hint: _l10n.suggestWordTypePicker,
          onTap: _pickWordType,
        ),
        if (_fieldErrors['word_type'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _fieldErrors['word_type']!,
              style: context.theme.typography.body.sm.copyWith(
                color: context.theme.colors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _wordClassField({required bool forAdd}) {
    final selectedId = forAdd ? _addWordClassId : _wordClassId;
    return ref
        .watch(_suggestWordClassesProvider)
        .when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: FCircularProgress()),
          ),
          error: (_, _) => FButton(
            variant: .outline,
            onPress: () => ref.invalidate(_suggestWordClassesProvider),
            child: Text(_l10n.suggestWordClassLoadFailed),
          ),
          data: (items) {
            final selected = items.where((e) => e.id == selectedId).firstOrNull;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FieldCaption(
                  forAdd
                      ? _l10n.suggestWordClassLabel
                      : _l10n.suggestWordClassLabelShort,
                  info: _l10n.suggestWordClassHint,
                ),
                _SelectField(
                  selectedLabel: selected?.displayLabel,
                  hint: _l10n.suggestWordClassPicker,
                  onTap: () => _pickWordClass(items, forAdd: forAdd),
                ),
                if (_fieldErrors['word_class'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _fieldErrors['word_class']!,
                      style: context.theme.typography.body.sm.copyWith(
                        color: context.theme.colors.error,
                      ),
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
              child: CachedNetworkImageWithFallback(
                imageUrl: img.url,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Gap(10),
          Expanded(
            child: FCheckbox(
              value: removed,
              label: Text(
                img.isPrimary
                    ? _l10n.suggestRemovePrimary
                    : _l10n.suggestRemove,
              ),
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
              child: Text(
                _setPrimaryImageId == img.id
                    ? _l10n.suggestPrimaryMark
                    : _l10n.suggestSetPrimary,
              ),
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
                  style: theme.typography.body.sm.copyWith(
                    color: hasValue
                        ? theme.colors.foreground
                        : theme.colors.mutedForeground,
                  ),
                ),
              ),
              Icon(
                FLucideIcons.chevronsUpDown,
                size: 16,
                color: theme.colors.mutedForeground,
              ),
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
              style: theme.typography.body.sm.copyWith(
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
        child: Text(
          message,
          style: theme.typography.body.sm.copyWith(height: 1.35),
        ),
      ),
      builder: (context, controller, child) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: controller.toggle,
        child: child,
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(
          FLucideIcons.info,
          size: 14,
          color: theme.colors.mutedForeground,
        ),
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

  String get displayLabel =>
      (alias == null || alias!.isEmpty) ? name : '$name ($alias)';
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
    final byCode = classes
        .where((c) => c.code.toLowerCase() == normalizedCode)
        .firstOrNull;
    if (byCode != null) return byCode.id;
    if (normalizedCode == 'a') {
      final adj = classes
          .where((c) => c.code.toLowerCase() == 'adj')
          .firstOrNull;
      if (adj != null) return adj.id;
    }
  }
  final normalizedLabel = label?.trim().toLowerCase();
  if (normalizedLabel != null && normalizedLabel.isNotEmpty) {
    return classes
        .where((c) => c.name.toLowerCase() == normalizedLabel)
        .firstOrNull
        ?.id;
  }
  return null;
}
