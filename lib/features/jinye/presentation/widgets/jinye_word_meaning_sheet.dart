import 'package:dio/dio.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../dictionary/domain/entities/word_detail.dart';
import '../../../dictionary/domain/providers/dictionary_domain_providers.dart';
import '../../../dictionary/domain/usecases/search_words_use_case.dart';
import '../../data/jinye_providers.dart';
import '../../domain/jinye_models.dart';
import 'jinye_link_lemma_sheet.dart';
import 'jinye_word_picker_sheet.dart';

/// Strip tanda baca di ujung token untuk lookup lemma.
String jinyeLookupToken(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return t;
  return t.replaceAll(
    RegExp(r'^[^\p{L}\p{N}]+|[^\p{L}\p{N}]+$', unicode: true),
    '',
  );
}

/// Hasil sheet makna: `login` = arahkan login; selain itu = wordId buka lemma.
Future<String?> showJinyeWordMeaningSheet(
  BuildContext context, {
  required String jinyeId,
  required JinyeSpanSelection span,
  JinyeLemmaLink? link,
  required bool isAuth,
  VoidCallback? onLinked,
}) {
  return showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _JinyeWordMeaningSheet(
      jinyeId: jinyeId,
      span: span,
      link: link,
      isAuth: isAuth,
      onLinked: onLinked,
    ),
  );
}

class _JinyeWordMeaningSheet extends ConsumerStatefulWidget {
  const _JinyeWordMeaningSheet({
    required this.jinyeId,
    required this.span,
    required this.link,
    required this.isAuth,
    this.onLinked,
  });

  final String jinyeId;
  final JinyeSpanSelection span;
  final JinyeLemmaLink? link;
  final bool isAuth;
  final VoidCallback? onLinked;

  @override
  ConsumerState<_JinyeWordMeaningSheet> createState() =>
      _JinyeWordMeaningSheetState();
}

class _JinyeWordMeaningSheetState
    extends ConsumerState<_JinyeWordMeaningSheet> {
  bool _loading = true;
  String? _error;
  WordDetail? _word;
  bool _linking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _word = null;
    });

    final link = widget.link;
    if (link != null) {
      final result = await ref.read(getWordByIdUseCaseProvider)(link.wordId);
      if (!mounted) return;
      result.match(
        (f) => setState(() {
          _loading = false;
          _error = f.message;
        }),
        (w) => setState(() {
          _loading = false;
          _word = w;
        }),
      );
      return;
    }

    final q = jinyeLookupToken(widget.span.text);
    if (q.isEmpty) {
      setState(() {
        _loading = false;
        _word = null;
      });
      return;
    }

    final byLemma = await ref.read(getWordByLemmaUseCaseProvider)(q);
    if (!mounted) return;
    final hit = byLemma.fold<WordDetail?>((_) => null, (w) => w);
    if (hit != null) {
      setState(() {
        _loading = false;
        _word = hit;
      });
      return;
    }

    // Hanya exact lemma. Fuzzy hit disembunyikan - kalau belum ada, user
    // boleh usul kata baru (bukan arti lemma mirip).
    final search = await ref.read(searchWordsUseCaseProvider)(
      SearchWordsParams(query: q, limit: 10, searchIn: 'lemma'),
    );
    if (!mounted) return;
    final page = search.fold((_) => null, (p) => p);
    final exact = page?.items
        .where((i) => i.lemma.toLowerCase() == q.toLowerCase())
        .toList();
    if (exact == null || exact.isEmpty) {
      setState(() {
        _loading = false;
        _word = null;
      });
      return;
    }

    final detail = await ref.read(getWordByIdUseCaseProvider)(exact.first.id);
    if (!mounted) return;
    detail.match(
      (f) => setState(() {
        _loading = false;
        _error = f.message;
      }),
      (w) => setState(() {
        _loading = false;
        _word = w;
      }),
    );
  }

  void _onProposeNewLemma() {
    final l10n = AppLocalizations.of(context);
    if (!widget.isAuth) {
      showFToast(context: context, title: Text(l10n.jinyeWordMeaningLoginFirst));
      Navigator.of(context).pop('login');
      return;
    }
    final q = jinyeLookupToken(widget.span.text);
    if (q.isEmpty) return;
    Navigator.of(context).pop('contribute:${Uri.encodeComponent(q)}');
  }

  Future<void> _onHubungkan() async {
    final l10n = AppLocalizations.of(context);
    if (!widget.isAuth) {
      showFToast(context: context, title: Text(l10n.jinyeWordMeaningLoginFirst));
      Navigator.of(context).pop('login');
      return;
    }
    if (_linking) return;

    final word = await showJinyeWordPickerSheet(
      context,
      initialQuery: jinyeLookupToken(widget.span.text),
    );
    if (word == null || !mounted) return;

    setState(() => _linking = true);
    try {
      await ref.read(jinyeRepositoryProvider).createLemmaLink(
            jinyeId: widget.jinyeId,
            start: widget.span.start,
            end: widget.span.end,
            wordId: word.id,
          );
      if (!mounted) return;
      widget.onLinked?.call();
      showFToast(context: context, title: Text(l10n.jinyeLemmaLinkSuccess));
      Navigator.of(context).pop();
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _linking = false);
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message']
          : null;
      await showAppErrorSheet(
        context,
        message: msg is String && msg.isNotEmpty
            ? msg
            : l10n.jinyeLemmaLinkFailed,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _linking = false);
      await showAppErrorSheet(context, message: l10n.jinyeLemmaLinkFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final linked = widget.link != null;
    final displayLemma =
        _word?.lemma ?? widget.link?.lemma ?? widget.span.text;
    final maxH = MediaQuery.sizeOf(context).height * 0.55;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                displayLemma,
                style: theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.jinyeWordMeaningLookupLabel,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
            const Gap(12),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxH),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildBody(l10n),
              ),
            ),
            const Gap(8),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (linked)
                    FButton(
                      onPress: () =>
                          Navigator.of(context).pop(widget.link!.wordId),
                      child: Text(l10n.jinyeWordMeaningOpenLemma),
                    )
                  else if (!_loading && _error == null && _word == null) ...[
                    // Lemma belum di kamus → usul kata baru (prefill token).
                    FButton(
                      onPress: _onProposeNewLemma,
                      child: Text(l10n.dictProposeThisWord),
                    ),
                    const Gap(8),
                    FButton(
                      variant: FButtonVariant.outline,
                      onPress: _linking ? null : _onHubungkan,
                      prefix: _linking ? const FCircularProgress() : null,
                      child: Text(l10n.jinyeWordMeaningLinkAction),
                    ),
                  ] else
                    FButton(
                      onPress: _linking ? null : _onHubungkan,
                      prefix: _linking ? const FCircularProgress() : null,
                      child: Text(l10n.jinyeWordMeaningLinkAction),
                    ),
                  const Gap(8),
                  FButton(
                    variant: FButtonVariant.outline,
                    onPress: () => Navigator.of(context).pop(),
                    child: Text(l10n.commonCancel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    final theme = context.theme;
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: FCircularProgress()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          l10n.jinyeWordMeaningLoadFailed,
          style: theme.typography.body.md.copyWith(
            color: theme.colors.destructive,
          ),
        ),
      );
    }
    final word = _word;
    if (word == null || word.meanings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          l10n.jinyeWordMeaningEmpty,
          style: theme.typography.body.md.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < word.meanings.length; i++) ...[
          if (i > 0) const Gap(12),
          _MeaningBlock(
            index: i + 1,
            showIndex: word.meanings.length > 1,
            meaning: word.meanings[i],
          ),
        ],
      ],
    );
  }
}

class _MeaningBlock extends StatelessWidget {
  const _MeaningBlock({
    required this.index,
    required this.showIndex,
    required this.meaning,
  });

  final int index;
  final bool showIndex;
  final WordMeaning meaning;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final definition = meaning.definition?.trim();
    final classLabel =
        meaning.wordClassBracket ??
        (meaning.wordClassName != null && meaning.wordClassName!.isNotEmpty
            ? meaning.wordClassName
            : null);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showIndex)
          SizedBox(
            width: 22,
            child: Text(
              '$index.',
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (classLabel != null) ...[
                Text(
                  classLabel,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(4),
              ],
              if (definition != null && definition.isNotEmpty)
                Text(
                  definition,
                  style: theme.typography.body.md.copyWith(height: 1.5),
                ),
              if (meaning.translations.isNotEmpty) ...[
                const Gap(6),
                ...meaning.translations.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '→ ${t.text}',
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
