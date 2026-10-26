import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/exclude_semantics_on_exit.dart';
import '../../domain/entities/event.dart';
import '../../event_router.dart';
import '../providers/event_browse_providers.dart';
import '../providers/event_providers.dart';

/// Grid 3 kolom, selaras grid wisata/kuliner (`place_list_page.dart`,
/// `cuisine_list_page.dart`): poster kotak 1:1 + nama maks 2 baris. Tanggal
/// tampil sebagai badge pill overlay di atas poster; badge status & jam
/// lengkap ada di halaman detail.
const _eventGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 3,
  mainAxisSpacing: 12,
  crossAxisSpacing: 8,
  childAspectRatio: 0.7,
);

/// Daftar acara (festival, pameran, kegiatan) di Sambas.
class EventListPage extends ConsumerStatefulWidget {
  const EventListPage({super.key});

  @override
  ConsumerState<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends ConsumerState<EventListPage> {
  String? _categoryId;
  String _query = '';
  Timer? _debounce;
  final _scroll = ScrollController();
  bool _autoloadBusy = false;
  int? _fillToken;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.removeListener(_maybeLoadMore);
    _scroll.dispose();
    super.dispose();
  }

  EventBrowseQuery get _browseQuery => EventBrowseQuery(
    categoryId: _categoryId,
    q: _query.trim(),
    notEnded: false,
  );

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted || text == _query) return;
      setState(() => _query = text);
      _resetScroll();
    });
  }

  /// Kembalikan daftar ke atas setelah filter/cari berubah. Dijadwalkan
  /// post-frame karena provider baru masih `AsyncLoading`: `CustomScrollView`
  /// belum terpasang, jadi `jumpTo(0)` di frame ini dilewati dan daftar
  /// tetap di posisi lama (terasa "nyangkut" di tengah).
  void _resetScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) _scroll.jumpTo(0);
    });
  }

  void _scheduleFillCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _maybeLoadMore();
    });
  }

  /// Halaman pertama yang tidak memenuhi layar tidak memicu scroll, jadi
  /// sisa halaman tidak pernah dimuat. Sama pola dengan daftar wisata.
  Future<void> _maybeLoadMore() async {
    if (_autoloadBusy || !_scroll.hasClients) return;
    final data = ref.read(eventBrowseProvider(_browseQuery)).value;
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
      await ref.read(eventBrowseProvider(_browseQuery).notifier).loadMore();
    } finally {
      _autoloadBusy = false;
      final after = ref.read(eventBrowseProvider(_browseQuery)).value;
      if (mounted && after != null && after.items.length != before) {
        _scheduleFillCheck();
      }
    }
  }

  Future<void> _reload() => ref
      .read(eventBrowseProvider(_browseQuery).notifier)
      .reload(keepItems: true);

  @override
  Widget build(BuildContext context) {
    final browseQuery = _browseQuery;
    final browseAsync = ref.watch(eventBrowseProvider(browseQuery));
    final categories = ref.watch(eventCategoriesProvider).value ?? const [];

    return ExcludeSemanticsOnExit(
      child: FScaffold(
        // Forui sudah memberi gutter dari tema - jangan tambah padding lagi.
        childPad: true,
        header: FHeader.nested(
          title: const Text('Acara'),
          prefixes: [
            FHeaderAction.back(
              onPress: () =>
                  context.canPop() ? context.pop() : context.go('/explore'),
            ),
          ],
          suffixes: [
            FHeaderAction(
              icon: const Icon(FLucideIcons.history),
              onPress: () => context.push(EventRouter.proposals.path),
            ),
            FHeaderAction(
              icon: const Icon(FLucideIcons.plus),
              onPress: () => context.push(EventRouter.contribute.path),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FTextField(
              control: FTextFieldControl.managed(
                onChange: (value) => _onSearchChanged(value.text),
              ),
              hint: 'Cari acara',
              textInputAction: TextInputAction.search,
              clearable: (value) => value.text.isNotEmpty,
              prefixBuilder: (context, style, variants) =>
                  FTextField.prefixIconBuilder(
                    context,
                    style,
                    variants,
                    const Icon(FLucideIcons.search),
                  ),
            ),
            const Gap(12),
            if (categories.isNotEmpty) ...[
              _CategoryBar(
                categories: categories,
                selectedId: _categoryId,
                onSelect: (id) {
                  if (id == _categoryId) return;
                  setState(() => _categoryId = id);
                  // Ganti chip = provider baru (AsyncLoading) -> scroll view
                  // sementara dilepas. Reset posisi SETELAH frame berikut,
                  // kalau dipanggil langsung controller bisa tanpa position.
                  _resetScroll();
                },
              ),
              const Gap(12),
            ],
            Expanded(
              child: browseAsync.when(
                loading: () => const _SkeletonGrid(),
                error: (_, _) => _ErrorBody(onRetry: _reload),
                data: (page) {
                  if (page.items.isEmpty) {
                    return _EmptyBody(
                      hasQuery: _query.trim().isNotEmpty,
                      onRefresh: _reload,
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
                  return RefreshIndicator(
                    onRefresh: _reload,
                    child: CustomScrollView(
                      controller: _scroll,
                      physics: const AlwaysScrollableScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      slivers: [
                        SliverGrid(
                          gridDelegate: _eventGridDelegate,
                          delegate: SliverChildBuilderDelegate(
                            (context, i) =>
                                _EventGridTile(event: page.items[i]),
                            childCount: page.items.length,
                          ),
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
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: FButton(
                                  variant: FButtonVariant.outline,
                                  onPress: () => ref
                                      .read(
                                        eventBrowseProvider(
                                          browseQuery,
                                        ).notifier,
                                      )
                                      .loadMore(),
                                  child: const Text('Coba lagi'),
                                ),
                              ),
                            ),
                          ),
                      ],
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

/// Chip kategori horizontal. "Semua" = tanpa filter.
class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<EventCategoryRef> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onSelect(null),
            child: FBadge(
              variant: selectedId == null
                  ? FBadgeVariant.primary
                  : FBadgeVariant.secondary,
              child: const Text('Semua'),
            ),
          ),
          for (final category in categories) ...[
            const Gap(6),
            GestureDetector(
              onTap: () => onSelect(category.id),
              child: FBadge(
                variant: selectedId == category.id
                    ? FBadgeVariant.primary
                    : FBadgeVariant.secondary,
                child: Text(category.name),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Subtitle kartu grid: tanggal mulai singkat, mis. `17 Nov`. Jam dan status
/// lengkap ada di halaman detail.
String _gridSchedule(Event event) {
  return formatDateShort(event.startsAt);
}

/// Kartu acara di grid 3 kolom, bentuk sama dengan kartu wisata/kuliner:
/// poster kotak 1:1 + nama maks 2 baris. Tanggal mulai jadi badge pill
/// overlay di pojok poster - badge status & jam sengaja tidak ditampilkan
/// (sel kecil); info lengkap ada di halaman detail.
class _EventGridTile extends StatelessWidget {
  const _EventGridTile({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final poster = event.posterUrls.isEmpty ? null : event.posterUrls.first;
    final titleStyle = theme.typography.body.xs.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.25,
    );
    // fontSize fallback 14 = nilai xs Forui touch mode (lihat typography.dart);
    // fallback 12 lama bikin SizedBox lebih pendek dari teks aslinya.
    final titleHeight = (titleStyle.fontSize ?? 14) * 1.25 * 2;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => context.push(EventRouter.detailPath(event.slug)),
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
                    child: poster == null || poster.isEmpty
                        ? ColoredBox(
                            color: theme.colors.muted,
                            child: Icon(
                              FLucideIcons.calendarDays,
                              size: 28,
                              color: theme.colors.mutedForeground,
                            ),
                          )
                        : CachedNetworkImageWithFallback(
                            imageUrl:
                                displayImageUrl(poster, width: 480) ?? poster,
                            fallbackUrl: poster,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    left: 4,
                    bottom: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colors.background.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: Text(
                          _gridSchedule(event),
                          maxLines: 1,
                          style: theme.typography.body.xs.copyWith(
                            color: theme.colors.foreground,
                          ),
                        ),
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
                event.name,
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

/// Skeleton grid saat loading - bentuknya sama dengan kartu asli supaya
/// transisi loading -> konten tidak "loncat".
class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

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
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: _eventGridDelegate,
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
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.hasQuery, required this.onRefresh});

  final bool hasQuery;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const Gap(48),
          Center(
            child: Icon(
              FLucideIcons.calendarDays,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(10),
          Text(
            hasQuery ? 'Belum ada acara yang cocok' : 'Belum ada acara',
            textAlign: TextAlign.center,
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(4),
          Text(
            hasQuery
                ? 'Coba kata lain ya.'
                : 'Kalau ada acara di sekitarmu, bisa kamu usulkan sendiri.',
            textAlign: TextAlign.center,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(16),
          Center(
            child: FButton(
              variant: FButtonVariant.outline,
              onPress: () => context.push(EventRouter.contribute.path),
              child: const Text('Usulkan acara'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FAlert(
            title: Text('Gagal memuat acara'),
            subtitle: Text('Periksa koneksi internetmu lalu coba lagi ya.'),
          ),
          const Gap(16),
          FButton(onPress: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}
