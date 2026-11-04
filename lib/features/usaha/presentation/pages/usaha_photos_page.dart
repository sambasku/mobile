import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../auth/auth_router.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/entities/usaha.dart';
import '../../usaha_router.dart';
import '../providers/usaha_providers.dart';

/// Galeri foto singgah usaha (3 kolom) + unggah.
class UsahaPhotosPage extends ConsumerStatefulWidget {
  const UsahaPhotosPage({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<UsahaPhotosPage> createState() => _UsahaPhotosPageState();
}

class _UsahaPhotosPageState extends ConsumerState<UsahaPhotosPage> {
  static const _pageSize = 12;

  final _scroll = ScrollController();
  final _extra = <UsahaImage>[];
  int? _nextOffset;
  bool _loading = false;
  bool _uploading = false;
  String? _loadedSlug;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
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
    if (left < 400) unawaited(_loadMore());
  }

  void _reset(Usaha usaha) {
    if (_loadedSlug == widget.slug) return;
    _loadedSlug = widget.slug;
    _extra.clear();
    _nextOffset = usaha.images.length < _pageSize ? null : _pageSize;
    unawaited(_loadMore());
  }

  List<UsahaImage> _firstPage(Usaha? usaha) => usaha?.images ?? const [];

  Future<void> _loadMore() async {
    final offset = _nextOffset;
    if (offset == null || _loading) return;
    setState(() => _loading = true);
    try {
      final page = await ref
          .read(usahaRepositoryProvider)
          .imagePage(widget.slug, offset: offset);
      if (!mounted) return;
      setState(() {
        // Dedup terhadap halaman 1 dari detail + yang sudah di-_extra.
        final detail = ref.read(usahaBySlugProvider(widget.slug)).value;
        final seen = {
          for (final img in _firstPage(detail)) img.url,
          for (final img in _extra) img.url,
        };
        _extra.addAll(page.items.where((img) => !seen.contains(img.url)));
        _nextOffset = page.nextOffset;
      });
    } catch (_) {
      // biarkan tombol muat ulang lewat pull
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _upload() async {
    final l10n = AppLocalizations.of(context);
    final authed = ref.read(authStatusProvider).value?.isAuth == true;
    if (!authed) {
      if (context.mounted) context.push(AuthRouter.login.path);
      return;
    }
    final files = await FilePicker.pickFiles(type: FileType.image);
    if (files.isEmpty || !mounted) return;
    setState(() => _uploading = true);
    try {
      final repo = ref.read(usahaRepositoryProvider);
      final urls = <String>[];
      for (final f in files.take(5)) {
        final path = f.path;
        if (path == null) continue;
        urls.add(await repo.uploadImage(File(path)));
      }
      if (urls.isEmpty) return;
      await repo.appendImages(widget.slug, urls);
      ref.invalidate(usahaBySlugProvider(widget.slug));
      if (!mounted) return;
      setState(() {
        _loadedSlug = null;
        _extra.clear();
      });
    } catch (e) {
      if (!mounted) return;
      await showAppErrorSheet(
        context,
        message: e is Exception ? e.toString() : l10n.usahaUploadImageFailed,
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(usahaBySlugProvider(widget.slug));

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.usahaPhotosTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go(UsahaRouter.detailPath(widget.slug)),
          ),
        ],
        suffixes: [
          FHeaderAction(
            icon: _uploading
                ? const FCircularProgress()
                : const Icon(FLucideIcons.plus),
            onPress: _uploading ? null : _upload,
          ),
        ],
      ),
      child: async.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (_, _) => Center(child: Text(l10n.usahaNotFound)),
        data: (usaha) {
          if (usaha == null) {
            return Center(child: Text(l10n.usahaNotFound));
          }
          _reset(usaha);
          final images = [...usaha.images, ..._extra];
          if (images.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.usahaPhotosEmpty,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return GridView.builder(
            controller: _scroll,
            padding: const EdgeInsets.only(bottom: 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: images.length + (_loading ? 1 : 0),
            itemBuilder: (context, i) {
              if (i >= images.length) {
                return const Center(child: FCircularProgress(size: .sm));
              }
              final img = images[i];
              return GestureDetector(
                onTap: () => showImagePreview(
                  context,
                  urls: [for (final im in images) im.url],
                  initialIndex: i,
                ),
                child: CachedNetworkImageWithFallback(
                  imageUrl: displayImageUrl(img.url, width: 400) ?? img.url,
                  fallbackUrl: img.url,
                  fit: BoxFit.cover,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
