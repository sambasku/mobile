import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../auth/auth_router.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/entities/event_image.dart';
import '../../event_router.dart';
import '../providers/event_providers.dart';

/// Grid foto acara, 3 kolom (pola PlacePhotosPage). Halaman pertama dari
/// provider galeri; halaman lanjut via `next_offset` saat scroll.
class EventPhotosPage extends ConsumerStatefulWidget {
  const EventPhotosPage({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<EventPhotosPage> createState() => _EventPhotosPageState();
}

class _EventPhotosPageState extends ConsumerState<EventPhotosPage> {
  final _scroll = ScrollController();
  final _images = <EventImage>[];

  /// Offset halaman berikut; null = galeri habis.
  /// 0 = belum pernah load (halaman pertama di-fetch saat init).
  int? _nextOffset = 0;
  bool _loading = false;
  bool _failed = false;
  bool _firstLoaded = false;
  String? _title;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMore());
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final left = _scroll.position.maxScrollExtent - _scroll.position.pixels;
    if (left < 400) _loadMore();
  }

  Future<void> _loadMore({bool reset = false}) async {
    final offset = reset ? 0 : _nextOffset;
    // offset null = galeri habis; 0 saat reset = halaman pertama.
    if (offset == null || _loading) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final page = await ref
          .read(eventRepositoryProvider)
          .imagePage(widget.slug, offset: offset);
      if (!mounted) return;
      setState(() {
        if (reset) _images.clear();
        final seen = {
          for (final img in _images) img.url,
        };
        _images.addAll(page.items.where((img) => !seen.contains(img.url)));
        _nextOffset = page.nextOffset;
        _firstLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Sepulang dari halaman unggah: muat ulang galeri dari awal.
  Future<void> _refresh() async {
    ref.invalidate(eventImagePreviewProvider(widget.slug));
    ref.invalidate(eventBySlugProvider(widget.slug));
    if (!mounted) return;
    await _loadMore(reset: true);
  }

  /// Pull-to-refresh: reset galeri + invalidate detail (pola wisata).
  Future<void> _onPullRefresh() async {
    ref.invalidate(eventBySlugProvider(widget.slug));
    setState(() => _nextOffset = 0);
    await _loadMore(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final guest = ref.watch(authStatusProvider).value?.isAuth != true;

    final detail = ref.watch(eventBySlugProvider(widget.slug)).asData?.value;
    _title ??= detail?.name;

    return FScaffold(
      header: FHeader.nested(
        title: Text(_title ?? l10n.eventPhotosTitle),
        prefixes: [FHeaderAction.back(onPress: () => _back(context))],
      ),
      childPad: false,
      child: Column(
        children: [
          Expanded(child: _body(context)),
          _UploadBar(slug: widget.slug, guest: guest, onReturned: _refresh),
        ],
      ),
    );
  }

  void _back(BuildContext context) =>
      context.canPop() ? context.pop() : context.go('/acara');

  Widget _body(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!_firstLoaded && _loading) {
      return const _PhotosSkeleton();
    }
    if (!_firstLoaded && _failed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FButton(
            onPress: () => _loadMore(),
            child: Text(l10n.commonRetry),
          ),
        ),
      );
    }
    if (_images.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onPullRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text(l10n.eventPhotosEmpty)),
            ),
          ],
        ),
      );
    }
    final footer = _loading
        ? 3
        : _failed
            ? 3
            : 0;
    return GridView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: _images.length + footer,
      itemBuilder: (context, i) {
        if (i >= _images.length) {
          if (_failed && i == _images.length) {
            return Center(
              child: FButton(
                variant: FButtonVariant.outline,
                onPress: _loadMore,
                child: Text(AppLocalizations.of(context).commonRetry),
              ),
            );
          }
          return const ColoredBox(color: Colors.transparent);
        }
        final img = _images[i];
        return GestureDetector(
          onTap: () => showImagePreview(
            context,
            urls: [for (final im in _images) im.url],
            credits: [for (final im in _images) im.attribution],
            initialIndex: i,
          ),
          child: CachedNetworkImageWithFallback(
            imageUrl: displayImageUrl(img.url, width: 480) ?? img.url,
            fallbackUrl: img.url,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}

class _UploadBar extends StatelessWidget {
  const _UploadBar({
    required this.slug,
    required this.guest,
    required this.onReturned,
  });

  final String slug;

  /// Foto acara tayang di feed publik -> tamu diarahkan login.
  final bool guest;

  /// Dipanggil setelah halaman unggah ditutup (foto baru sudah di server).
  final Future<void> Function() onReturned;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: FButton(
          prefix: const Icon(FLucideIcons.camera),
          onPress: () async {
            await context.push(
              guest
                  ? AuthRouter.login.path
                  : EventRouter.photoAddPath(slug),
            );
            if (!guest) await onReturned();
          },
          child: Text(AppLocalizations.of(context).eventPhotosUpload),
        ),
      ),
    );
  }
}

class _PhotosSkeleton extends StatelessWidget {
  const _PhotosSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: 9,
      itemBuilder: (_, _) => ColoredBox(color: theme.colors.muted),
    );
  }
}
