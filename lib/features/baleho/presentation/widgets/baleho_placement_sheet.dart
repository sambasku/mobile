import 'dart:async';

import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/baleho_models.dart';

/// Frame "parent" = rujukan judul / body / tombol (frame pertama).
BalehoFrame? balehoParentFrame(BalehoPlacement placement) {
  if (placement.frames.isEmpty) return null;
  return placement.frames.first;
}

/// Frame yang punya media gambar/video (carousel child).
List<BalehoFrame> balehoMediaFrames(BalehoPlacement placement) {
  return [
    for (final f in placement.frames)
      if (f.mediaUrl != null &&
          f.mediaUrl!.trim().isNotEmpty &&
          (f.mediaType == 'image' || f.mediaType == 'video'))
        f,
  ];
}

/// Preview placement sebelum aksi.
///
/// Judul, teks, dan label tombol selalu dari frame parent (pertama).
/// Child frame hanya menyumbang gambar di carousel.
Future<bool?> showBalehoPlacementSheet(
  BuildContext context, {
  required BalehoPlacement placement,
  BalehoFrame? frame,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Padding(
        padding: MediaQuery.viewInsetsOf(sheetContext),
        child: _BalehoPlacementSheetBody(
          placement: placement,
          // frame arg diabaikan untuk copy - tetap diterima demi call-site lama.
          initialFrame: frame,
        ),
      );
    },
  );
}

class _BalehoPlacementSheetBody extends StatefulWidget {
  const _BalehoPlacementSheetBody({
    required this.placement,
    this.initialFrame,
  });

  final BalehoPlacement placement;
  final BalehoFrame? initialFrame;

  @override
  State<_BalehoPlacementSheetBody> createState() =>
      _BalehoPlacementSheetBodyState();
}

class _BalehoPlacementSheetBodyState extends State<_BalehoPlacementSheetBody> {
  var _mediaIndex = 0;
  Timer? _timer;

  BalehoPlacement get _placement => widget.placement;

  BalehoFrame? get _parent => balehoParentFrame(_placement);

  List<BalehoFrame> get _media => balehoMediaFrames(_placement);

  double get _slotAspect {
    final w = _placement.w < 1 ? 1 : _placement.w;
    final h = _placement.h < 1 ? 1 : _placement.h;
    return w / h;
  }

  @override
  void initState() {
    super.initState();
    final media = _media;
    if (widget.initialFrame != null && media.isNotEmpty) {
      final i = media.indexWhere((f) => f.id == widget.initialFrame!.id);
      if (i >= 0) _mediaIndex = i;
    }
    _armTimer();
  }

  void _armTimer() {
    _timer?.cancel();
    if (_media.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() => _mediaIndex = (_mediaIndex + 1) % _media.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = FTheme.of(context);
    final size = MediaQuery.sizeOf(context);
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final parent = _parent;
    final title = (parent?.title?.trim().isNotEmpty ?? false)
        ? parent!.title!.trim()
        : l10n.balehoPlacementSheetTitle;
    final body = (parent?.body?.trim().isNotEmpty ?? false)
        ? parent!.body!.trim()
        : null;
    final openLabel = (parent?.ctaLabel?.trim().isNotEmpty ?? false)
        ? parent!.ctaLabel!.trim()
        : l10n.balehoPlacementOpen;
    final media = _media;
    final hasMedia = media.isNotEmpty;
    final currentMedia =
        hasMedia ? media[_mediaIndex % media.length] : null;
    final canOpen = (parent?.actionPayload.trim().isNotEmpty ?? false) &&
        !_placement.isOwnerPending;

    final info = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          softWrap: true,
          style: theme.typography.body.lg.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colors.foreground,
          ),
        ),
        if (body != null) ...[
          const Gap(4),
          Text(
            body,
            softWrap: true,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.foreground.withValues(alpha: 0.8),
            ),
          ),
        ],
        if (_placement.isOwnerPending) ...[
          const Gap(8),
          Text(
            l10n.balehoPlacementPendingHint,
            softWrap: true,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.foreground.withValues(alpha: 0.75),
            ),
          ),
        ],
        const Gap(16),
        if (canOpen)
          FButton(
            onPress: () => Navigator.pop(context, true),
            child: Text(openLabel),
          ),
        if (canOpen) const Gap(8),
        FButton(
          variant: FButtonVariant.outline,
          onPress: () => Navigator.pop(context, false),
          child: Text(l10n.commonClose),
        ),
      ],
    );

    final mediaPreview = hasMedia
        ? _SlotMediaPreview(
            url: currentMedia!.mediaUrl!,
            aspect: _slotAspect,
            maxHeight: size.height * (landscape ? 0.55 : 0.42),
            gridW: _placement.w,
            gridH: _placement.h,
            pageHint: media.length > 1
                ? '${_mediaIndex % media.length + 1}/${media.length}'
                : null,
          )
        : null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: size.height * (landscape ? 0.72 : 0.85),
          ),
          child: landscape && mediaPreview != null
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: mediaPreview),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 4,
                      child: SingleChildScrollView(child: info),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (mediaPreview != null) ...[
                        mediaPreview,
                        const Gap(12),
                      ],
                      info,
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

/// Preview media di skala sel papan.
class _SlotMediaPreview extends StatelessWidget {
  const _SlotMediaPreview({
    required this.url,
    required this.aspect,
    required this.maxHeight,
    required this.gridW,
    required this.gridH,
    this.pageHint,
  });

  final String url;
  final double aspect;
  final double maxHeight;
  final int gridW;
  final int gridH;
  final String? pageHint;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final cols = BalehoBoard.prototypeCols;
    final gw = gridW < 1 ? 1 : gridW;
    final gh = gridH < 1 ? 1 : gridH;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 32;
        var cell = maxW / cols;
        if (cell * gh > maxHeight && gh > 0) {
          cell = maxHeight / gh;
        }
        final width = cell * gw;
        final height = cell * gh;
        assert((width / height - aspect).abs() < 0.02);

        return Align(
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: width,
                    height: height,
                    errorBuilder: (_, _, _) => ColoredBox(
                      color: theme.colors.secondary,
                      child: Center(
                        child: Icon(
                          FLucideIcons.image,
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ),
                  ),
                  if (pageHint != null)
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colors.background.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Text(
                            pageHint!,
                            style: theme.typography.body.xs.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
