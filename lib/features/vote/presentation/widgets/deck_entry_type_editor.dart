import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/gestures/swipe_exempt.dart';
import '../../../../core/network/api_error_text.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../shared/reference/reference_data.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/word_type_picker_sheet.dart';
import '../../../contribution/presentation/widgets/word_class_picker_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../contribution/presentation/utils/invalidate_word_detail.dart';
import '../../../dictionary/domain/entities/word_detail.dart';
import '../../../suggest_edit/domain/suggest_edit_feedback.dart';
import '../../domain/deck_type_suggestion.dart';

/// Jenis entri + kelas Umum di kartu deck. Pilihan langsung jadi usulan edit.
class DeckEntryTypeEditor extends ConsumerStatefulWidget {
  const DeckEntryTypeEditor({super.key, required this.detail});

  final WordDetail detail;

  @override
  ConsumerState<DeckEntryTypeEditor> createState() =>
      _DeckEntryTypeEditorState();
}

class _DeckEntryTypeEditorState extends ConsumerState<DeckEntryTypeEditor> {
  late String _wordType;
  late String _savedWordType;
  final _classByMeaning = <String, String>{};
  final _savedClass = <String, String>{};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _syncFromDetail();
  }

  @override
  void didUpdateWidget(covariant DeckEntryTypeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detail.id != widget.detail.id ||
        oldWidget.detail.wordType != widget.detail.wordType) {
      _syncFromDetail();
    }
  }

  void _syncFromDetail() {
    _wordType = widget.detail.wordType;
    _savedWordType = _wordType;
    _classByMeaning
      ..clear()
      ..addEntries(
        widget.detail.meanings
            .where((meaning) => (meaning.wordClassId ?? '').isNotEmpty)
            .map((meaning) => MapEntry(meaning.id, meaning.wordClassId!)),
      );
    _savedClass
      ..clear()
      ..addAll(_classByMeaning);
  }

  bool _isUmum(WordMeaning meaning) =>
      (meaning.wordClassCode ?? '').toLowerCase() == 'umum';

  List<DeckClassPick> _picks() {
    return [
      for (final meaning in widget.detail.meanings)
        DeckClassPick(
          meaningId: meaning.id,
          currentClassId: _savedClass[meaning.id] ?? meaning.wordClassId,
          nextClassId: _classByMeaning[meaning.id] ?? meaning.wordClassId,
          isUmum: _isUmum(meaning),
        ),
    ];
  }

  Future<void> _pickType() async {
    final picked = await showWordTypePickerSheet(context, selected: _wordType);
    if (!mounted || picked == null || picked == _wordType) return;
    final previous = _wordType;
    setState(() => _wordType = picked);
    final saved = await _save();
    if (!saved && mounted) setState(() => _wordType = previous);
  }

  Future<void> _pickClass(WordMeaning meaning) async {
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
    final current = _classByMeaning[meaning.id] ?? meaning.wordClassId;
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
    if (!mounted || picked == null || picked.id == current) return;
    final previous = _classByMeaning[meaning.id];
    setState(() => _classByMeaning[meaning.id] = picked.id);
    final saved = await _save();
    if (!saved && mounted) {
      setState(() {
        if (previous == null) {
          _classByMeaning.remove(meaning.id);
        } else {
          _classByMeaning[meaning.id] = previous;
        }
      });
    }
  }

  String _classLabel(List<ReferenceItem>? classes, WordMeaning meaning) {
    final id = _classByMeaning[meaning.id] ?? meaning.wordClassId;
    if (classes != null && id != null) {
      for (final item in classes) {
        if (item.id != id) continue;
        final alias = item.alias?.trim();
        if (alias != null && alias.isNotEmpty) return alias;
        return item.name;
      }
    }
    final name = meaning.wordClassName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return 'Umum';
  }

  Future<bool> _save() async {
    if (_busy) return false;
    final proposal = buildDeckTypeProposal(
      currentWordType: _savedWordType,
      nextWordType: _wordType,
      classes: _picks(),
    );
    if (proposal == null) return true;
    setState(() => _busy = true);
    var ok = false;
    final dio = ref.read(dioProvider);
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/words/${widget.detail.id}/suggest-edit',
        data: {
          'proposed_changes': proposal,
          'reason_code': 'other',
          'reason_text': 'Ubah jenis / kelas kata',
        },
      );
      if (!mounted) return true;
      final selfApplied = suggestEditWasSelfApplied(
        responseStatus: suggestEditStatusFromResponse(response.data),
        actorRole: ref.read(authStatusProvider).value?.role,
      );
      showFToast(
        context: context,
        title: Text(
          selfApplied ? 'Tersimpan' : 'Usulan terkirim',
        ),
      );
      AnalyticsService.instance.log(
        AnalyticsEvents.suggestEditSubmit,
        params: {
          'word_id': widget.detail.id,
          'category': 'other',
        },
      );
      _savedWordType = _wordType;
      _savedClass
        ..clear()
        ..addAll(_classByMeaning);
      ok = true;
      await invalidateWordDetailCaches(
        ref,
        widget.detail.id,
        widget.detail.lemma,
      );
    } on DioException catch (error) {
      if (!mounted) return false;
      final data = error.response?.data;
      final code = data is Map ? data['error_code']?.toString() : null;
      final message = apiErrorText(
        data,
        'Gagal mengirim usulan. Periksa koneksi lalu coba lagi.',
      );
      if (code == 'RATE_LIMITED') {
        showFToast(context: context, title: Text(message));
      } else {
        await showAppErrorSheet(context, message: message);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final classes = ref.watch(referenceWordClassesProvider).asData?.value;
    final classMeanings = widget.detail.meanings;

    return SwipeExemptRegion(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FTileGroup(
            children: [
              FTile(
                title: const Text('Jenis entri'),
                details: Text(deckWordTypeLabel(_wordType)),
                suffix: Icon(
                  FLucideIcons.chevronRight,
                  color: theme.colors.mutedForeground,
                ),
                onPress: _busy ? null : _pickType,
              ),
              for (final meaning in classMeanings)
                FTile(
                  title: const Text('Kelas kata'),
                  subtitle: _meaningHint(meaning, classMeanings.length),
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

Widget? _meaningHint(WordMeaning meaning, int count) {
  if (count < 2) return null;
  final text = meaning.definition?.trim();
  if (text == null || text.isEmpty || text == '-') return const Text('Makna');
  return Text(text);
}
