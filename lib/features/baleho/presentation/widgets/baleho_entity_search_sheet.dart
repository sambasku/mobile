import 'dart:async';

import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/compact_search_hit_tile.dart';
import '../../../event/event_router.dart';
import '../../../event/presentation/providers/event_providers.dart';
import '../../../explore/domain/entities/place.dart';
import '../../../explore/presentation/providers/places_providers.dart';
import '../../../karya/karya_router.dart';
import '../../../karya/presentation/karya_providers.dart';
import '../../../usaha/presentation/providers/usaha_providers.dart';
import '../../../usaha/usaha_router.dart';
import '../../domain/baleho_deeplink_pick.dart';

enum BalehoEntitySearchKind { usaha, acara, wisata, karya }

class _EntityHit {
  const _EntityHit({
    required this.title,
    required this.path,
    required this.entityType,
    required this.entityId,
    this.subtitle,
  });

  final String title;
  final String path;
  final String entityType;
  final String entityId;
  final String? subtitle;
}

/// Bottom sheet cari + pilih entity untuk deeplink Baleho yang tertarget.
Future<BalehoDeeplinkPick?> showBalehoEntitySearchSheet(
  BuildContext context, {
  required BalehoEntitySearchKind kind,
}) {
  final container = ProviderScope.containerOf(context);
  return showModalBottomSheet<BalehoDeeplinkPick>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    builder: (_) => UncontrolledProviderScope(
      container: container,
      child: _BalehoEntitySearchBody(kind: kind),
    ),
  );
}

class _BalehoEntitySearchBody extends ConsumerStatefulWidget {
  const _BalehoEntitySearchBody({required this.kind});

  final BalehoEntitySearchKind kind;

  @override
  ConsumerState<_BalehoEntitySearchBody> createState() =>
      _BalehoEntitySearchBodyState();
}

class _BalehoEntitySearchBodyState
    extends ConsumerState<_BalehoEntitySearchBody> {
  late final TextEditingController _queryCtrl;
  Timer? _debounce;
  var _seq = 0;
  var _loading = false;
  var _searched = false;
  var _failed = false;
  List<_EntityHit> _hits = const [];

  @override
  void initState() {
    super.initState();
    _queryCtrl = TextEditingController();
    _queryCtrl.addListener(_onQueryChanged);
    // Muat daftar awal tanpa query supaya user langsung lihat pilihan.
    WidgetsBinding.instance.addPostFrameCallback((_) => _search());
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
    if (available <= 0) return 0;
    final target = available * 0.78;
    final minH = available < 320 ? available : 300.0;
    return target.clamp(minH, available);
  }

  String _title(AppLocalizations l10n) => switch (widget.kind) {
        .usaha => l10n.balehoEntitySearchUsahaTitle,
        .acara => l10n.balehoEntitySearchAcaraTitle,
        .wisata => l10n.balehoEntitySearchWisataTitle,
        .karya => l10n.balehoEntitySearchKaryaTitle,
      };

  Future<void> _search() async {
    final q = _queryCtrl.text.trim();
    // Query 1 huruf saja: tunggu (hindari spam); kosong = browse awal.
    if (q.length == 1) return;

    final seq = ++_seq;
    setState(() {
      _loading = true;
      _failed = false;
    });

    try {
      final hits = await _fetchHits(q.isEmpty ? null : q);
      if (!mounted || seq != _seq) return;
      setState(() {
        _hits = hits;
        _searched = true;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || seq != _seq) return;
      setState(() {
        _hits = const [];
        _searched = true;
        _loading = false;
        _failed = true;
      });
    }
  }

  Future<List<_EntityHit>> _fetchHits(String? q) async {
    switch (widget.kind) {
      case .usaha:
        final page = await ref.read(usahaRepositoryProvider).listPage(
              limit: 24,
              q: q,
            );
        return [
          for (final u in page.items)
            _EntityHit(
              title: u.name,
              path: UsahaRouter.detailPath(u.slug),
              subtitle: '/usaha/${u.slug}',
              entityType: 'usaha',
              entityId: u.id,
            ),
        ];
      case .acara:
        final page = await ref.read(eventRepositoryProvider).listPage(
              limit: 24,
              q: q,
              notEnded: true,
            );
        return [
          for (final e in page.events)
            _EntityHit(
              title: e.name,
              path: EventRouter.detailPath(e.slug),
              subtitle: '/acara/${e.slug}',
              entityType: 'event',
              entityId: e.id,
            ),
        ];
      case .wisata:
        final page = await ref.read(placesRepositoryProvider).listPage(
              category: PlaceCategory.wisata.name,
              q: q,
              limit: 24,
            );
        return [
          for (final p in page.items)
            _EntityHit(
              title: p.name,
              path: '/explore/place/${Uri.encodeComponent(p.slug)}',
              subtitle: '/explore/place/${p.slug}',
              entityType: 'place',
              entityId: p.id,
            ),
        ];
      case .karya:
        final items = await ref.read(karyaApiProvider).list(q: q);
        return [
          for (final k in items.take(24))
            _EntityHit(
              title: k.title,
              path: KaryaRouter.detailPath(k.slug),
              subtitle: '/karya/${k.slug}',
              entityType: 'karya',
              entityId: k.id,
            ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SizedBox(
        height: _sheetHeight(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
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
                      _title(l10n),
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FTextField(
                control: FTextFieldControl.managed(controller: _queryCtrl),
                hint: l10n.balehoEntitySearchHint,
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
            const Gap(8),
            Expanded(
              child: !_searched && _loading
                  ? const Center(child: FCircularProgress())
                  : _failed
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              l10n.balehoEntitySearchFailed,
                              textAlign: TextAlign.center,
                              style: theme.typography.body.sm.copyWith(
                                color: theme.colors.mutedForeground,
                              ),
                            ),
                          ),
                        )
                      : _hits.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Text(
                                  _searched
                                      ? l10n.balehoEntitySearchEmpty
                                      : l10n.balehoEntitySearchPrompt,
                                  textAlign: TextAlign.center,
                                  style: theme.typography.body.sm.copyWith(
                                    color: theme.colors.mutedForeground,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _hits.length,
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              itemBuilder: (context, index) {
                                final hit = _hits[index];
                                return CompactSearchHitTile(
                                  title: hit.title,
                                  subtitle: hit.subtitle,
                                  titleBold: true,
                                  onTap: () => Navigator.of(context).pop(
                                    BalehoDeeplinkPick(
                                      path: hit.path,
                                      entityType: hit.entityType,
                                      entityId: hit.entityId,
                                    ),
                                  ),
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
