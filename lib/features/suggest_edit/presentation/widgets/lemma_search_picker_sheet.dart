import 'dart:async';

import 'package:dio/dio.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../l10n/app_localizations.dart';

/// Satu hasil cari lemma di kamus (untuk chip / list sheet).
class LemmaSearchHit {
  const LemmaSearchHit({
    required this.id,
    required this.lemma,
    this.sense,
  });

  final String id;
  final String lemma;
  final String? sense;
}

/// Bottom sheet cari + pilih lemma yang sudah ada (#265).
///
/// Return lemma terpilih, atau teks query bila user pilih "pakai sebagai
/// lemma baru". Null = batal.
Future<String?> showLemmaSearchPickerSheet(
  BuildContext context, {
  Set<String> excludeLemmas = const {},
  String? title,
}) {
  final container = ProviderScope.containerOf(context);
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    builder: (_) => UncontrolledProviderScope(
      // Sheet di root navigator keluar subtree Consumer - warisi container.
      container: container,
      child: _LemmaSearchPickerSheetBody(
        excludeLemmas: {
          for (final e in excludeLemmas)
            if (e.trim().isNotEmpty) e.trim().toLowerCase(),
        },
        title: title,
      ),
    ),
  );
}

class _LemmaSearchPickerSheetBody extends ConsumerStatefulWidget {
  const _LemmaSearchPickerSheetBody({
    required this.excludeLemmas,
    this.title,
  });

  final Set<String> excludeLemmas;
  final String? title;

  @override
  ConsumerState<_LemmaSearchPickerSheetBody> createState() =>
      _LemmaSearchPickerSheetBodyState();
}

class _LemmaSearchPickerSheetBodyState
    extends ConsumerState<_LemmaSearchPickerSheetBody> {
  late final TextEditingController _queryCtrl;
  Timer? _debounce;
  int _seq = 0;
  bool _loading = false;
  bool _searched = false;
  List<LemmaSearchHit> _hits = const [];

  @override
  void initState() {
    super.initState();
    _queryCtrl = TextEditingController();
    _queryCtrl.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryCtrl.removeListener(_onQueryChanged);
    _queryCtrl.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _search);
  }

  double _sheetHeight(BuildContext context) {
    final media = MediaQuery.of(context);
    final available = media.size.height - media.viewInsets.bottom;
    final target = available * 0.7;
    return target.clamp(320.0, available);
  }

  Future<void> _search() async {
    final q = _queryCtrl.text.trim();
    if (q.length < 2) {
      if (mounted) {
        setState(() {
          _hits = const [];
          _searched = false;
          _loading = false;
        });
      }
      return;
    }
    final seq = ++_seq;
    setState(() => _loading = true);
    try {
      final res = await ref.read(dioProvider).get<Map<String, dynamic>>(
            '/api/v1/words/search',
            queryParameters: {'q': q, 'limit': 12},
          );
      if (!mounted || seq != _seq) return;
      final data = res.data?['data'];
      final hits = <LemmaSearchHit>[];
      final seen = <String>{};
      for (final item in data is List ? data : const []) {
        if (item is! Map) continue;
        final lemma = item['lemma']?.toString().trim() ?? '';
        if (lemma.isEmpty) continue;
        final key = lemma.toLowerCase();
        if (widget.excludeLemmas.contains(key) || !seen.add(key)) continue;
        hits.add(
          LemmaSearchHit(
            id: item['id']?.toString() ?? lemma,
            lemma: lemma,
            sense: item['sense']?.toString() ??
                item['definition']?.toString() ??
                item['matched_translation']?.toString(),
          ),
        );
      }
      setState(() {
        _hits = hits;
        _searched = true;
        _loading = false;
      });
    } on DioException {
      if (mounted && seq == _seq) {
        setState(() {
          _hits = const [];
          _searched = true;
          _loading = false;
        });
      }
    } on Object {
      if (mounted && seq == _seq) {
        setState(() {
          _hits = const [];
          _searched = true;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final q = _queryCtrl.text.trim();
    final exactHit = _hits.any((h) => h.lemma.toLowerCase() == q.toLowerCase());
    final canUseNew = q.length >= 2 &&
        !widget.excludeLemmas.contains(q.toLowerCase()) &&
        !exactHit;

    return SizedBox(
      height: _sheetHeight(context),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
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
                      widget.title ?? l10n.lemmaSearchSheetTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.lg.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                l10n.lemmaSearchSheetIntro,
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
                control: FTextFieldControl.managed(controller: _queryCtrl),
                hint: l10n.lemmaSearchSheetHint,
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
            if (_searched && !_loading && _hits.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Text(
                  l10n.lemmaSearchSheetCount(_hits.length),
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
              child: _loading
                  ? const Center(child: FCircularProgress())
                  : !_searched
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              l10n.lemmaSearchSheetPrompt,
                              textAlign: TextAlign.center,
                              style: theme.typography.body.sm.copyWith(
                                color: theme.colors.mutedForeground,
                              ),
                            ),
                          ),
                        )
                      : _hits.isEmpty && !canUseNew
                          ? Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  l10n.lemmaSearchSheetEmpty,
                                  textAlign: TextAlign.center,
                                  style: theme.typography.body.sm.copyWith(
                                    color: theme.colors.mutedForeground,
                                  ),
                                ),
                              ),
                            )
                          : ListView(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              children: [
                                for (final hit in _hits)
                                  _LemmaHitTile(
                                    hit: hit,
                                    onTap: () =>
                                        Navigator.of(context).pop(hit.lemma),
                                  ),
                                if (canUseNew)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      8,
                                      8,
                                      8,
                                      0,
                                    ),
                                    child: FButton(
                                      variant: FButtonVariant.outline,
                                      onPress: () =>
                                          Navigator.of(context).pop(q),
                                      child: Text(
                                        l10n.lemmaSearchSheetUseNew(q),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LemmaHitTile extends StatelessWidget {
  const _LemmaHitTile({required this.hit, required this.onTap});

  final LemmaSearchHit hit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final sense = hit.sense?.trim();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hit.lemma,
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (sense != null && sense.isNotEmpty) ...[
                const Gap(2),
                Text(
                  sense,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
