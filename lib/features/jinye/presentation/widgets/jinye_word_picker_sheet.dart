import 'dart:async';

import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../dictionary/domain/entities/word_summary.dart';
import '../../../dictionary/domain/providers/dictionary_domain_providers.dart';
import '../../../dictionary/domain/usecases/search_words_use_case.dart';

/// Bottom sheet cari lemma terverifikasi. Kembali [WordSummary] via Navigator.pop.
Future<WordSummary?> showJinyeWordPickerSheet(
  BuildContext context, {
  String initialQuery = '',
}) {
  return showModalBottomSheet<WordSummary>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
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

  Future<void> _search() async {
    final q = _ctrl.text.trim();
    if (q.isEmpty) {
      setState(() {
        _items = const [];
        _error = null;
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
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
    final bottom = MediaQuery.paddingOf(context).bottom;
    final inset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.jinyeLemmaPickWordTitle,
                style: theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w600,
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
                onSubmit: (_) => _search(),
                prefixBuilder: (context, style, variants) =>
                    FTextField.prefixIconBuilder(
                      context,
                      style,
                      variants,
                      const Icon(FLucideIcons.search),
                    ),
              ),
            ),
            const Gap(8),
            Expanded(
              child: _loading
                  ? const Center(child: FCircularProgress())
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: theme.typography.body.sm,
                            ),
                          ),
                        )
                      : _items.isEmpty
                          ? Center(
                              child: Text(
                                _ctrl.text.trim().isEmpty
                                    ? l10n.jinyeLemmaPickWordEmptyHint
                                    : l10n.jinyeLemmaPickWordNoResult,
                                style: theme.typography.body.sm.copyWith(
                                  color: theme.colors.mutedForeground,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, bottom + 8),
                              itemCount: _items.length,
                              itemBuilder: (context, i) {
                                final w = _items[i];
                                return FTile(
                                  title: Text(w.lemma),
                                  subtitle: w.matchedTranslation != null
                                      ? Text(w.matchedTranslation!)
                                      : null,
                                  onPress: () => Navigator.pop(context, w),
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
