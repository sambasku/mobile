import 'dart:async';

import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/network/network_providers.dart';
import '../../l10n/app_localizations.dart';
import '../models/content_related_link.dart';
import '../utils/content_related_nav.dart';
import 'option_picker_sheet.dart';

const _kContentRelatedMax = 12;

/// Pilih satu tautan terkait (kind lalu cari). Null = batal / penuh.
Future<ContentRelatedLink?> showContentRelatedPickerSheet(
  BuildContext context, {
  required List<ContentRelatedLink> selected,
}) async {
  final l10n = AppLocalizations.of(context);
  if (selected.length >= _kContentRelatedMax) {
    return null;
  }
  final kind = await showOptionPickerSheet<String>(
    context,
    title: l10n.contentRelatedPickKindTitle,
    subtitle: l10n.contentRelatedPickKindSubtitle,
    items: [
      OptionPickerItem(
        value: 'word',
        label: l10n.karyaRelatedKindWord,
      ),
      OptionPickerItem(
        value: 'article',
        label: l10n.karyaRelatedKindArticle,
      ),
      OptionPickerItem(
        value: 'place',
        label: l10n.karyaRelatedKindPlace,
      ),
      OptionPickerItem(
        value: 'event',
        label: l10n.karyaRelatedKindEvent,
      ),
      OptionPickerItem(
        value: 'usaha',
        label: l10n.karyaRelatedKindUsaha,
      ),
      OptionPickerItem(
        value: 'karya',
        label: l10n.karyaRelatedKindKarya,
      ),
    ],
  );
  if (kind == null || !context.mounted) return null;

  final excludeIds = {for (final s in selected) s.id};
  final container = ProviderScope.containerOf(context);
  return showModalBottomSheet<ContentRelatedLink>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    builder: (_) => UncontrolledProviderScope(
      container: container,
      child: _ContentRelatedSearchBody(
        kind: kind,
        excludeIds: excludeIds,
      ),
    ),
  );
}

class _ContentRelatedSearchBody extends ConsumerStatefulWidget {
  const _ContentRelatedSearchBody({
    required this.kind,
    required this.excludeIds,
  });

  final String kind;
  final Set<String> excludeIds;

  @override
  ConsumerState<_ContentRelatedSearchBody> createState() =>
      _ContentRelatedSearchBodyState();
}

class _ContentRelatedSearchBodyState
    extends ConsumerState<_ContentRelatedSearchBody> {
  final _queryCtrl = TextEditingController();
  Timer? _debounce;
  var _seq = 0;
  var _loading = false;
  var _searched = false;
  List<ContentRelatedLink> _hits = const [];

  @override
  void initState() {
    super.initState();
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
    _debounce = Timer(const Duration(milliseconds: 320), _search);
  }

  Future<void> _search() async {
    final q = _queryCtrl.text.trim();
    if (q.length < 2) {
      setState(() {
        _hits = const [];
        _searched = false;
        _loading = false;
      });
      return;
    }
    final seq = ++_seq;
    setState(() {
      _loading = true;
      _searched = true;
    });
    try {
      final hits = await _fetchHits(q);
      if (!mounted || seq != _seq) return;
      setState(() {
        _hits = hits;
        _loading = false;
      });
    } on Object {
      if (mounted && seq == _seq) {
        setState(() {
          _hits = const [];
          _loading = false;
        });
      }
    }
  }

  Future<List<ContentRelatedLink>> _fetchHits(String q) async {
    final dio = ref.read(dioProvider);
    final exclude = widget.excludeIds;
    switch (widget.kind) {
      case 'word':
        final res = await dio.get<Map<String, dynamic>>(
          '/api/v1/words/search',
          queryParameters: {'q': q, 'limit': 12},
        );
        final data = res.data?['data'];
        final out = <ContentRelatedLink>[];
        for (final item in data is List ? data : const []) {
          if (item is! Map) continue;
          final id = item['id']?.toString() ?? '';
          final lemma = item['lemma']?.toString().trim() ?? '';
          if (id.isEmpty || lemma.isEmpty || exclude.contains(id)) continue;
          out.add(ContentRelatedLink(kind: 'word', id: id, title: lemma));
        }
        return out;
      case 'article':
        final res = await dio.get<Map<String, dynamic>>(
          '/api/v1/encyclopedia/articles/search',
          queryParameters: {'q': q, 'limit': 12},
        );
        return _mapListHits(res.data?['data'], kind: 'article', exclude: exclude);
      case 'place':
        final res = await dio.get<Map<String, dynamic>>(
          '/api/v1/places',
          queryParameters: {'q': q, 'limit': 12},
        );
        return _mapListHits(res.data?['data'], kind: 'place', exclude: exclude);
      case 'event':
        final res = await dio.get<Map<String, dynamic>>(
          '/api/v1/events',
          queryParameters: {'q': q, 'limit': 12},
        );
        return _mapListHits(res.data?['data'], kind: 'event', exclude: exclude);
      case 'usaha':
        final res = await dio.get<Map<String, dynamic>>(
          '/api/v1/usahas',
          queryParameters: {'q': q, 'limit': 12},
        );
        return _mapListHits(res.data?['data'], kind: 'usaha', exclude: exclude);
      case 'karya':
        final res = await dio.get<Map<String, dynamic>>(
          '/api/v1/karyas',
          queryParameters: {'q': q, 'limit': 12},
        );
        return _mapListHits(res.data?['data'], kind: 'karya', exclude: exclude);
      default:
        return const [];
    }
  }

  List<ContentRelatedLink> _mapListHits(
    Object? data, {
    required String kind,
    required Set<String> exclude,
  }) {
    final list = data is Map ? data['items'] : data;
    final out = <ContentRelatedLink>[];
    for (final item in list is List ? list : const []) {
      if (item is! Map) continue;
      final id = item['id']?.toString() ?? '';
      final title = (item['title'] ?? item['name'] ?? item['lemma'])
              ?.toString()
              .trim() ??
          '';
      final slug = item['slug']?.toString().trim();
      if (id.isEmpty || title.isEmpty || exclude.contains(id)) continue;
      out.add(
        ContentRelatedLink(
          kind: kind,
          id: id,
          title: title,
          slug: (slug == null || slug.isEmpty) ? null : slug,
          coverUrl: item['cover_url']?.toString(),
        ),
      );
    }
    return out;
  }

  double _sheetHeight(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return (h * 0.72).clamp(320.0, 640.0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
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
                      l10n.contentRelatedSearchTitle(
                        contentRelatedKindLabel(l10n, widget.kind),
                      ),
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: FTextField(
                control: FTextFieldControl.managed(controller: _queryCtrl),
                hint: l10n.contentRelatedSearchHint,
                textInputAction: TextInputAction.search,
                onSubmit: (_) {
                  _debounce?.cancel();
                  _search();
                },
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: FCircularProgress(size: .sm)),
              )
            else if (_searched && _hits.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.contentRelatedSearchEmpty,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _hits.length,
                  itemBuilder: (context, i) {
                    final hit = _hits[i];
                    return FTile(
                      title: Text(hit.title),
                      subtitle: hit.slug == null ? null : Text(hit.slug!),
                      onPress: () => Navigator.of(context).pop(hit),
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
