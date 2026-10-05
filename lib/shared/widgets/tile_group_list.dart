import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// List seragam gaya network_monitor: satu `FTileGroup.builder` (kartu
/// bordered, divider inset otomatis dari Forui) + autoload saat scroll
/// mendekati ekor (sisa scroll < 200px).
///
/// `onLoadMore` dipanggil saat scroll mendekati ekor (sisa scroll < 200px).
/// ponytail: notifier kebanyakan punya guard `isLoadingMore` sendiri; widget
/// ini menambah guard sync supaya notifier tanpa guard (mis. review_history)
/// tidak dobel-fetch dalam async gap. Retry "muat lagi" inline belum ada -
/// gagal autoload diam sampai pull-to-refresh; tambah kalau laporan masuk.
class TileGroupList<T> extends StatefulWidget {
  const TileGroupList({
    required this.items,
    required this.hasMore,
    required this.onLoadMore,
    required this.tileBuilder,
    this.physics = const AlwaysScrollableScrollPhysics(),
    super.key,
  });

  final List<T> items;
  final bool hasMore;
  final Future<void> Function() onLoadMore;
  final Widget Function(BuildContext context, T item) tileBuilder;
  final ScrollPhysics physics;

  @override
  State<TileGroupList<T>> createState() => _TileGroupListState<T>();
}

class _TileGroupListState<T> extends State<TileGroupList<T>> {
  final _scroll = ScrollController();

  /// Guard anti dobel-fetch saat listener lebih cepat dari async loadMore.
  bool _loadingMore = false;

  /// Panjang item saat load terakhir mulai. Kalau load selesai tanpa
  /// penambahan item (halaman kosong tapi hasMore=true), stop autoload
  /// supaya tidak loop request tanpa ujung; recovery lewat pull-to-refresh.
  int _lastLoadStartLength = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
    _scheduleFillCheck();
  }

  @override
  void didUpdateWidget(covariant TileGroupList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != oldWidget.items.length ||
        widget.hasMore != oldWidget.hasMore) {
      _scheduleFillCheck();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // Halaman pertama yang lebih pendek dari layar tidak memicu scroll, jadi
  // sisa halaman tidak pernah dimuat. Cek ulang setelah frame selesai.
  void _scheduleFillCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _maybeLoadMore();
    });
  }

  Future<void> _maybeLoadMore() async {
    if (_loadingMore || !widget.hasMore || !_scroll.hasClients) return;
    if (_scroll.position.maxScrollExtent - _scroll.position.pixels >= 200) {
      return;
    }
    _loadingMore = true;
    _lastLoadStartLength = widget.items.length;
    try {
      await widget.onLoadMore();
    } finally {
      _loadingMore = false;
      if (mounted && widget.items.length != _lastLoadStartLength) {
        _scheduleFillCheck();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FTileGroup.builder(
      scrollController: _scroll,
      physics: widget.physics,
      count: widget.items.length,
      tileBuilder: (context, index) =>
          widget.tileBuilder(context, widget.items[index]),
    );
  }
}
