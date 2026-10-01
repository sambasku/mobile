import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../shared/widgets/image_credit.dart';
import '../data/share_background_repository.dart';
import '../domain/share_models.dart';
import 'widgets/share_skeleton.dart';
const _photoProviders = ['pixabay', 'openverse', 'unsplash'];
const _videoProviders = ['pixabay'];

/// Jelajah latar / gambar stock: tab Gambar | Video, provider sebagai chip.
/// [photoOnly] = true untuk konteks gambar kata (sembunyikan tab Video).
Future<ShareBackground?> showShareMediaExplorer(
  BuildContext context, {
  required ShareBackgroundRepository backgrounds,
  bool initialVideo = false,
  bool photoOnly = false,
}) {
  return showModalBottomSheet<ShareBackground>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    // Root navigator: aman di atas sheet lain (share / pilih sumber) dan
    // shell GoRouter, supaya pop(item) tidak salah route.
    useRootNavigator: true,
    builder: (_) => _MediaExplorerBody(
      backgrounds: backgrounds,
      initialVideo: photoOnly ? false : initialVideo,
      photoOnly: photoOnly,
    ),
  );
}

class _MediaExplorerBody extends StatefulWidget {
  const _MediaExplorerBody({
    required this.backgrounds,
    required this.initialVideo,
    this.photoOnly = false,
  });

  final ShareBackgroundRepository backgrounds;
  final bool initialVideo;
  final bool photoOnly;

  @override
  State<_MediaExplorerBody> createState() => _MediaExplorerBodyState();
}

class _MediaExplorerBodyState extends State<_MediaExplorerBody>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late final TabController _tabs;

  String _photoProvider = 'pixabay';
  String _videoProvider = 'pixabay';
  late String _media;
  late String _provider;
  String _mode = 'popular';
  String _activeQuery = '';
  int _page = 1;
  bool _loading = true;
  bool _loadingMore = false;
  bool _degraded = false;
  bool _hasMore = true;
  List<ShareBackground> _items = const [];

  @override
  void initState() {
    super.initState();
    _media = widget.initialVideo ? 'video' : 'photo';
    _provider = _media == 'video' ? _videoProvider : _photoProvider;
    _tabs = TabController(
      length: widget.photoOnly ? 1 : 2,
      vsync: this,
      initialIndex: widget.photoOnly ? 0 : (widget.initialVideo ? 1 : 0),
    );
    if (!widget.photoOnly) {
      _tabs.addListener(_onTab);
    }
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  @override
  void dispose() {
    if (!widget.photoOnly) {
      _tabs.removeListener(_onTab);
    }
    _tabs.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onTab() {
    if (_tabs.indexIsChanging) return;
    final nextMedia = _tabs.index == 1 ? 'video' : 'photo';
    if (nextMedia == _media) return;
    setState(() {
      _media = nextMedia;
      _provider = nextMedia == 'video' ? _videoProvider : _photoProvider;
    });
    _loadInitial();
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore || _loading || !_scrollCtrl.hasClients) {
      return;
    }
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 240) {
      _loadMore();
    }
  }

  List<String> get _providersForTab =>
      _media == 'video' ? _videoProviders : _photoProviders;

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _page = 1;
      _hasMore = true;
      _items = const [];
    });
    final isSearch = _activeQuery.trim().isNotEmpty;
    final result = await widget.backgrounds.listBackgrounds(
      isSearch ? _activeQuery : '',
      page: 1,
      sort: isSearch ? 'relevant' : 'popular',
      provider: _provider,
      media: _media,
      limit: 12,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _degraded = result.degraded;
      _items = result.items;
      _page = result.page;
      _hasMore = result.items.length >= 12;
      _mode = isSearch ? 'relevant' : 'popular';
    });
    _fillViewport();
  }

  /// 12 item (4 baris) sering muat di layar tanpa scroll, jadi _onScroll tidak
  /// pernah terpicu. Cek setelah frame: kalau grid belum penuh, muat halaman
  /// berikutnya sampai bisa di-scroll atau data habis.
  void _fillViewport() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onScroll();
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    final next = _page + 1;
    final isSearch = _mode == 'relevant';
    final result = await widget.backgrounds.listBackgrounds(
      isSearch ? _activeQuery : '',
      page: next,
      sort: _mode,
      provider: _provider,
      media: _media,
      limit: 12,
    );
    if (!mounted) return;
    setState(() {
      _loadingMore = false;
      if (result.items.isEmpty) {
        _hasMore = false;
      } else {
        _items = [..._items, ...result.items];
        _page = next;
        _hasMore = result.items.length >= 12;
      }
    });
    _fillViewport();
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim();
    setState(() => _activeQuery = q);
    _loadInitial();
  }

  void _onClearSearch() {
    _searchCtrl.clear();
    setState(() => _activeQuery = '');
    _loadInitial();
  }

  void _selectProvider(String id) {
    setState(() {
      if (_media == 'video') {
        _videoProvider = id;
      } else {
        _photoProvider = id;
      }
      _provider = id;
    });
    _loadInitial();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final media = MediaQuery.of(context);
    final badge = _media == 'video'
        ? '${shareProviderLabel(_provider)} video'
        : shareProviderLabel(_provider);

    return SizedBox(
      height: media.size.height * 0.92,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Media Explorer',
                        style: theme.typography.lg.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colors.secondary,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: theme.colors.border),
                        ),
                        child: Text(
                          badge,
                          style: theme.typography.sm.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: theme.colors.foreground),
                ),
              ],
            ),
          ),
          if (!widget.photoOnly)
            TabBar(
              controller: _tabs,
              labelColor: theme.colors.foreground,
              unselectedLabelColor: theme.colors.mutedForeground,
              indicatorColor: theme.colors.primary,
              tabs: const [
                Tab(text: 'Gambar'),
                Tab(text: 'Video'),
              ],
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final id in _providersForTab)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _selectProvider(id),
                    child: FBadge(
                      variant: _provider == id
                          ? FBadgeVariant.primary
                          : FBadgeVariant.secondary,
                      child: Text(shareProviderLabel(id)),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _onSearch(),
                    decoration: InputDecoration(
                      hintText: _media == 'video'
                          ? 'Cari video…'
                          : 'Cari gambar…',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: _onClearSearch,
                            )
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const Gap(8),
                FButton(
                  mainAxisSize: MainAxisSize.min,
                  onPress: _onSearch,
                  child: const Text('Cari'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _mode == 'popular' ? 'Populer' : 'Hasil: $_activeQuery',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
          const Gap(8),
          Expanded(child: _buildGrid(context)),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final theme = context.theme;
    if (_loading) {
      return ShareSkeleton(
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 9,
          itemBuilder: (_, _) => Bone(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _degraded
                ? 'Latar tidak tersedia. Coba lagi nanti.'
                : 'Tidak ada hasil.',
            textAlign: TextAlign.center,
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
      );
    }
    return GridView.builder(
      controller: _scrollCtrl,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: _items.length + (_loadingMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= _items.length) {
          return ShareSkeleton(
            child: Bone(borderRadius: BorderRadius.circular(10)),
          );
        }
        final item = _items[i];
        // opaque: default deferToChild sering gagal hit-test saat placeholder
        // / gambar belum penuh, jadi tap diam saja.
        final isUnsplash = item.provider == 'unsplash';
        final isOpenverse = item.provider == 'openverse';
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (isUnsplash) widget.backgrounds.trackUnsplashDownload(item.id);
            Navigator.of(context).pop(item);
          },
          // Dasar gelap: tile tetap "berbobot" saat gambar masih dimuat.
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF1C1917),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImageWithFallback(
                    imageUrl: item.thumbUrl,
                    fit: BoxFit.cover,
                  ),
                  if (isUnsplash || isOpenverse)
                    Positioned(
                      left: 5,
                      right: 5,
                      bottom: 5,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            child: ImageCredit(
                              attribution: item.attribution,
                              color: Colors.white,
                              fontSize: 11.5,
                              compact: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (item.isVideo)
                    const Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
