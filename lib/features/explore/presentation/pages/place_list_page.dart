import 'package:material_ui/material_ui.dart';
import 'dart:async';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/display_image_url.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/exclude_semantics_on_exit.dart';
import '../../domain/entities/place.dart';
import '../../explore_router.dart';
import '../place_ui.dart';
import '../utils/explore_back.dart';
import '../providers/places_browse_providers.dart';

/// Filter list satu baris. Publik karena dipakai juga dari
/// ExploreCategoryPage (kartu Wisata / Kuliner di tab Eksplorasi).
enum PlaceListFilter { semua, alam, budaya, pantai, sejarah, belanja, kuliner }

const _filterLabels = {
  PlaceListFilter.semua: 'Semua',
  PlaceListFilter.alam: 'Alam',
  PlaceListFilter.budaya: 'Budaya',
  PlaceListFilter.pantai: 'Pantai',
  PlaceListFilter.sejarah: 'Sejarah',
  PlaceListFilter.belanja: 'Belanja',
  PlaceListFilter.kuliner: 'Kuliner',
};

/// Mode halaman daftar Place. Wisata dan Kuliner punya halaman sendiri,
/// tapi sumber datanya tetap satu `places.json` (dibedakan `category`).
enum PlacePageMode { wisata, kuliner }

const _pageTitle = {
  PlacePageMode.wisata: 'Wisata',
  PlacePageMode.kuliner: 'Kuliner',
};

/// 3 kolom: foto kotak 1:1, nama selalu 2 baris. Tipe tidak ditampilkan.
const _placeGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 3,
  mainAxisSpacing: 12,
  crossAxisSpacing: 8,
  childAspectRatio: 0.7,
);

/// Daftar Place berhalaman (`before` / `next_cursor`).
/// Mode wisata = grid 3 kolom. Mode kuliner tetap list satu kolom.
class PlaceListPage extends ConsumerStatefulWidget {
  const PlaceListPage({super.key, required this.mode});

  final PlacePageMode mode;

  @override
  ConsumerState<PlaceListPage> createState() => _PlaceListPageState();
}

class _PlaceListPageState extends ConsumerState<PlaceListPage> {
  late PlaceListFilter _filter;
  late PlacePageMode _mode;
  final _scroll = ScrollController();
  bool _autoloadBusy = false;
  int? _fillToken;

  @override
  void initState() {
    super.initState();
    _mode = widget.mode;
    _filter = _mode == PlacePageMode.kuliner
        ? PlaceListFilter.kuliner
        : PlaceListFilter.semua;
    _scroll.addListener(_maybeLoadMore);
  }

  String _query = '';
  Timer? _debounce;

  PlacesBrowseQuery get _browseQuery {
    final q = _query.trim();
    if (_mode == PlacePageMode.kuliner || _filter == PlaceListFilter.kuliner) {
      return PlacesBrowseQuery(category: PlaceCategory.kuliner, q: q);
    }
    final type = _filter == PlaceListFilter.semua
        ? null
        : PlaceType.values.byName(_filter.name);
    return PlacesBrowseQuery(category: PlaceCategory.wisata, type: type, q: q);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _scheduleFillCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _maybeLoadMore();
    });
  }

  Future<void> _maybeLoadMore() async {
    if (_autoloadBusy || !_scroll.hasClients) return;
    final data = ref.read(placesBrowseProvider(_browseQuery)).value;
    if (data == null ||
        !data.hasMore ||
        data.isLoadingMore ||
        data.loadMoreFailed) {
      return;
    }
    if (_scroll.position.maxScrollExtent - _scroll.position.pixels >= 200) {
      return;
    }
    final before = data.items.length;
    _autoloadBusy = true;
    try {
      await ref.read(placesBrowseProvider(_browseQuery).notifier).loadMore();
    } finally {
      _autoloadBusy = false;
      final after = ref.read(placesBrowseProvider(_browseQuery)).value;
      if (mounted && after != null && after.items.length != before) {
        _scheduleFillCheck();
      }
    }
  }

  void _onSearchChanged(TextEditingValue value) {
    final text = value.text;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = text);
    });
  }

  Future<void> _reload({bool keepItems = false}) async {
    setState(() => _refreshing = true);
    try {
      await ref
          .read(placesBrowseProvider(_browseQuery).notifier)
          .reload(keepItems: keepItems);
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  bool _refreshing = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final browseQuery = _browseQuery;
    final placesAsync = ref.watch(placesBrowseProvider(browseQuery));

    return ExcludeSemanticsOnExit(
      // Back sistem: jangan tutup app saat halaman dibuka dari deep link
      // (tanpa stack) - kembali ke tab Eksplorasi.
      child: PopScope(
        canPop: exploreCanPop(context),
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) popOrGoExplore(context);
        },
        child: FScaffold(
        childPad: true,
        header: FHeader.nested(
          title: Text(_pageTitle[_mode] ?? 'Eksplorasi'),
          prefixes: [
            FHeaderAction.back(onPress: () => popOrGoExplore(context)),
          ],
          suffixes: _mode == PlacePageMode.wisata
              ? [
                  FHeaderAction(
                    icon: const Icon(FLucideIcons.history),
                    onPress: () =>
                        context.push(ExploreRouter.placeProposals.path),
                  ),
                  FHeaderAction(
                    icon: const Icon(FLucideIcons.plus),
                    onPress: () =>
                        context.push(ExploreRouter.placeContribute.path),
                  ),
                ]
              : const [],
        ),
        child: placesAsync.when(
          // Skeleton tetap DI BAWAH search + filter: query berubah = state
          // loading baru, kalau seluruh body diganti skeleton, search bar
          // ikut hilang/timpa - UX buruk saat ngetik.
          loading: () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SearchField(onChanged: _onSearchChanged),
              const Gap(12),
              if (_mode == PlacePageMode.wisata) ...[
                _PlaceFilterBar(
                  selected: _filter,
                  onSelect: (f) => setState(() => _filter = f),
                ),
                // Jarak chips -> grid: 4 terlalu mepet (chip punya tinggi
                // sendiri, grid langsung menempel di bawahnya).
                const Gap(12),
              ],
              Expanded(
                child: _SkeletonList(
                  refreshing: _refreshing,
                  grid: _mode == PlacePageMode.wisata,
                ),
              ),
            ],
          ),
          error: (_, _) => _ErrorBody(onRetry: () => _reload()),
          data: (page) {
            if (page.items.isEmpty &&
                _query.trim().isEmpty &&
                (_mode == PlacePageMode.kuliner ||
                    _filter == PlaceListFilter.semua)) {
              return _EmptyWithSearch(
                search: _SearchField(onChanged: _onSearchChanged),
                filterBar: _mode == PlacePageMode.wisata
                    ? _PlaceFilterBar(
                        selected: _filter,
                        onSelect: (f) => setState(() => _filter = f),
                      )
                    : null,
              );
            }
            final fillToken = Object.hash(
              browseQuery,
              page.items.length,
              page.hasMore,
            );
            if (page.hasMore && fillToken != _fillToken) {
              _fillToken = fillToken;
              _scheduleFillCheck();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SearchField(onChanged: _onSearchChanged),
                const Gap(12),
                if (_mode == PlacePageMode.wisata) ...[
                  _PlaceFilterBar(
                    selected: _filter,
                    onSelect: (f) {
                      setState(() => _filter = f);
                      if (_scroll.hasClients) _scroll.jumpTo(0);
                    },
                  ),
                  const Gap(12),
                ],
                if (page.items.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'Belum ada destinasi yang cocok.',
                        textAlign: TextAlign.center,
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => _reload(keepItems: true),
                      child: CustomScrollView(
                        controller: _scroll,
                        physics: const AlwaysScrollableScrollPhysics(),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        slivers: [
                          if (_mode == PlacePageMode.wisata)
                            SliverGrid(
                              gridDelegate: _placeGridDelegate,
                              delegate: SliverChildBuilderDelegate(
                                (context, i) =>
                                    _PlaceGridTile(place: page.items[i]),
                                childCount: page.items.length,
                              ),
                            )
                          else
                            SliverList.separated(
                              itemCount: page.items.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, i) =>
                                  _PlaceCard(place: page.items[i]),
                            ),
                          if (page.isLoadingMore)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: FCircularProgress()),
                              ),
                            ),
                          if (page.loadMoreFailed)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: FButton(
                                  onPress: () => ref
                                      .read(
                                        placesBrowseProvider(
                                          browseQuery,
                                        ).notifier,
                                      )
                                      .loadMore(),
                                  child: const Text('Coba lagi'),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        ),
      ),
    );
  }
}

class _PlaceFilterBar extends StatelessWidget {
  const _PlaceFilterBar({required this.selected, required this.onSelect});

  final PlaceListFilter selected;
  final ValueChanged<PlaceListFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final f in PlaceListFilter.values) ...[
            if (f != PlaceListFilter.semua) const Gap(6),
            GestureDetector(
              onTap: () => onSelect(f),
              child: FBadge(
                variant: selected == f
                    ? FBadgeVariant.primary
                    : FBadgeVariant.secondary,
                child: Text(_filterLabels[f]!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<TextEditingValue> onChanged;

  @override
  Widget build(BuildContext context) {
    return FTextField(
      control: FTextFieldControl.managed(onChange: onChanged),
      hint: 'Cari destinasi...',
      textInputAction: TextInputAction.search,
      clearable: (value) => value.text.isNotEmpty,
      prefixBuilder: (context, style, variants) => FTextField.prefixIconBuilder(
        context,
        style,
        variants,
        const Icon(FLucideIcons.search),
      ),
    );
  }
}

/// Body kosong (belum ada konten sama sekali) TAPI search + filter tetap
/// tampil supaya user bisa mencoba kata lain tanpa kehilangan field.
class _EmptyWithSearch extends StatelessWidget {
  const _EmptyWithSearch({required this.search, this.filterBar});

  final Widget search;
  final Widget? filterBar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        search,
        const Gap(12),
        if (filterBar != null) ...[filterBar!, const Gap(12)],
        const Expanded(child: _EmptyBody()),
      ],
    );
  }
}

class _PlaceGridTile extends StatelessWidget {
  const _PlaceGridTile({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cover = place.cover;
    final titleStyle = theme.typography.body.xs.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.25,
    );
    final titleHeight = (titleStyle.fontSize ?? 12) * 1.25 * 2;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => context.push(
          ExploreRouter.place.path.replaceFirst(':slug', place.slug),
        ),
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: cover == null
                        ? ColoredBox(
                            color: theme.colors.muted,
                            child: Icon(
                              FLucideIcons.landmark,
                              size: 28,
                              color: theme.colors.mutedForeground,
                            ),
                          )
                        : CachedNetworkImageWithFallback(
                            imageUrl:
                                displayImageUrl(cover.url, width: 360) ??
                                cover.url,
                            fallbackUrl: cover.url,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: IconButton(
                      tooltip: 'Bookmark',
                      onPressed: () => showPlaceBookmarkSoon(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 28,
                        height: 28,
                      ),
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: theme.colors.background.withValues(
                          alpha: 0.88,
                        ),
                        minimumSize: const Size(28, 28),
                        fixedSize: const Size(28, 28),
                      ),
                      icon: Icon(
                        FLucideIcons.bookmark,
                        size: 14,
                        color: theme.colors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(6),
            SizedBox(
              height: titleHeight,
              child: Text(
                place.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place});

  static const _thumbSize = 88.0;

  final Place place;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cover = place.cover;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => context.push(
          ExploreRouter.place.path.replaceFirst(':slug', place.slug),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox.square(
                  dimension: _thumbSize,
                  child: cover == null
                      ? ColoredBox(
                          color: theme.colors.muted,
                          child: Icon(
                            place.category == PlaceCategory.kuliner
                                ? FLucideIcons.utensilsCrossed
                                : FLucideIcons.landmark,
                            size: 32,
                            color: theme.colors.mutedForeground,
                          ),
                        )
                      : CachedNetworkImageWithFallback(
                          imageUrl:
                              displayImageUrl(cover.url, width: 240) ??
                              cover.url,
                          fallbackUrl: cover.url,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      placeLabel(place),
                      style: theme.typography.body.xs.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colors.primary,
                      ),
                    ),
                    if (place.shortDescription.isNotEmpty)
                      Text(
                        place.shortDescription,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Bookmark',
                onPressed: () => showPlaceBookmarkSoon(context),
                padding: EdgeInsets.zero,
                alignment: Alignment.topRight,
                constraints: const BoxConstraints.tightFor(
                  width: 40,
                  height: 40,
                ),
                style: const ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Icon(
                  FLucideIcons.bookmark,
                  size: 20,
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FAlert(
              title: Text('Gagal memuat'),
              subtitle: Text(
                'Gagal terhubung ke server. Coba lagi dalam beberapa saat.',
              ),
            ),
            const Gap(16),
            FButton(onPress: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}

/// Skeleton kartu Place saat loading - bentuknya mirip konten asli supaya
/// transisi loading → konten/gagal tidak "loncat".
class _SkeletonList extends StatelessWidget {
  /// #104: true saat pull-to-refresh (muat ulang dari CDN) - label
  /// semantics membedakan "menyegarkan" dari loading awal.
  const _SkeletonList({this.refreshing = false, this.grid = false});

  final bool refreshing;
  final bool grid;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = context.theme.colors.muted;
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: isDark
            ? muted.withValues(alpha: 0.35)
            : const Color(0xFFE7E7EA),
        highlightColor: isDark
            ? muted.withValues(alpha: 0.55)
            : const Color(0xFFF4F4F5),
        duration: const Duration(milliseconds: 1500),
      ),
      child: grid
          ? GridView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: _placeGridDelegate,
              itemCount: 9,
              itemBuilder: (_, _) => const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Bone(
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  Gap(6),
                  Bone(width: double.infinity, height: 12),
                  Gap(4),
                  Bone(width: 72, height: 12),
                ],
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, _) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone(
                      width: _PlaceCard._thumbSize,
                      height: _PlaceCard._thumbSize,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Bone(width: 160, height: 16),
                          Gap(6),
                          Bone(width: 64, height: 14),
                          Gap(6),
                          Bone(width: 200, height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FLucideIcons.compass, size: 48, color: theme.colors.primary),
            const Gap(16),
            Text(
              'Belum ada destinasi',
              style: theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(8),
            Text(
              'Konten wisata dan kuliner sedang disiapkan. Balik lagi nanti ya.',
              textAlign: TextAlign.center,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
