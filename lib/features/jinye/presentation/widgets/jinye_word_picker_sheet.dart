import 'dart:async';

import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/compact_search_hit_tile.dart';
import '../../../dictionary/domain/entities/word_summary.dart';
import '../../../dictionary/domain/providers/dictionary_domain_providers.dart';
import '../../../dictionary/domain/usecases/search_words_use_case.dart';

/// Bottom sheet cari lemma terverifikasi. Kembali [WordSummary] via Navigator.pop.
/// Chrome + densitas baris = pola [showKbbiDefinitionSheet].
Future<WordSummary?> showJinyeWordPickerSheet(
  BuildContext context, {
  String initialQuery = '',
}) {
  return showModalBottomSheet<WordSummary>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _JinyeWordPickerSheet(initialQuery: initialQuery),
  );
}

class _JinyeWordPickerSheet extends ConsumerStatefulWidget {
  const _JinyeWordPickerSheet({required this.initialQuery});

  final String initialQuery;

  @override
  ConsumerState<_JinyeWordPickerSheet> createState() =>
      _JinyeWordPickerSheetState();
}

class _JinyeWordPickerSheetState extends ConsumerState<_JinyeWordPickerSheet> {
  late final TextEditingController _ctrl;
  Timer? _debounce;
  List<WordSummary> _items = const [];
  bool _loading = false;
  bool _searched = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _search());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(TextEditingValue _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _search);
  }

  double _sheetHeight(BuildContext context) {
    final media = MediaQuery.of(context);
    final available = media.size.height - media.viewInsets.bottom;
    final target = available * 0.75;
    return target.clamp(280.0, available);
  }

  Future<void> _search() async {
    final q = _ctrl.text.trim();
    if (q.isEmpty) {
      setState(() {
        _items = const [];
        _error = null;
        _loading = false;
        _searched = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _searched = true;
    });
    final result = await ref.read(searchWordsUseCaseProvider)(
      SearchWordsParams(query: q, limit: 20, searchIn: 'lemma'),
    );
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _loading = false;
        _error = f.message;
        _items = const [];
      }),
      (page) => setState(() {
        _loading = false;
        // Hanya kata tayang + terverifikasi (syarat API lemma link).
        _items = page.items
            .where((w) => w.isVerified && w.status == 'published')
            .toList();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final inset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: SizedBox(
        height: _sheetHeight(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  Icon(
                    FLucideIcons.search,
                    size: 18,
                    color: theme.colors.primary,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      l10n.jinyeLemmaPickWordTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.lg.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(FLucideIcons.x),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                l10n.jinyeLemmaPickWordIntro,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FTextField(
                control: FTextFieldControl.managed(
                  controller: _ctrl,
                  onChange: _onChanged,
                ),
                hint: l10n.jinyeLemmaPickWordHint,
                textInputAction: TextInputAction.search,
                onSubmit: (_) {
                  _debounce?.cancel();
                  _search();
                },
                suffixBuilder: _loading
                    ? (context, style, _) => Padding(
                          padding: style.clearButtonPadding,
                          child: const FCircularProgress(size: .sm),
                        )
                    : null,
              ),
            ),
            if (_error != null) ...[
              const Gap(8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FAlert(
                  variant: FAlertVariant.destructive,
                  title: Text(
                    _error!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            if (_searched && !_loading && _items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Text(
                  l10n.jinyeLemmaPickWordCount(_items.length),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                    fontSize: 12,
                  ),
                ),
              ),
            const Gap(8),
            Expanded(
              child: !_searched
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          l10n.jinyeLemmaPickWordEmptyHint,
                          textAlign: TextAlign.center,
                          style: theme.typography.body.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                    )
                  : _items.isEmpty && !_loading
                      ? (_error != null
                          ? const SizedBox.shrink()
                          : Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  l10n.jinyeLemmaPickWordNoResult,
                                  textAlign: TextAlign.center,
                                  style: theme.typography.body.sm.copyWith(
                                    color: theme.colors.mutedForeground,
                                  ),
                                ),
                              ),
                            ))
                      : ListView.builder(
                          itemCount: _items.length,
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemBuilder: (context, i) {
                            final w = _items[i];
                            final gloss = w.matchedTranslation?.trim();
                            return CompactSearchHitTile(
                              title: w.lemma,
                              subtitle: (gloss != null && gloss.isNotEmpty)
                                  ? gloss
                                  : null,
                              titleBold: true,
                              onTap: () => Navigator.pop(context, w),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
