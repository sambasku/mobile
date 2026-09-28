import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../my_contributions/presentation/providers/my_contributions_providers.dart';
import '../../../contribution/presentation/widgets/contribute_images_field.dart';
import '../../../contribution/presentation/widgets/contribute_relations_sheet.dart';
import '../../../contribution/presentation/widgets/kbbi_definition_sheet.dart';
import '../../../contribution/presentation/widgets/word_class_picker_sheet.dart';
import '../../../dictionary/domain/entities/word_detail.dart';
import '../../../dictionary/presentation/providers/word_detail_providers.dart';
import '../../../review/domain/review_access.dart';
import '../../domain/suggest_edit_feedback.dart';
import '../widgets/suggest_edit_extras_sheet.dart';
import '../widgets/word_change_history_section.dart';

const _reasonOptions = <({String code, String label})>[
  (code: 'typo', label: 'Kesalahan penulisan'),
  (code: 'inaccurate_definition', label: 'Definisi kurang tepat'),
  (code: 'missing_example', label: 'Kurang contoh'),
  (code: 'missing_relation', label: 'Relasi/sinonim kurang'),
  (code: 'image_issue', label: 'Gambar kurang/salah'),
  (code: 'other', label: 'Lainnya'),
];

/// Form usul perubahan - layout slim seperti form kontribusi.
class SuggestEditPage extends ConsumerStatefulWidget {
  const SuggestEditPage({super.key, required this.wordId});

  final String wordId;

  @override
  ConsumerState<SuggestEditPage> createState() => _SuggestEditPageState();
}

class _SuggestEditPageState extends ConsumerState<SuggestEditPage> {
  final _lemmaCtrl = TextEditingController();
  final _padananCtrl = TextEditingController();
  final _definitionCtrl = TextEditingController();
  final _reasonTextCtrl = TextEditingController();

  bool _prefilled = false;
  bool _submitting = false;
  String? _error;
  String _reasonCode = 'typo';

  String? _wordClassId;
  String? _originalWordClassId;
  String _originalPadanan = '';
  String _originalDefinition = '';
  String? _originalNotes;
  String? _originalTranslationLanguageId;

  SuggestEditExtrasDraft _extras = const SuggestEditExtrasDraft();
  final Set<String> _removeImageIds = {};
  String? _setPrimaryImageId;
  List<ContributeImageSlot> _newImages = [];

  @override
  void dispose() {
    _lemmaCtrl.dispose();
    _padananCtrl.dispose();
    _definitionCtrl.dispose();
    _reasonTextCtrl.dispose();
    super.dispose();
  }

  void _prefillOnce(WordDetail detail) {
    if (_prefilled) return;
    _prefilled = true;
    _lemmaCtrl.text = detail.lemma;
    _originalNotes = detail.notes;
    if (detail.meanings.isNotEmpty) {
      final m = detail.meanings.first;
      _definitionCtrl.text = m.definition ?? '';
      _originalDefinition = _definitionCtrl.text;
      _wordClassId = m.wordClassId;
      _originalWordClassId = m.wordClassId;
      final tr = m.translations.firstOrNull;
      _padananCtrl.text = tr?.text ?? '';
      _originalPadanan = _padananCtrl.text;
      _originalTranslationLanguageId = tr?.languageId;
    }
    // Prefill catatan ke sheet (bukan field utama).
    if ((detail.notes ?? '').isNotEmpty) {
      _extras = SuggestEditExtrasDraft(
        relations: ContributeRelationsDraft(notesText: detail.notes ?? ''),
      );
    }
  }

  List<String> _csvParts(String raw) =>
      raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  Future<String?> _resolveLemmaId(
    Dio dio,
    String lemma,
    String excludeId,
  ) async {
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

  Future<String?> _resolveIdnLanguageId(Dio dio) async {
    if (_originalTranslationLanguageId != null &&
        _originalTranslationLanguageId!.isNotEmpty) {
      return _originalTranslationLanguageId;
    }
    final res = await dio.get<Map<String, dynamic>>(
      '/api/v1/languages',
      queryParameters: {'is_active': true},
    );
    final data = res.data?['data'];
    if (data is! List) return null;
    for (final item in data) {
      if (item is! Map) continue;
      final code = item['code']?.toString().toUpperCase();
      if (code == 'IDN') return item['id']?.toString();
    }
    return null;
  }

  Future<void> _openWordClassSheet(List<_RefItem> items) async {
    final picked = await showWordClassPickerSheet(
      context,
      items: [
        for (final e in items)
          WordClassPickItem(id: e.id, name: e.name, alias: e.alias),
      ],
      selectedId: _wordClassId,
    );
    if (!mounted || picked == null) return;
    setState(() => _wordClassId = picked.id);
  }

  Future<void> _openExtrasSheet(WordDetail detail) async {
    final result = await showSuggestEditExtrasSheet(
      context,
      initial: _extras,
      detail: detail,
    );
    if (!mounted || result == null) return;
    setState(() => _extras = result);
  }

  Future<void> _openKbbiSheet() async {
    final auth = await ref.read(authStatusProvider.future);
    if (!mounted) return;
    if (!auth.isAuth) {
      showFToast(
        context: context,
        title: const Text('Masuk dulu untuk ambil definisi dari KBBI'),
      );
      context.push('/login');
      return;
    }

    final dio = ref.read(dioProvider);
    final picked = await showKbbiDefinitionSheet(
      context,
      dio: dio,
      initialLemma: _padananCtrl.text.trim().isNotEmpty
          ? _padananCtrl.text.trim()
          : _lemmaCtrl.text.trim(),
    );
    if (!mounted || picked == null) return;

    final classes =
        ref.read(_suggestWordClassesProvider).value ?? const <_RefItem>[];
    final matched = _matchWordClassId(
      classes,
      picked.wordClassCode,
      picked.wordClassLabel,
    );

    setState(() {
      _definitionCtrl.text = picked.definition;
      final lemmaId = picked.lemma.trim();
      if (lemmaId.isNotEmpty) {
        _padananCtrl.text = lemmaId;
      }
      if (matched != null) {
        _wordClassId = matched;
      }
    });

    showFToast(
      context: context,
      title: Text(
        matched != null
            ? 'Terisi dari KBBI (terjemahan, kelas kata, definisi)'
            : 'Terisi dari KBBI (terjemahan & definisi)',
      ),
    );
  }

  Future<void> _submit(WordDetail detail) async {
    final reasonText = _reasonTextCtrl.text.trim();
    if (_reasonCode == 'other' && reasonText.length < 3) {
      setState(() => _error = 'Untuk Lainnya, isi detail minimal 3 karakter');
      return;
    }

    final proposed = <String, dynamic>{};
    final lemma = _lemmaCtrl.text.trim();
    final notes = _extras.relations.notesText.trim();
    final definition = _definitionCtrl.text.trim();
    final padanan = _padananCtrl.text.trim();

    if (lemma.isNotEmpty && lemma != detail.lemma) {
      proposed['lemma'] = lemma;
    }
    if (notes != (_originalNotes ?? '')) {
      proposed['notes'] = notes;
    }

    if (detail.meanings.isNotEmpty) {
      final meaning = detail.meanings.first;
      final defChanged = definition != _originalDefinition;
      final classChanged = _wordClassId != _originalWordClassId;
      final padananChanged = padanan != _originalPadanan;

      if (defChanged || classChanged || padananChanged) {
        final meaningUpdate = <String, dynamic>{
          'meaning_id': meaning.id,
          'action': 'update',
        };
        if (defChanged) {
          meaningUpdate['definition'] = definition;
        }
        if (classChanged && _wordClassId != null) {
          meaningUpdate['word_class_id'] = _wordClassId;
        }
        if (padananChanged && padanan.isNotEmpty) {
          final dio = ref.read(dioProvider);
          final langId = await _resolveIdnLanguageId(dio);
          if (langId == null) {
            setState(() => _error = 'Bahasa Indonesia (IDN) tidak ditemukan');
            return;
          }
          meaningUpdate['translations'] = [
            {
              'language_id': langId,
              'translation_text': padanan,
              'translation_type': 'direct',
            },
          ];
        }
        proposed['meanings'] = [meaningUpdate];
      }
    }

    final variants = <Map<String, dynamic>>[];
    for (final form in _csvParts(_extras.relations.variantsText)) {
      if (form.toLowerCase() == detail.lemma.toLowerCase()) continue;
      variants.add({
        'action': 'add',
        'form': form,
        'variant_type': 'alternative',
      });
    }
    for (final form in _extras.removeVariantForms) {
      variants.add({
        'action': 'remove',
        'form': form,
        'variant_type': 'alternative',
      });
    }
    if (variants.isNotEmpty) proposed['variants'] = variants;

    final relations = <Map<String, dynamic>>[];
    for (final key in _extras.removeRelationKeys) {
      final parts = key.split('|');
      if (parts.length != 2) continue;
      relations.add({
        'action': 'remove',
        'relation_type': parts[0],
        'word_id': parts[1],
      });
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final dio = ref.read(dioProvider);

      for (final lemmaName in _csvParts(_extras.relations.synonymsText)) {
        final id = await _resolveLemmaId(dio, lemmaName, detail.id);
        if (id == null) {
          setState(() {
            _error =
                'Sinonim "$lemmaName" tidak ditemukan (pakai lemma kata yang sudah ada)';
            _submitting = false;
          });
          return;
        }
        relations.add({
          'action': 'add',
          'relation_type': 'synonym',
          'word_id': id,
        });
      }
      for (final lemmaName in _csvParts(_extras.relations.antonymsText)) {
        final id = await _resolveLemmaId(dio, lemmaName, detail.id);
        if (id == null) {
          setState(() {
            _error =
                'Antonim "$lemmaName" tidak ditemukan (pakai lemma kata yang sudah ada)';
            _submitting = false;
          });
          return;
        }
        relations.add({
          'action': 'add',
          'relation_type': 'antonym',
          'word_id': id,
        });
      }
      if (relations.isNotEmpty) proposed['relations'] = relations;

      final images = <Map<String, dynamic>>[];
      for (final slot in _newImages) {
        final dto = slot.uploaded;
        if (dto == null || !slot.isReady) continue;
        images.add({
          'action': 'add',
          'url': dto.url,
          'provider_file_id': dto.providerFileId,
          if (dto.provider != null) 'provider': dto.provider,
          if (dto.sha != null) 'sha': dto.sha,
          'alt_text': dto.altText,
          'is_primary': dto.isPrimary,
        });
      }
      for (final id in _removeImageIds) {
        images.add({'action': 'remove', 'image_id': id});
      }
      if (_setPrimaryImageId != null &&
          !_removeImageIds.contains(_setPrimaryImageId)) {
        images.add({'action': 'set_primary', 'image_id': _setPrimaryImageId});
      }
      if (images.isNotEmpty) proposed['images'] = images;

      if (proposed.isEmpty) {
        setState(() {
          _error = 'Isi minimal satu perubahan';
          _submitting = false;
        });
        return;
      }

      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/words/${widget.wordId}/suggest-edit',
        data: {
          'proposed_changes': proposed,
          'reason_code': _reasonCode,
          if (reasonText.isNotEmpty) 'reason_text': reasonText,
        },
      );
      if (!mounted) return;
      AnalyticsService.instance.log(
        AnalyticsEvents.suggestEditSubmit,
        params: {'word_id': widget.wordId},
      );
      final verified =
          ref.read(wordDetailProvider(widget.wordId)).value?.isVerified ??
              true;
      final lemma = _lemmaCtrl.text.trim();
      final actorRole = ref.read(authStatusProvider).value?.role;
      final selfApplied = suggestEditWasSelfApplied(
        responseStatus: suggestEditStatusFromResponse(response.data),
        actorRole: actorRole,
      );
      final title = suggestEditSuccessToast(
        selfApplied: selfApplied,
        wordVerified: verified,
        lemma: lemma,
      );
      showFToast(
        context: context,
        title: Text(title),
      );
      final router = GoRouter.of(context);
      if (selfApplied) {
        // Self-apply: kembali ke detail kata dengan data segar (bukan antrean).
        ref.invalidate(wordDetailProvider(widget.wordId));
        ref.invalidate(changeHistoryProvider(widget.wordId));
        router.pop();
      } else {
        ref.invalidate(myContributionsListControllerProvider);
        router.pop();
        router.push('/contributions');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      var msg = 'Gagal mengirim usulan';
      if (data is Map && data['message'] is String) {
        msg = data['message'] as String;
      }
      if (mounted) setState(() => _error = msg);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStatusProvider).value;
    final detailAsync = ref.watch(wordDetailProvider(widget.wordId));
    final wordClassesAsync = ref.watch(_suggestWordClassesProvider);
    final theme = context.theme;

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
    final reasonLabels = suggestEditReasonLabels(auth?.role);
    final headerTitle =
        isVerifierRole(auth?.role) ? 'Ubah Kata' : 'Usulkan Perubahan';

    return FScaffold(
      header: FHeader.nested(
        title: Text(headerTitle),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      footer: SafeArea(
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
            child: Text(_submitting ? preSubmit.ctaBusy : preSubmit.cta),
          ),
        ),
      ),
      child: detailAsync.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (e, _) => Center(child: Text('$e')),
        data: (detail) {
          _prefillOnce(detail);
          final hasMeaning = detail.meanings.isNotEmpty;
          return ListView(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
            children: [
              Text(
                preSubmit.banner,
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(12),

              FTextField(
                control: FTextFieldControl.managed(controller: _lemmaCtrl),
                label: const Text('Lemma'),
                hint: 'Contoh: kata',
                textInputAction: TextInputAction.next,
              ),

              if (hasMeaning) ...[
                const Gap(12),
                const _FieldCaption(
                  'Terjemahan Indonesia',
                  info:
                      'Satu kata/frasa setara dengan lemma.\n\n'
                      'Contoh: “makan”. Beda dari definisi.',
                ),
                FTextField(
                  control: FTextFieldControl.managed(controller: _padananCtrl),
                  hint: 'Satu kata/frasa setara di Indonesia',
                  description: const Text(
                    'Tekan icon buku untuk mencari definisi di KBBI',
                  ),
                  textInputAction: TextInputAction.next,
                  suffixBuilder: (context, style, _) => Padding(
                    padding: style.clearButtonPadding,
                    child: FButton.icon(
                      style: style.clearButtonStyle,
                      onPress: _openKbbiSheet,
                      child: Icon(
                        FLucideIcons.bookOpen,
                        semanticLabel: 'Ambil dari KBBI',
                      ),
                    ),
                  ),
                ),
                const Gap(8),
                wordClassesAsync.when(
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
                    final selected = _wordClassId == null
                        ? null
                        : items.where((e) => e.id == _wordClassId).firstOrNull;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _FieldCaption(
                          'Kelas kata',
                          info:
                              'Nomina, verba, adjektiva, dsb. Bisa terisi dari KBBI.',
                        ),
                        _SelectField(
                          selectedLabel: selected?.displayLabel,
                          hint: 'Pilih kelas kata…',
                          onTap: () => _openWordClassSheet(items),
                        ),
                      ],
                    );
                  },
                ),
                const Gap(8),
                const _FieldCaption(
                  'Definisi',
                  info:
                      'Uraian makna berbahasa Indonesia - bukan terjemahan satu kata.',
                ),
                FTextField(
                  control: FTextFieldControl.managed(
                    controller: _definitionCtrl,
                  ),
                  hint: 'Jelaskan makna kata ini',
                  maxLines: 3,
                  minLines: 2,
                ),
              ],

              const Gap(12),
              const _FieldCaption(
                'Kelengkapan',
                info: 'Opsional: catatan, variasi, sinonim, antonim.',
              ),
              _SelectField(
                selectedLabel: _extras.isEmpty ? null : _extras.summaryLabel,
                hint: 'Tambah variasi, sinonim, antonim…',
                onTap: () => _openExtrasSheet(detail),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  'Opsional',
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ),

              const _FieldCaption(
                'Gambar',
                info: 'Opsional. Tambah baru atau tandai hapus yang ada.',
              ),
              ContributeImagesField(
                enabled: true,
                images: _newImages,
                onChanged: (next) => setState(() => _newImages = next),
              ),
              if (detail.images.isNotEmpty) ...[
                const Gap(8),
                for (final img in detail.images)
                  Padding(
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
                            value: _removeImageIds.contains(img.id),
                            label: Text(
                              img.isPrimary ? 'Hapus (utama)' : 'Hapus',
                            ),
                            onChange: (val) {
                              setState(() {
                                if (val) {
                                  _removeImageIds.add(img.id);
                                  if (_setPrimaryImageId == img.id) {
                                    _setPrimaryImageId = null;
                                  }
                                } else {
                                  _removeImageIds.remove(img.id);
                                }
                              });
                            },
                          ),
                        ),
                        if (!_removeImageIds.contains(img.id) && !img.isPrimary)
                          FButton(
                            variant: .outline,
                            onPress: () =>
                                setState(() => _setPrimaryImageId = img.id),
                            child: Text(
                              _setPrimaryImageId == img.id
                                  ? 'Utama ✓'
                                  : 'Jadikan utama',
                            ),
                          ),
                      ],
                    ),
                  ),
              ],

              const Gap(12),
              _FieldCaption(reasonLabels.fieldCaption),
              FTile(
                title: Text(
                  _reasonOptions
                          .where((o) => o.code == _reasonCode)
                          .firstOrNull
                          ?.label ??
                      'Pilih alasan',
                ),
                subtitle: const Text('Ketuk untuk memilih'),
                suffix: Icon(
                  FLucideIcons.chevronRight,
                  size: 16,
                  color: theme.colors.mutedForeground,
                ),
                onPress: () => _openReasonSheet(reasonLabels.sheetTitle),
              ),
              const Gap(8),
              FTextField(
                control: FTextFieldControl.managed(controller: _reasonTextCtrl),
                label: Text(
                  _reasonCode == 'other'
                      ? 'Detail alasan *'
                      : 'Detail tambahan (opsional)',
                ),
                maxLines: 3,
                minLines: 2,
              ),
              if (_error != null) ...[
                const Gap(8),
                Text(
                  _error!,
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.error,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _openReasonSheet(String sheetTitle) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) {
        final sheetTheme = sheetContext.theme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  sheetTitle,
                  style: sheetTheme.typography.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(10),
                FTileGroup(
                  children: [
                    for (final o in _reasonOptions)
                      FTile(
                        title: Text(o.label),
                        suffix: o.code == _reasonCode
                            ? Icon(
                                FLucideIcons.check,
                                size: 18,
                                color: sheetTheme.colors.primary,
                              )
                            : null,
                        onPress: () => Navigator.of(sheetContext).pop(o.code),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || picked == null) return;
    setState(() => _reasonCode = picked);
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
