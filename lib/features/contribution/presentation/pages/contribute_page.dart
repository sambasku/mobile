import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/cache/cache_entry.dart';
import '../../../../core/cache/cache_key.dart';
import '../../../../core/cache/cache_providers.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../dictionary/domain/entities/word_detail.dart';
import '../../../my_contributions/presentation/providers/my_contributions_providers.dart';
import '../../domain/failures/contribution_failure.dart';
import '../../domain/repositories/contribution_repository.dart';
import '../../domain/usecases/submit_anon_word_use_case.dart';
import '../../domain/meaning_source.dart';
import '../models/submit_word_state.dart';
import '../providers/submit_word_providers.dart';
import '../widgets/contribute_images_field.dart';
import '../widgets/contribute_relations_sheet.dart';
import '../widgets/dialect_picker_sheet.dart';
import '../widgets/duplicate_meaning_vote_sheet.dart';
import '../widgets/kbbi_definition_sheet.dart';
import '../widgets/knowledge_toggles.dart';
import '../widgets/word_class_picker_sheet.dart';
import '../../data/providers/contribution_data_providers.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';

class ContributePage extends ConsumerStatefulWidget {
  const ContributePage({
    super.key,
    this.initialLemma,
    this.initialSearchIn,
    this.initialSearchMissId,
  });

  final String? initialLemma;
  final String? initialSearchIn;
  final String? initialSearchMissId;

  @override
  ConsumerState<ContributePage> createState() => _ContributePageState();
}

/// State lokal satu blok makna (controller + flag Definisi/Padanan).
class _MeaningDraft {
  _MeaningDraft({String? initialPadanan})
    : defCtrl = TextEditingController(),
      trCtrl = TextEditingController(text: initialPadanan ?? '');

  final TextEditingController defCtrl;
  final TextEditingController trCtrl;
  String? wordClassId;
  bool wantDefinition = false;
  bool wantPadanan = false;
  String savedDefinition = '';
  String savedTranslation = '';
  KbbiMeaningSnapshot? kbbiSnapshot;
  /// Guard saat apply pick supaya listener tidak clear snapshot.
  bool applyingKbbiPick = false;

  bool get modePicked => wantDefinition || wantPadanan;

  void dispose() {
    defCtrl.dispose();
    trCtrl.dispose();
  }
}

class _ContributePageState extends ConsumerState<ContributePage> {
  late final TextEditingController _lemmaCtrl;
  late final FocusNode _lemmaFocus;
  late final TextEditingController _standardTranslationCtrl;
  late final List<_MeaningDraft> _meanings;

  /// false = mode standar (lemma + terjemahan). true = form lengkap.
  bool _advanced = false;
  String? _dialectId;
  bool _dialectSeeded = false;

  /// Id kelas kata `umum` setelah referensi termuat. Dipakai makna baru.
  String? _umumWordClassId;

  /// Definisi dan kelas kata dari pilihan KBBI. Kosong = entri tanpa definisi.
  String _standardDefinition = '';
  String? _standardWordClassId;
  KbbiMeaningSnapshot? _standardKbbiSnapshot;
  bool _applyingKbbiPick = false;

  /// API `word_type`: word | idiom | peribahasa | ungkapan. Default kata.
  String _wordType = 'word';

  /// Register & peringatan (`usage_labels`). Default kosong.
  final Set<String> _usageLabels = {};

  ContributeRelationsDraft _relations = const ContributeRelationsDraft();
  List<ContributeImageSlot> _images = const [];

  @override
  void initState() {
    super.initState();
    final isTranslationMiss = widget.initialSearchIn == 'translation';
    _lemmaCtrl = TextEditingController(
      text: isTranslationMiss ? '' : (widget.initialLemma ?? ''),
    );
    _lemmaFocus = FocusNode();
    _standardTranslationCtrl = TextEditingController(
      text: isTranslationMiss ? (widget.initialLemma ?? '') : '',
    );
    _meanings = [
      _MeaningDraft(
        initialPadanan: isTranslationMiss ? (widget.initialLemma ?? '') : null,
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final guest = !(ref.read(authStatusProvider).value?.isAuth ?? false);
      AnalyticsService.instance.log(
        AnalyticsEvents.contributeStart,
        params: {
          'guest': guest ? 1 : 0,
          'from': widget.initialSearchMissId != null ? 'search_miss' : 'form',
        },
      );
      ref
          .read(submitWordProvider.notifier)
          .initPrefill(
            lemma: widget.initialLemma,
            searchIn: widget.initialSearchIn,
            searchMissId: widget.initialSearchMissId,
          );
      _lemmaCtrl.addListener(_onFieldEdited);
      _standardTranslationCtrl.addListener(_onStandardTranslationEdited);
      for (final m in _meanings) {
        m.defCtrl.addListener(_onFieldEdited);
        m.trCtrl.addListener(() => _onDraftTranslationEdited(m));
      }
    });
  }

  void _onFieldEdited() {
    ref.read(submitWordProvider.notifier).clearFieldErrors();
  }

  void _onStandardTranslationEdited() {
    _onFieldEdited();
    if (_applyingKbbiPick) return;
    final snap = _standardKbbiSnapshot;
    if (snap == null) return;
    final text = _standardTranslationCtrl.text.trim();
    // Kosongkan padanan: biarkan definisi/kelas (kbbi_edited).
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    // Padanan diganti ke teks lain → definisi KBBI tidak lagi dipercaya.
    if (text != snap.padanan.trim()) {
      setState(() {
        _standardDefinition = '';
        _standardWordClassId = null;
      });
    }
  }

  void _onDraftTranslationEdited(_MeaningDraft draft) {
    _onFieldEdited();
    if (draft.applyingKbbiPick) return;
    final snap = draft.kbbiSnapshot;
    if (snap == null) return;
    final text = draft.trCtrl.text.trim();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    if (text != snap.padanan.trim()) {
      setState(() {
        draft.defCtrl.text = '';
        draft.wordClassId = null;
      });
    }
  }

  MeaningSource _resolveStandardMeaningSource() {
    final source = resolveMeaningSource(
      snapshot: _standardKbbiSnapshot,
      padanan: _standardTranslationCtrl.text,
      definition: _standardDefinition,
      wordClassId: _standardWordClassId,
    );
    if (source == MeaningSource.manual && _standardKbbiSnapshot != null) {
      _standardKbbiSnapshot = null;
    }
    return source;
  }

  MeaningSource _resolveDraftMeaningSource(_MeaningDraft draft) {
    final source = resolveMeaningSource(
      snapshot: draft.kbbiSnapshot,
      padanan: draft.wantPadanan ? draft.trCtrl.text : '',
      definition: draft.wantDefinition ? draft.defCtrl.text : '',
      wordClassId: draft.wordClassId,
    );
    if (source == MeaningSource.manual && draft.kbbiSnapshot != null) {
      draft.kbbiSnapshot = null;
    }
    return source;
  }

  @override
  void dispose() {
    _lemmaCtrl.dispose();
    _lemmaFocus.dispose();
    _standardTranslationCtrl.dispose();
    for (final m in _meanings) {
      m.dispose();
    }
    super.dispose();
  }

  List<String> _parseCsv(String raw) => raw
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);

  List<SubmitWordRelation> _buildRelatedWords() {
    final out = <SubmitWordRelation>[];
    for (final lemma in _parseCsv(_relations.synonymsText)) {
      out.add(SubmitWordRelation(relationType: 'synonym', lemma: lemma));
    }
    for (final lemma in _parseCsv(_relations.antonymsText)) {
      out.add(SubmitWordRelation(relationType: 'antonym', lemma: lemma));
    }
    return out;
  }

  void _addMeaning() {
    if (_meanings.length >= SubmitAnonWordUseCase.maxMeanings) return;
    _onFieldEdited();
    setState(() {
      final draft = _MeaningDraft();
      draft.wordClassId = _umumWordClassId;
      draft.defCtrl.addListener(_onFieldEdited);
      draft.trCtrl.addListener(() => _onDraftTranslationEdited(draft));
      _meanings.add(draft);
    });
  }

  void _removeMeaning(int index) {
    if (_meanings.length <= 1) return;
    _onFieldEdited();
    setState(() {
      final removed = _meanings.removeAt(index);
      removed.dispose();
    });
  }

  /// Form kosong di halaman yang sama setelah "Tambah lagi".
  void _resetFormForAnother() {
    for (final m in _meanings) {
      m.dispose();
    }
    _meanings.clear();
    final draft = _MeaningDraft();
    draft.wordClassId = _umumWordClassId;
    draft.defCtrl.addListener(_onFieldEdited);
    draft.trCtrl.addListener(() => _onDraftTranslationEdited(draft));
    _meanings.add(draft);

    _lemmaCtrl.clear();
    _standardTranslationCtrl.clear();
    setState(() {
      _advanced = false;
      _standardDefinition = '';
      _standardWordClassId = null;
      _standardKbbiSnapshot = null;
      _applyingKbbiPick = false;
      _wordType = 'word';
      _usageLabels.clear();
      _relations = const ContributeRelationsDraft();
      _images = const [];
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _lemmaFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final languagesAsync = ref.watch(_referenceLanguagesProvider);
    final wordClassesAsync = ref.watch(_referenceWordClassesProvider);
    final sambasLanguageId = languagesAsync.value
        ?.where((e) => e.code.toUpperCase() == 'SBS')
        .firstOrNull
        ?.id;
    final dialectsAsync = sambasLanguageId == null
        ? const AsyncValue<List<_OptionItem>>.data([])
        : ref.watch(_referenceDialectsProvider(sambasLanguageId));

    // Auto-select dialek is_default (umum) sekali; user tetap bisa ganti.
    final dialectItems = dialectsAsync.value;
    if (!_dialectSeeded &&
        _dialectId == null &&
        dialectItems != null &&
        dialectItems.isNotEmpty) {
      final def =
          dialectItems.where((e) => e.isDefault).firstOrNull ??
          dialectItems.where((e) => e.code.toLowerCase() == 'umum').firstOrNull;
      if (def != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _dialectSeeded || _dialectId != null) return;
          setState(() {
            _dialectId = def.id;
            _dialectSeeded = true;
          });
        });
      } else {
        _dialectSeeded = true;
      }
    }

    // Isi kelas kata `umum` pada makna yang belum dipilih user.
    final wordClassItems = wordClassesAsync.value;
    final umum = wordClassItems
        ?.where((e) => e.code.toLowerCase() == 'umum')
        .firstOrNull;
    if (umum != null &&
        _meanings.any((m) => m.wordClassId == null || m.wordClassId!.isEmpty)) {
      final umumId = umum.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        var changed = _umumWordClassId != umumId;
        for (final m in _meanings) {
          if (m.wordClassId == null || m.wordClassId!.isEmpty) {
            m.wordClassId = umumId;
            changed = true;
          }
        }
        if (!changed) return;
        setState(() => _umumWordClassId = umumId);
      });
    } else if (umum != null && _umumWordClassId != umum.id) {
      final umumId = umum.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _umumWordClassId == umumId) return;
        setState(() => _umumWordClassId = umumId);
      });
    }

    final state = ref.watch(submitWordProvider);
    final notifier = ref.read(submitWordProvider.notifier);
    final theme = context.theme;
    final isAuth = ref.watch(authStatusProvider).value?.isAuth ?? false;

    ref.listen<SubmitWordState>(submitWordProvider, (prev, next) {
      if (next.result != null && prev?.result == null) {
        // ponytail: show lemma user typed, not server ULID (useless to contributors)
        _showSuccessDialog(context, _lemmaCtrl.text.trim());
        return;
      }

      final failure = next.failure;
      if (failure is ContributionFailure && prev?.failure != failure) {
        if (failure.isDuplicateMeaning) {
          // ignore: unawaited_futures
          _handleDuplicateMeaning(context, failure, isAuth);
          return;
        }
        if (failure.isValidationError) {
          showFToast(
            context: context,
            title: const Text('Periksa kembali isian yang ditandai merah'),
            variant: FToastVariant.destructive,
          );
          return;
        }
        if (failure.isRateLimited) {
          showFToast(
            context: context,
            title: Text(failure.message),
            variant: FToastVariant.destructive,
          );
          ref.read(submitWordProvider.notifier).clearError();
          return;
        }
        final message = failure.message.isNotEmpty ? failure.message : null;
        if (message != null && context.mounted) {
          showAppErrorSheet(context, message: message).whenComplete(() {
            if (context.mounted) {
              ref.read(submitWordProvider.notifier).clearError();
            }
          });
        }
      }
    });

    return FScaffold(
      header: FHeader.nested(
        title: const Text('Usulkan'),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop() ? context.pop() : context.go('/'),
          ),
        ],
      ),
      footer: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FButton(
                onPress: state.isSubmitting ? null : _submitForm,
                prefix: state.isSubmitting ? const FCircularProgress() : null,
                child: Text(
                  state.isSubmitting ? 'Mengirim...' : 'Kirim Usulan',
                ),
              ),
            ],
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
        children: [
          Text(
            isAuth
                ? 'Kata langsung tayang dengan label Menunggu pengecekan. Tim akan memeriksanya.'
                : 'Dikirim sebagai tamu. Kata belum tayang. Tim akan memeriksanya dulu.',
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(12),
          FTileGroup(
            children: [
              FTile(
                prefix: Icon(
                  FLucideIcons.listPlus,
                  color: theme.colors.primary,
                ),
                title: const Text('Usulkan banyak sekaligus'),
                subtitle: const Text(
                  'Isi beberapa kata dan terjemahan dalam satu layar',
                ),
                suffix: const Icon(FLucideIcons.chevronRight),
                onPress: () => context.push('/contribute/bulk'),
              ),
            ],
          ),
          const Gap(12),
          const _FieldCaption('Cara mengisi'),
          const Gap(6),
          _ContributeModeChips(
            advanced: _advanced,
            onChanged: (advanced) {
              _onFieldEdited();
              setState(() {
                final turningOn = advanced && !_advanced;
                _advanced = advanced;
                if (!turningOn) return;
                final text = _standardTranslationCtrl.text.trim();
                final first = _meanings.first;
                if (first.modePicked) return;
                if (text.isNotEmpty) {
                  first.wantPadanan = true;
                  first.trCtrl.text = text;
                }
                final definition = _standardDefinition.trim();
                if (definition.isNotEmpty) {
                  first.wantDefinition = true;
                  first.defCtrl.text = definition;
                }
                if (_standardWordClassId != null) {
                  first.wordClassId = _standardWordClassId;
                }
              });
            },
          ),
          const Gap(12),

          FTextField(
            control: FTextFieldControl.managed(controller: _lemmaCtrl),
            focusNode: _lemmaFocus,
            label: const Text('Kata / ungkapan Sambas *'),
            hint: 'Isi kata, peribahasa, atau ungkapan',
            textInputAction: TextInputAction.next,
          ),
          _inlineError(notifier.errorFor('lemma')),

          if (!_advanced) ...[
            const Gap(12),
            FTextField(
              control: FTextFieldControl.managed(
                controller: _standardTranslationCtrl,
              ),
              label: const Text('Terjemahan Indonesia *'),
              hint: 'Satu kata/frasa setara di Indonesia',
              description: const Text(
                'Tekan icon buku untuk mencari definisi di KBBI',
              ),
              textInputAction: TextInputAction.done,
              suffixBuilder: (context, style, _) => Padding(
                padding: style.clearButtonPadding,
                child: FButton.icon(
                  style: style.clearButtonStyle,
                  onPress: _openStandardKbbiSheet,
                  child: Icon(
                    FLucideIcons.bookOpen,
                    semanticLabel: 'Ambil dari KBBI',
                  ),
                ),
              ),
            ),
            _inlineError(notifier.errorForMeaning(0, 'translation_texts')),
            _inlineError(notifier.errorForMeaning(0, 'definition')),
            if (_standardDefinition.trim().isNotEmpty) ...[
              const Gap(12),
              const _FieldCaption(
                'Penjelasan arti',
                info:
                    'Muncul setelah satu makna dipilih dari KBBI. Tetap jika terjemahan dikosongkan; hilang jika terjemahan diganti kata lain.',
              ),
              Text(
                _standardDefinition.trim(),
                style: theme.typography.sm.copyWith(height: 1.4),
              ),
            ],
            const Gap(12),
            const _FieldCaption(
              'Register',
              info:
                  'Opsional. Gaya atau pantangan berbahasa. '
                  'Halus dan Kasar tidak bisa dipilih bersamaan.',
            ),
            const Gap(6),
            _UsageLabelChips(
              options: kRegisterUsageLabels,
              selected: _usageLabels,
              onToggle: _toggleUsageLabel,
            ),
            const Gap(12),
            const _FieldCaption(
              'Peringatan',
              info: 'Opsional. Sensitivitas isi makna.',
            ),
            const Gap(6),
            _UsageLabelChips(
              options: kWarningUsageLabels,
              selected: _usageLabels,
              onToggle: _toggleUsageLabel,
            ),
            _inlineError(notifier.errorFor('usage_labels')),
          ] else ...[
            const Gap(12),
            const _FieldCaption('Jenis'),
            const Gap(6),
            _WordTypeChips(
              value: _wordType,
              onChanged: (v) {
                _onFieldEdited();
                setState(() => _wordType = v);
              },
            ),
            _inlineError(notifier.errorFor('word_type')),
            const Gap(12),
            const _FieldCaption(
              'Register',
              info:
                  'Opsional. Gaya atau pantangan berbahasa. '
                  'Halus dan Kasar tidak bisa dipilih bersamaan.',
            ),
            const Gap(6),
            _UsageLabelChips(
              options: kRegisterUsageLabels,
              selected: _usageLabels,
              onToggle: _toggleUsageLabel,
            ),
            const Gap(12),
            const _FieldCaption(
              'Peringatan',
              info: 'Opsional. Sensitivitas isi makna.',
            ),
            const Gap(6),
            _UsageLabelChips(
              options: kWarningUsageLabels,
              selected: _usageLabels,
              onToggle: _toggleUsageLabel,
            ),
            _inlineError(notifier.errorFor('usage_labels')),
            const Gap(8),

            const _FieldCaption('Dialek'),
            if (sambasLanguageId == null)
              const _SelectFieldSkeleton()
            else
              dialectsAsync.when(
                loading: () => const _SelectFieldSkeleton(),
                error: (e, _) => _BuildReferenceError(
                  message: 'Gagal muat dialek',
                  onRetry: () => ref.invalidate(
                    _referenceDialectsProvider(sambasLanguageId),
                  ),
                ),
                data: (items) {
                  final selected = _dialectId == null
                      ? null
                      : items.where((e) => e.id == _dialectId).firstOrNull;
                  return _SelectField(
                    selectedLabel: selected?.name,
                    hint: items.isEmpty ? '-' : 'Pilih dialek…',
                    onTap: items.isEmpty
                        ? null
                        : () => _openDialectSheet(items),
                  );
                },
              ),
            _inlineError(notifier.errorFor('dialect_id')),
            _inlineError(notifier.errorFor('language_id')),
            const Gap(16),
            const _FieldCaption(
              'Makna *',
              info:
                  'Satu kata bisa punya beberapa arti.\n\n'
                  'Tiap blok: centang Penjelasan arti dan/atau Terjemahan, isi kelas kata.',
            ),
            const Gap(8),
            for (var i = 0; i < _meanings.length; i++) ...[
              _MeaningBlock(
                index: i,
                draft: _meanings[i],
                canRemove: _meanings.length > 1,
                isTranslationMiss: widget.initialSearchIn == 'translation',
                wordClassesAsync: wordClassesAsync,
                onRetryWordClasses: () =>
                    ref.invalidate(_referenceWordClassesProvider),
                onRemove: () => _removeMeaning(i),
                onWantDefinition: (v) => _setWantDefinition(i, v),
                onWantPadanan: (v) => _setWantPadanan(i, v),
                onPickWordClass: (items) => _openWordClassSheet(i, items),
                onOpenKbbi: () => _openKbbiSheet(i),
                definitionError: notifier.errorForMeaning(i, 'definition'),
                padananError: notifier.errorForMeaning(i, 'translation_texts'),
                wordClassError: notifier.errorForMeaning(i, 'word_class_id'),
              ),
              if (i < _meanings.length - 1) const Gap(12),
            ],
            const Gap(8),
            if (_meanings.length < SubmitAnonWordUseCase.maxMeanings)
              FButton(
                variant: FButtonVariant.outline,
                onPress: _addMeaning,
                prefix: Icon(FLucideIcons.plus, size: 16),
                child: const Text('Tambah makna'),
              )
            else
              Text(
                'Maksimal ${SubmitAnonWordUseCase.maxMeanings} makna per usulan.',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            const Gap(12),

            const _FieldCaption(
              'Kelengkapan',
              info:
                  'Opsional: variasi ejaan, sinonim, antonim. Dibuka di bottomsheet.',
            ),
            _SelectField(
              selectedLabel: _relations.isEmpty
                  ? null
                  : _relations.summaryLabel,
              hint: 'Tambah variasi, sinonim, antonim…',
              onTap: _openRelationsSheet,
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
              info:
                  'Opsional. Media Explorer tanpa login; kamera/galeri perlu masuk. Maks 3.',
            ),
            ContributeImagesField(
              enabled: true,
              allowLocalPick: isAuth,
              images: _images,
              onChanged: (next) => setState(() => _images = next),
            ),
          ],
        ],
      ),
    );
  }

  void _setWantDefinition(int index, bool next) {
    final draft = _meanings[index];
    if (next == draft.wantDefinition) return;
    _onFieldEdited();
    setState(() {
      if (draft.wantDefinition && !next) {
        draft.savedDefinition = draft.defCtrl.text;
        draft.defCtrl.text = '-';
      } else if (!draft.wantDefinition && next) {
        draft.defCtrl.text = draft.savedDefinition == '-'
            ? ''
            : draft.savedDefinition;
      }
      draft.wantDefinition = next;
      if (!draft.wantDefinition &&
          (draft.defCtrl.text.trim().isEmpty ||
              draft.defCtrl.text.trim() == '-')) {
        draft.defCtrl.text = '-';
      } else if (draft.wantDefinition && draft.defCtrl.text.trim() == '-') {
        draft.defCtrl.text = '';
      }
    });
  }

  void _setWantPadanan(int index, bool next) {
    final draft = _meanings[index];
    if (next == draft.wantPadanan) return;
    _onFieldEdited();
    setState(() {
      if (draft.wantPadanan && !next) {
        draft.savedTranslation = draft.trCtrl.text;
        draft.trCtrl.text = '';
      } else if (!draft.wantPadanan && next) {
        draft.trCtrl.text = draft.savedTranslation;
      }
      draft.wantPadanan = next;
    });
  }

  void _toggleUsageLabel(String code) {
    _onFieldEdited();
    final selected = _usageLabels.contains(code);
    if (!selected) {
      final next = {..._usageLabels, code};
      if (hasConflictingUsageLabels(next)) {
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

  Future<void> _openDialectSheet(List<_OptionItem> items) async {
    final picked = await showDialectPickerSheet(
      context,
      items: [
        for (final e in items)
          DialectPickItem(id: e.id, name: e.name, isDefault: e.isDefault),
      ],
      selectedId: _dialectId,
    );
    if (!mounted || picked == null) return;
    _onFieldEdited();
    setState(() {
      _dialectId = picked.id;
      _dialectSeeded = true;
    });
  }

  Future<void> _openWordClassSheet(int index, List<_OptionItem> items) async {
    final draft = _meanings[index];
    final picked = await showWordClassPickerSheet(
      context,
      items: [
        for (final e in items)
          WordClassPickItem(id: e.id, name: e.name, alias: e.alias),
      ],
      selectedId: draft.wordClassId,
    );
    if (!mounted || picked == null) return;
    _onFieldEdited();
    setState(() => draft.wordClassId = picked.id);
  }

  Future<void> _openRelationsSheet() async {
    final result = await showContributeRelationsSheet(
      context,
      initial: _relations,
      lemma: _lemmaCtrl.text,
    );
    if (!mounted || result == null) return;
    _onFieldEdited();
    setState(() => _relations = result);
  }

  Future<void> _openStandardKbbiSheet() async {
    final dio = ref.read(dioProvider);
    final picked = await showKbbiDefinitionSheet(
      context,
      dio: dio,
      initialLemma: _standardTranslationCtrl.text.trim(),
    );
    if (!mounted || picked == null) return;

    final classes =
        ref.read(_referenceWordClassesProvider).value ?? const <_OptionItem>[];
    final matched = _matchWordClassId(
      classes,
      picked.wordClassCode,
      picked.wordClassLabel,
    );

    _onFieldEdited();
    setState(() {
      _applyingKbbiPick = true;
      final lemmaId = picked.lemma.trim();
      final definition = picked.definition.trim();
      if (lemmaId.isNotEmpty) {
        _standardTranslationCtrl.text = lemmaId;
      }
      _standardDefinition = definition;
      if (matched != null) _standardWordClassId = matched;
      _standardKbbiSnapshot = KbbiMeaningSnapshot(
        padanan: lemmaId,
        definition: definition,
        wordClassId: matched,
      );
      _applyingKbbiPick = false;
    });

    final parts = <String>['Terjemahan'];
    if (_standardDefinition.isNotEmpty) parts.add('definisi');
    if (matched != null) parts.add('kelas kata');
    showFToast(
      context: context,
      title: Text('${parts.join(', ')} diisi dari KBBI - silakan review'),
    );
  }

  Future<void> _openKbbiSheet(int index) async {
    // Lookup KBBI publik - tamu tidak perlu login.
    final draft = _meanings[index];
    final dio = ref.read(dioProvider);
    final picked = await showKbbiDefinitionSheet(
      context,
      dio: dio,
      initialLemma: draft.trCtrl.text.trim(),
    );
    if (!mounted || picked == null) return;

    final classes =
        ref.read(_referenceWordClassesProvider).value ?? const <_OptionItem>[];
    final matched = _matchWordClassId(
      classes,
      picked.wordClassCode,
      picked.wordClassLabel,
    );

    _onFieldEdited();
    setState(() {
      draft.applyingKbbiPick = true;
      draft.wantDefinition = true;
      draft.wantPadanan = true;
      draft.defCtrl.text = picked.definition;
      // Lemma KBBI = padanan Indonesia
      final lemmaId = picked.lemma.trim();
      if (lemmaId.isNotEmpty) {
        draft.trCtrl.text = lemmaId;
      }
      if (matched != null) {
        draft.wordClassId = matched;
      }
      draft.kbbiSnapshot = KbbiMeaningSnapshot(
        padanan: lemmaId,
        definition: picked.definition.trim(),
        wordClassId: matched,
      );
      draft.applyingKbbiPick = false;
    });

    final parts = <String>['Penjelasan arti'];
    if (matched != null) parts.add('kelas kata');
    if (picked.lemma.trim().isNotEmpty) parts.add('terjemahan');
    showFToast(
      context: context,
      title: Text('${parts.join(', ')} diisi dari KBBI - silakan review'),
    );
  }

  Future<void> _submitForm() async {
    if (!_advanced) {
      if (_standardTranslationCtrl.text.trim().isEmpty) {
        showFToast(
          context: context,
          title: const Text('Isi terjemahan bahasa Indonesia'),
        );
        return;
      }
    } else {
      if (hasConflictingUsageLabels(_usageLabels)) {
        showFToast(
          context: context,
          title: const Text('Halus dan Kasar tidak bisa dipilih bersamaan'),
        );
        return;
      }
      final incomplete = _meanings.indexWhere((m) => !m.modePicked);
      if (incomplete >= 0) {
        showFToast(
          context: context,
          title: Text(
            'Makna ${incomplete + 1}: centang dulu Penjelasan arti dan/atau Terjemahan',
          ),
        );
        return;
      }
      if (_images.any((e) => e.uploading)) {
        showFToast(
          context: context,
          title: const Text('Tunggu upload gambar selesai'),
        );
        return;
      }
      if (_images.any((e) => e.error)) {
        showFToast(
          context: context,
          title: const Text('Hapus gambar yang gagal diunggah dulu'),
          variant: FToastVariant.destructive,
        );
        return;
      }
    }
    final notifier = ref.read(submitWordProvider.notifier);
    final languages =
        ref.read(_referenceLanguagesProvider).value ?? const <_OptionItem>[];
    final languageId =
        languages.where((e) => e.code.toUpperCase() == 'SBS').firstOrNull?.id ??
        '';
    final translationLanguageId =
        languages.where((e) => e.code.toUpperCase() == 'IDN').firstOrNull?.id ??
        '';
    // Mode Dasar juga kirim dialek umum bila sudah termuat. Jangan kirim
    // `dialect_id: null` - Zod `.optional()` menolak null (bukan omit).
    var dialectId = _dialectId;
    if ((dialectId == null || dialectId.isEmpty) && languageId.isNotEmpty) {
      final dialectItems = ref
          .read(_referenceDialectsProvider(languageId))
          .value;
      dialectId =
          dialectItems?.where((e) => e.isDefault).firstOrNull?.id ??
          dialectItems
              ?.where((e) => e.code.toLowerCase() == 'umum')
              .firstOrNull
              ?.id;
    }
    final notes = _relations.notesText.trim();
    final meanings = _advanced
        ? [
            for (final m in _meanings)
              SubmitAnonWordMeaningParams(
                wordClassId: m.wordClassId ?? '',
                definition: m.wantDefinition ? m.defCtrl.text : '-',
                isHaveDefinition: m.wantDefinition,
                isHaveTranslation: m.wantPadanan,
                meaningSource: _resolveDraftMeaningSource(m).apiValue,
                translationTexts: m.wantPadanan ? [m.trCtrl.text] : const [],
              ),
          ]
        : [
            SubmitAnonWordMeaningParams(
              wordClassId: _standardWordClassId ?? _umumWordClassId ?? '',
              definition: _standardDefinition.trim().isEmpty
                  ? '-'
                  : _standardDefinition.trim(),
              isHaveDefinition: _standardDefinition.trim().isNotEmpty,
              isHaveTranslation: true,
              meaningSource: _resolveStandardMeaningSource().apiValue,
              translationTexts: [_standardTranslationCtrl.text],
            ),
          ];
    await notifier.submit(
      lemma: _lemmaCtrl.text,
      languageId: languageId,
      meanings: meanings,
      dialectId: dialectId,
      wordType: _advanced ? _wordType : 'word',
      categoryIds: [],
      usageLabels: _usageLabels.toList(growable: false),
      notes: _advanced && notes.isNotEmpty ? notes : null,
      spellingVariants: _advanced
          ? _parseCsv(_relations.variantsText)
          : const [],
      relatedWords: _advanced ? _buildRelatedWords() : const [],
      translationLanguageId: translationLanguageId,
      images: _advanced ? readySubmitImages(_images) : const [],
      searchMissId: widget.initialSearchMissId,
    );
  }

  Widget _inlineError(String? message) {
    if (message == null || message.isEmpty) return const SizedBox.shrink();
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        message,
        style: theme.typography.sm.copyWith(color: theme.colors.error),
      ),
    );
  }

  Future<void> _handleDuplicateMeaning(
    BuildContext context,
    ContributionFailure failure,
    bool isAuth,
  ) async {
    final lemma = failure.duplicateLemma?.trim().isNotEmpty == true
        ? failure.duplicateLemma!.trim()
        : (_lemmaCtrl.text.trim().isNotEmpty
              ? _lemmaCtrl.text.trim()
              : 'kata ini');
    final wordId = failure.duplicateWordId;
    final meaningId = failure.duplicateMeaningId;
    if (wordId == null || meaningId == null) {
      showFToast(
        context: context,
        title: Text(failure.message),
        variant: FToastVariant.destructive,
      );
      return;
    }

    final choice = await showDuplicateMeaningVoteSheet(
      context: context,
      lemma: lemma,
      isAuthenticated: isAuth,
    );
    if (!context.mounted || choice == null) return;

    if (choice == DuplicateMeaningVoteChoice.login) {
      await context.push('/login');
      return;
    }

    final value = choice == DuplicateMeaningVoteChoice.upvote ? 1 : -1;
    final repo = ref.read(contributionRepositoryProvider);
    final result = await repo.confirmDuplicateMeaning(
      wordId: wordId,
      meaningId: meaningId,
      value: value,
    );
    if (!context.mounted) return;
    await result.match(
      (err) async {
        showFToast(
          context: context,
          title: Text(err.message),
          variant: FToastVariant.destructive,
        );
      },
      (message) async {
        final goHistory = await showFDialog<bool>(
          context: context,
          builder: (dialogContext, style, animation) => FDialog(
            style: style,
            animation: animation,
            direction: Axis.vertical,
            title: const Text('Tercatat di riwayat'),
            body: Text(message),
            actions: [
              FButton(
                onPress: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Lihat riwayat'),
              ),
              FButton(
                variant: FButtonVariant.outline,
                onPress: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
        if (!context.mounted) return;
        if (goHistory == true) {
          context.push('/words/$wordId/history');
        }
      },
    );
  }

  Future<void> _showSuccessDialog(BuildContext context, String lemma) async {
    final isAuth = ref.read(authStatusProvider).value?.isAuth ?? false;
    final successText = isAuth
        ? (lemma.isNotEmpty
              ? '"$lemma" sudah tayang dengan label Menunggu pengecekan. Tim akan memeriksanya.'
              : 'Kata sudah tayang dengan label Menunggu pengecekan. Tim akan memeriksanya.')
        : 'Dikirim sebagai tamu. Kata belum tayang. Tim akan memeriksanya dulu.';

    final choice = await showFDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext, style, animation) => FDialog(
        style: style,
        animation: animation,
        direction: Axis.vertical,
        title: const Text('Usulan terkirim'),
        body: Text(successText),
        actions: [
          FButton(
            onPress: () => Navigator.of(dialogContext).pop('again'),
            child: const Text('Tambah lagi'),
          ),
          FButton(
            variant: FButtonVariant.outline,
            onPress: () => Navigator.of(dialogContext).pop('list'),
            child: const Text('Lihat usulan'),
          ),
          FButton(
            variant: FButtonVariant.ghost,
            onPress: () => Navigator.of(dialogContext).pop('home'),
            child: const Text('Ke beranda'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    // Form sudah terkirim. Jangan biarkan /contribute tetap di bawah
    // halaman berikutnya: tombol kembali akan membuka isian yang sama lagi.
    switch (choice) {
      case 'again':
        ref.read(submitWordProvider.notifier).resetForAnother();
        _resetFormForAnother();
      case 'list':
        ref.invalidate(myContributionsListControllerProvider);
        context.pushReplacement('/contributions');
      case 'home':
        context.go('/');
      default:
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
    }
  }
}

class _MeaningBlock extends StatelessWidget {
  const _MeaningBlock({
    required this.index,
    required this.draft,
    required this.canRemove,
    required this.isTranslationMiss,
    required this.wordClassesAsync,
    required this.onRetryWordClasses,
    required this.onRemove,
    required this.onWantDefinition,
    required this.onWantPadanan,
    required this.onPickWordClass,
    required this.onOpenKbbi,
    required this.definitionError,
    required this.padananError,
    required this.wordClassError,
  });

  final int index;
  final _MeaningDraft draft;
  final bool canRemove;
  final bool isTranslationMiss;
  final AsyncValue<List<_OptionItem>> wordClassesAsync;
  final VoidCallback onRetryWordClasses;
  final VoidCallback onRemove;
  final ValueChanged<bool> onWantDefinition;
  final ValueChanged<bool> onWantPadanan;
  final void Function(List<_OptionItem> items) onPickWordClass;
  final VoidCallback onOpenKbbi;
  final String? definitionError;
  final String? padananError;
  final String? wordClassError;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Makna ${index + 1}',
                    style: theme.typography.sm.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (canRemove)
                  FButton(
                    variant: FButtonVariant.ghost,
                    onPress: onRemove,
                    child: Text(
                      'Hapus',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.error,
                      ),
                    ),
                  ),
              ],
            ),
            const Gap(8),
            const _FieldCaption(
              'Apa yang kamu ketahui? *',
              info:
                  'Centang yang kamu tahu (boleh keduanya).\n\n'
                  '• Penjelasan arti - uraian makna berbahasa Indonesia.\n'
                  '• Terjemahan - satu kata/frasa setara.\n\n'
                  'Form di bawah muncul sesuai centangan.',
            ),
            const Gap(8),
            KnowledgeToggles(
              wantDefinition: draft.wantDefinition,
              wantPadanan: draft.wantPadanan,
              onDefinitionChanged: onWantDefinition,
              onPadananChanged: onWantPadanan,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Text(
                knowledgeHint(
                  wantDefinition: draft.wantDefinition,
                  wantPadanan: draft.wantPadanan,
                ),
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                  height: 1.35,
                ),
              ),
            ),
            if (draft.modePicked) ...[
              if (draft.wantPadanan) ...[
                const Gap(8),
                _FieldCaption(
                  isTranslationMiss
                      ? 'Terjemahan Sambas *'
                      : 'Terjemahan Indonesia *',
                  info: isTranslationMiss
                      ? 'Satu kata/frasa Sambas yang setara - bukan uraian panjang.'
                      : 'Satu kata/frasa Indonesia yang setara dengan kata Sambas.\n\n'
                            'Contoh: “makan”. Beda dari penjelasan arti (“aktivitas memasukkan makanan ke mulut”).',
                ),
                FTextField(
                  control: FTextFieldControl.managed(controller: draft.trCtrl),
                  hint: isTranslationMiss
                      ? 'Terjemahan dalam bahasa Sambas'
                      : 'Satu kata/frasa setara di Indonesia',
                  description: isTranslationMiss
                      ? null
                      : const Text(
                          'Tekan icon buku untuk mencari definisi di KBBI',
                        ),
                  textInputAction: TextInputAction.next,
                  suffixBuilder: (context, style, _) => Padding(
                    padding: style.clearButtonPadding,
                    child: FButton.icon(
                      style: style.clearButtonStyle,
                      onPress: onOpenKbbi,
                      child: Icon(
                        FLucideIcons.bookOpen,
                        semanticLabel: 'Ambil dari KBBI',
                      ),
                    ),
                  ),
                ),
                _MeaningInlineError(padananError),
              ],
              const Gap(8),
              wordClassesAsync.when(
                loading: () => const _SelectFieldSkeleton(),
                error: (e, _) => _BuildReferenceError(
                  message: 'Gagal muat kelas kata',
                  onRetry: onRetryWordClasses,
                ),
                data: (items) {
                  final selected = draft.wordClassId == null
                      ? null
                      : items
                            .where((e) => e.id == draft.wordClassId)
                            .firstOrNull;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _FieldCaption(
                        'Kelas kata *',
                        info:
                            'Nomina, verba, adjektiva, dsb. Bisa dibantu isi lewat ikon buku di kolom terjemahan.',
                      ),
                      _SelectField(
                        selectedLabel: selected?.displayLabel,
                        hint: 'Pilih kelas kata…',
                        onTap: () => onPickWordClass(items),
                      ),
                    ],
                  );
                },
              ),
              _MeaningInlineError(wordClassError),
              if (draft.wantDefinition) ...[
                const Gap(8),
                const _FieldCaption(
                  'Penjelasan arti *',
                  info:
                      'Uraian makna berbahasa Indonesia - bukan terjemahan satu kata.\n\n'
                      'Contoh: “aktivitas memasukkan makanan ke mulut”.',
                ),
                FTextField(
                  control: FTextFieldControl.managed(controller: draft.defCtrl),
                  hint: 'Jelaskan arti kata ini',
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  maxLines: 3,
                  minLines: 2,
                ),
                _MeaningInlineError(definitionError),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _MeaningInlineError extends StatelessWidget {
  const _MeaningInlineError(this.message);

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) return const SizedBox.shrink();
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        message!,
        style: theme.typography.sm.copyWith(color: theme.colors.error),
      ),
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

/// Ikon ⓘ - tap buka penjelasan singkat (FPopover, lebih jelas di touch
/// daripada FTooltip long-press).
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
          size: 16,
          color: theme.colors.mutedForeground,
        ),
      ),
    );
  }
}

class _SelectFieldSkeleton extends StatelessWidget {
  const _SelectFieldSkeleton();

  @override
  Widget build(BuildContext context) {
    final materialBrightness = Theme.of(context).brightness;
    final isDark = materialBrightness == Brightness.dark;
    final muted = context.theme.colors.muted;
    final shimmer = ShimmerEffect(
      baseColor: isDark
          ? muted.withValues(alpha: 0.35)
          : const Color(0xFFE7E7EA),
      highlightColor: isDark
          ? muted.withValues(alpha: 0.55)
          : const Color(0xFFF4F4F5),
      duration: const Duration(milliseconds: 1500),
    );

    return SkeletonizerConfig(
      data: SkeletonizerConfigData(effect: shimmer),
      child: Skeletonizer(
        enabled: true,
        child: IgnorePointer(
          child: _SelectField(
            selectedLabel: 'Memuat dialek',
            hint: 'Pilih dialek…',
            onTap: null,
          ),
        ),
      ),
    );
  }
}

class _OptionItem {
  const _OptionItem({
    required this.id,
    required this.name,
    this.code = '',
    this.alias,
    this.isDefault = false,
  });
  final String id;
  final String name;
  final String code;
  final String? alias;
  final bool isDefault;

  String get displayLabel =>
      (alias == null || alias!.isEmpty) ? name : '$name ($alias)';
}

final _referenceLanguagesProvider = FutureProvider<List<_OptionItem>>((
  ref,
) async {
  final cache = ref.watch(cachedJsonClientProvider);
  final dio = ref.watch(dioProvider);
  final key = buildCacheKey(
    method: 'GET',
    path: '/api/v1/languages',
    query: const {'is_active': 'true'},
  );
  final data = await cache.getOrFetch(
    key: key,
    cacheClass: CacheClass.referenceStatic,
    fetch: () async {
      final resp = await dio.get<dynamic>('/api/v1/languages?is_active=true');
      final body = resp.data;
      if (body is! Map) {
        throw StateError('Envelope languages tidak valid');
      }
      return Map<String, dynamic>.from(body);
    },
  );
  final arr = data['data'];
  if (arr is! List) return [];
  return arr
      .whereType<Map>()
      .map(
        (e) => _OptionItem(
          id: e['id']?.toString() ?? '',
          name: e['name']?.toString() ?? '(?)',
          code: e['code']?.toString() ?? '',
        ),
      )
      .where((e) => e.id.isNotEmpty)
      .toList(growable: false);
});

final _referenceWordClassesProvider = FutureProvider<List<_OptionItem>>((
  ref,
) async {
  final cache = ref.watch(cachedJsonClientProvider);
  final dio = ref.watch(dioProvider);
  final key = buildCacheKey(method: 'GET', path: '/api/v1/word-classes');
  final data = await cache.getOrFetch(
    key: key,
    cacheClass: CacheClass.referenceStatic,
    fetch: () async {
      final resp = await dio.get<dynamic>('/api/v1/word-classes');
      final body = resp.data;
      if (body is! Map) {
        throw StateError('Envelope word-classes tidak valid');
      }
      return Map<String, dynamic>.from(body);
    },
  );
  final arr = data['data'];
  if (arr is! List) return [];
  return arr
      .whereType<Map>()
      .map(
        (e) => _OptionItem(
          id: e['id']?.toString() ?? '',
          name: e['name']?.toString() ?? '(?)',
          code: e['code']?.toString() ?? '',
          alias: e['alias']?.toString(),
        ),
      )
      .where((e) => e.id.isNotEmpty)
      .toList(growable: false);
});

String? _matchWordClassId(
  List<_OptionItem> classes,
  String? code,
  String? label,
) {
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

final _referenceDialectsProvider =
    FutureProvider.family<List<_OptionItem>, String>((ref, languageId) async {
      final cache = ref.watch(cachedJsonClientProvider);
      final dio = ref.watch(dioProvider);
      final query = <String, dynamic>{'language_id': languageId};
      final key = buildCacheKey(
        method: 'GET',
        path: '/api/v1/dialects',
        query: query,
      );
      final data = await cache.getOrFetch(
        key: key,
        cacheClass: CacheClass.referenceStatic,
        fetch: () async {
          final resp = await dio.get<dynamic>(
            '/api/v1/dialects',
            queryParameters: query,
          );
          final body = resp.data;
          if (body is! Map) {
            throw StateError('Envelope dialects tidak valid');
          }
          return Map<String, dynamic>.from(body);
        },
      );
      final arr = data['data'];
      if (arr is! List) return [];
      return arr
          .whereType<Map>()
          .map(
            (e) => _OptionItem(
              id: e['id']?.toString() ?? '',
              name: e['name']?.toString() ?? '(?)',
              code: e['code']?.toString() ?? '',
              isDefault: e['is_default'] == true,
            ),
          )
          .where((e) => e.id.isNotEmpty)
          .toList(growable: false);
    });

class _BuildReferenceError extends StatelessWidget {
  const _BuildReferenceError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: context.theme.typography.sm.copyWith(
              color: context.theme.colors.error,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        FButton(
          onPress: onRetry,
          variant: FButtonVariant.ghost,
          child: const Text('Ulangi'),
        ),
      ],
    );
  }
}

const _wordTypeOptions = <({String value, String label})>[
  (value: 'word', label: 'Kata'),
  (value: 'idiom', label: 'Idiom'),
  (value: 'peribahasa', label: 'Peribahasa'),
  (value: 'ungkapan', label: 'Ungkapan'),
];

class _ContributeModeChips extends StatelessWidget {
  const _ContributeModeChips({required this.advanced, required this.onChanged});

  final bool advanced;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeChip(
            label: 'Sederhana',
            selected: !advanced,
            onTap: () => onChanged(false),
          ),
        ),
        const Gap(8),
        Expanded(
          child: _ModeChip(
            label: 'Lengkap',
            selected: advanced,
            onTap: () => onChanged(true),
          ),
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? theme.colors.primary.withValues(alpha: 0.08)
              : theme.colors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? theme.colors.primary : theme.colors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.typography.sm.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? theme.colors.primary : theme.colors.foreground,
            ),
          ),
        ),
      ),
    );
  }
}

/// Picker jenis entri - pola chip sama seperti dialek (rekam) / filter komentar.
class _WordTypeChips extends StatelessWidget {
  const _WordTypeChips({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final opt in _wordTypeOptions)
          GestureDetector(
            onTap: () => onChanged(opt.value),
            child: FBadge(
              variant: value == opt.value
                  ? FBadgeVariant.primary
                  : FBadgeVariant.secondary,
              child: Text(opt.label),
            ),
          ),
      ],
    );
  }
}

/// Multi-select Register / Peringatan (`usage_labels`).
class _UsageLabelChips extends StatelessWidget {
  const _UsageLabelChips({
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final code in options)
          GestureDetector(
            onTap: () => onToggle(code),
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
