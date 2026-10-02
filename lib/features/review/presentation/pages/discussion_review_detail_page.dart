import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../discussion/data/discussion_providers.dart';
import '../../../discussion/domain/discussion_models.dart';
import '../providers/discussion_review_providers.dart';
import '../widgets/discussion_image_censor_editor.dart';

/// Detail diskusi pending + Setujui / Tolak (+ sensor multi-foto).
class DiscussionReviewDetailPage extends ConsumerWidget {
  const DiscussionReviewDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(discussionReviewDetailProvider(id));

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Tinjau diskusi'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: async.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (error, _) => Center(
          child: Text(
            error is DiscussionFailure
                ? error.message
                : 'Gagal memuat detail',
            textAlign: TextAlign.center,
          ),
        ),
        data: (item) => _DiscussionReviewBody(item: item),
      ),
    );
  }
}

class _DiscussionReviewBody extends ConsumerStatefulWidget {
  const _DiscussionReviewBody({required this.item});

  final DiscussionItem item;

  @override
  ConsumerState<_DiscussionReviewBody> createState() =>
      _DiscussionReviewBodyState();
}

class _DiscussionReviewBodyState extends ConsumerState<_DiscussionReviewBody> {
  bool _busy = false;
  int _activeIndex = 0;
  late List<Uint8List?> _censoredByIndex;
  late List<bool> _violenceByIndex;
  late List<MemoryImage?> _censoredPreviews;

  DiscussionItem get item => widget.item;

  bool get _isPending => item.status == 'pending_review';

  int get _n => item.images.length;

  @override
  void initState() {
    super.initState();
    _censoredByIndex = List<Uint8List?>.filled(_n, null);
    _violenceByIndex = List<bool>.filled(_n, false);
    _censoredPreviews = List<MemoryImage?>.filled(_n, null);
  }

  Future<void> _openCensorEditorSmart(int index) async {
    final src = item.images[index].displaySource;
    if (src == null || src.isEmpty) {
      showFToast(
        context: context,
        title: const Text('URL gambar staging tidak tersedia'),
      );
      return;
    }
    final loadUrl = displayImageUrl(src) ?? src;

    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => DiscussionImageCensorEditorPage(
          imageUrl: loadUrl,
          onApply: (bytes) {
            setState(() {
              _censoredByIndex[index] = bytes;
              _censoredPreviews[index] = MemoryImage(bytes);
            });
          },
        ),
      ),
    );
  }

  void _clearCensor(int index) {
    setState(() {
      _censoredByIndex[index] = null;
      _censoredPreviews[index] = null;
    });
  }

  Future<void> _approve() async {
    if (_busy || !_isPending) return;

    Future<void> run() async {
      setState(() => _busy = true);
      final warnings = [
        for (final v in _violenceByIndex) v ? <String>['kekerasan'] : <String>[],
      ];
      final result = await ref.read(discussionRepositoryProvider).approveAdmin(
        item.id,
        censoredFiles: _n > 0
            ? [
                for (final b in _censoredByIndex) b?.toList(),
              ]
            : null,
        contentWarnings: _n > 0 ? warnings : null,
      );
      if (!mounted) return;
      setState(() => _busy = false);
      result.fold(
        (failure) {
          showFToast(context: context, title: Text(failure.message));
        },
        (_) {
          ref.read(discussionReviewListProvider.notifier).drop(item.id);
          invalidateDiscussionReview(ref);
          showFToast(
            context: context,
            title: const Text('Diskusi disetujui dan tayang'),
          );
          context.pop();
        },
      );
    }

    if (_n == 0) {
      await run();
      return;
    }

    final m = _censoredByIndex.where((e) => e != null && e.isNotEmpty).length;
    final k = _violenceByIndex.where((e) => e).length;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Pastikan semua foto aman',
                  style: context.theme.typography.lg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(8),
                Text(
                  'Kamu menyetujui $_n foto ($m tersensor · $k ber-flag kekerasan).',
                ),
                const Gap(8),
                Text(
                  'Pastikan foto bukan NSFW, aman ditayangkan publik, '
                  'data sensitif sudah disensor bila perlu, dan flag kekerasan '
                  'sudah ditempel bila perlu.',
                  style: context.theme.typography.sm.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
                const Gap(16),
                FButton(
                  onPress: () => Navigator.of(sheetContext).pop(true),
                  child: const Text('Saya sudah memeriksa, setujui'),
                ),
                const Gap(8),
                FButton(
                  variant: FButtonVariant.outline,
                  onPress: () => Navigator.of(sheetContext).pop(false),
                  child: const Text('Batal'),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed == true && mounted) await run();
  }

  Future<void> _reject() async {
    if (_busy || !_isPending) return;
    final controller = TextEditingController();
    final note = await showFDialog<String>(
      context: context,
      builder: (dialogContext, style, animation) {
        return FDialog(
          style: style,
          animation: animation,
          title: const Text('Tolak diskusi'),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Berikan alasan penolakan (wajib).'),
              const Gap(12),
              FTextField(
                control: FTextFieldControl.managed(controller: controller),
                label: const Text('Alasan'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            FButton(
              onPress: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                Navigator.of(dialogContext).pop(text);
              },
              child: const Text('Tolak'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (note == null || note.isEmpty || !mounted) return;

    setState(() => _busy = true);
    final result = await ref.read(discussionRepositoryProvider).rejectAdmin(
      id: item.id,
      note: note,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold(
      (failure) {
        showFToast(context: context, title: Text(failure.message));
      },
      (_) {
        ref.read(discussionReviewListProvider.notifier).drop(item.id);
        invalidateDiscussionReview(ref);
        showFToast(
          context: context,
          title: const Text('Diskusi ditolak'),
        );
        context.pop();
      },
    );
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') {
      showFToast(
        context: context,
        title: const Text('Tautan tidak valid'),
      );
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      showFToast(
        context: context,
        title: const Text('Tidak bisa membuka tautan'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final name = displayPublicAccountLabel(
      displayName: item.displayName,
      username: item.username,
    );
    final body = (item.body ?? '').trim();
    final link = item.linkUrl?.trim();
    final active = _n > 0 ? _activeIndex.clamp(0, _n - 1) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            children: [
              Text(
                name,
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              if (item.createdAt.isNotEmpty) ...[
                const Gap(4),
                Text(
                  formatRelativeCompact(DateTime.tryParse(item.createdAt)),
                  style: theme.typography.xs.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ],
              const Gap(16),
              Text(
                body.isEmpty ? '(tanpa teks)' : body,
                style: theme.typography.sm,
              ),
              if (link != null && link.isNotEmpty) ...[
                const Gap(12),
                FButton(
                  variant: FButtonVariant.outline,
                  onPress: () => _openLink(link),
                  prefix: const Icon(FLucideIcons.externalLink),
                  child: Text(
                    link,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (_n > 0) ...[
                const Gap(16),
                Text(
                  'Lampiran gambar ($_n)',
                  style: theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                SizedBox(
                  height: 72,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _n,
                    separatorBuilder: (_, _) => const Gap(8),
                    itemBuilder: (context, index) {
                      final img = item.images[index];
                      final mem = _censoredPreviews[index];
                      final src = img.displaySource;
                      final selected = index == active;
                      return GestureDetector(
                        onTap: () => setState(() => _activeIndex = index),
                        child: Stack(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selected
                                      ? theme.colors.primary
                                      : theme.colors.border,
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: mem != null
                                  ? Image(
                                      image: mem,
                                      fit: BoxFit.cover,
                                    )
                                  : src != null
                                      ? CachedNetworkImageWithFallback(
                                          imageUrl:
                                              displayImageUrl(src) ?? src,
                                          fit: BoxFit.cover,
                                        )
                                      : const ColoredBox(
                                          color: Color(0x11000000),
                                        ),
                            ),
                            if (_censoredByIndex[index] != null)
                              const Positioned(
                                left: 4,
                                top: 4,
                                child: _MiniBadge(
                                  label: 'S',
                                  color: Color(0xFF3B82F6),
                                ),
                              ),
                            if (_violenceByIndex[index])
                              Positioned(
                                left: _censoredByIndex[index] != null ? 22 : 4,
                                top: 4,
                                child: const _MiniBadge(
                                  label: 'K',
                                  color: Color(0xFFF59E0B),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Gap(12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final screenW = MediaQuery.sizeOf(context).width;
                    final sideInset =
                        ((screenW - constraints.maxWidth) / 2).clamp(0.0, 48.0);
                    final src = item.images[active].displaySource;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: -sideInset),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AspectRatio(
                            aspectRatio: 4 / 3,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                final urls = [
                                  for (final img in item.images)
                                    if (img.displaySource != null)
                                      displayImageUrl(
                                            img.displaySource!,
                                            width: 1200,
                                          ) ??
                                          img.displaySource!,
                                ];
                                if (urls.isEmpty) return;
                                showImagePreview(
                                  context,
                                  urls: urls,
                                  initialIndex: active.clamp(0, urls.length - 1),
                                );
                              },
                              child: ColoredBox(
                                color: const Color(0x11000000),
                                child: _censoredPreviews[active] != null
                                    ? Image(
                                        image: _censoredPreviews[active]!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      )
                                    : src != null
                                        ? CachedNetworkImageWithFallback(
                                            imageUrl:
                                                displayImageUrl(src) ?? src,
                                            fit: BoxFit.cover,
                                          )
                                        : const SizedBox.expand(),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.fromLTRB(sideInset, 8, sideInset, 0),
                            child: Text(
                              'Ketuk foto untuk melihat ukuran penuh',
                              textAlign: TextAlign.center,
                              style: theme.typography.xs.copyWith(
                                color: theme.colors.mutedForeground,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                if (_isPending) ...[
                  const Gap(12),
                  Row(
                    children: [
                      Expanded(
                        child: FButton(
                          variant: FButtonVariant.outline,
                          onPress: _busy
                              ? null
                              : () => _openCensorEditorSmart(active),
                          child: Text(
                            _censoredByIndex[active] != null
                                ? 'Edit sensor'
                                : 'Sensor',
                          ),
                        ),
                      ),
                      if (_censoredByIndex[active] != null) ...[
                        const Gap(8),
                        FButton(
                          variant: FButtonVariant.ghost,
                          onPress: _busy ? null : () => _clearCensor(active),
                          child: const Text('Batalkan'),
                        ),
                      ],
                    ],
                  ),
                  const Gap(8),
                  FTile(
                    title: Text('Gambar ${active + 1}: berisi kekerasan'),
                    subtitle: const Text(
                      'Centang jika foto menunjukkan kekerasan',
                    ),
                    suffix: Switch.adaptive(
                      value: _violenceByIndex[active],
                      onChanged: _busy
                          ? null
                          : (v) => setState(() => _violenceByIndex[active] = v),
                    ),
                  ),
                ],
              ],
              const Gap(24),
            ],
          ),
        ),
        if (_isPending) ...[
          FButton(
            onPress: _busy ? null : _approve,
            child: _busy
                ? const FCircularProgress()
                : const Text('Setujui & tayangkan'),
          ),
          const Gap(8),
          FButton(
            variant: FButtonVariant.outline,
            onPress: _busy ? null : _reject,
            child: const Text('Tolak'),
          ),
          const Gap(12),
        ] else
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Status: ${item.statusLabel}',
              textAlign: TextAlign.center,
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
      ],
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
