import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/baleho_models.dart';

/// Preview placement sebelum aksi (in-app / eksternal).
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = FTheme.of(context);
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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasMedia) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    frame.mediaUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => ColoredBox(
                      color: theme.colors.secondary,
                      child: Icon(
                        FLucideIcons.image,
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(12),
            ],
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
        ),
      ),
    );
  }
}
