import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/baleho_models.dart';

/// Preview placement sebelum aksi (in-app / eksternal).
///
/// Rasio gambar = ukuran grid yang dipesan (`w:h`). Landscape: media + teks
/// berdampingan supaya sheet tidak menelan tinggi layar.
Future<bool?> showBalehoPlacementSheet(
  BuildContext context, {
  required BalehoPlacement placement,
  required BalehoFrame frame,
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
          frame: frame,
        ),
      );
    },
  );
}

class _BalehoPlacementSheetBody extends StatelessWidget {
  const _BalehoPlacementSheetBody({
    required this.placement,
    required this.frame,
  });

  final BalehoPlacement placement;
  final BalehoFrame frame;

  /// Sel papan kotak → rasio media = w/h slot.
  double get _slotAspect {
    final w = placement.w < 1 ? 1 : placement.w;
    final h = placement.h < 1 ? 1 : placement.h;
    return w / h;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = FTheme.of(context);
    final size = MediaQuery.sizeOf(context);
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final title = (frame.title?.trim().isNotEmpty ?? false)
        ? frame.title!.trim()
        : l10n.balehoPlacementSheetTitle;
    final subtitle = (frame.ctaLabel?.trim().isNotEmpty ?? false)
        ? frame.ctaLabel!.trim()
        : null;
    final openLabel = (frame.ctaLabel?.trim().isNotEmpty ?? false)
        ? frame.ctaLabel!.trim()
        : l10n.balehoPlacementOpen;
    final hasMedia = frame.mediaUrl != null &&
        frame.mediaUrl!.trim().isNotEmpty &&
        (frame.mediaType == 'image' || frame.mediaType == 'video');
    final canOpen = frame.actionPayload.trim().isNotEmpty &&
        !placement.isOwnerPending;

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
        if (subtitle != null) ...[
          const Gap(4),
          Text(
            subtitle,
            softWrap: true,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.foreground.withValues(alpha: 0.8),
            ),
          ),
        ],
        if (placement.isOwnerPending) ...[
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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: size.height * (landscape ? 0.72 : 0.85),
          ),
          child: landscape && hasMedia
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _SlotMediaPreview(
                        url: frame.mediaUrl!,
                        aspect: _slotAspect,
                        maxHeight: size.height * 0.55,
                      ),
                    ),
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
                      if (hasMedia) ...[
                        _SlotMediaPreview(
                          url: frame.mediaUrl!,
                          aspect: _slotAspect,
                          maxHeight: size.height * (landscape ? 0.4 : 0.42),
                        ),
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

/// Preview media dengan rasio slot, muat di dalam [maxHeight] × lebar parent.
class _SlotMediaPreview extends StatelessWidget {
  const _SlotMediaPreview({
    required this.url,
    required this.aspect,
    required this.maxHeight,
  });

  final String url;
  final double aspect;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 32;
        var width = maxW;
        var height = width / aspect;
        if (height > maxHeight) {
          height = maxHeight;
          width = height * aspect;
          if (width > maxW) {
            width = maxW;
            height = width / aspect;
          }
        }

        return Align(
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: width,
              height: height,
              child: Image.network(
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
            ),
          ),
        );
      },
    );
  }
}
