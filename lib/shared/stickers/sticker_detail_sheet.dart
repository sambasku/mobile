import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/auth/presentation/providers/auth_status_providers.dart';
import '../../l10n/app_localizations.dart';
import '../utils/error_bottom_sheet.dart';
import 'sticker_models.dart';
import 'sticker_providers.dart';
import 'sticker_view.dart';

enum _DetailSheetExit { none, login, send }

/// Bottom sheet detail stiker: preview besar + toggle favorit + opsional kirim.
/// Menggunakan pola pop-result lalu push untuk navigasi login (anti-freeze shell).
Future<void> showStickerDetailSheet(
  BuildContext context,
  CatalogSticker sticker, {
  VoidCallback? onSend,
}) async {
  final exit = await showModalBottomSheet<_DetailSheetExit>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) => _StickerDetailSheetBody(
      sticker: sticker,
      canSend: onSend != null,
    ),
  );
  if (!context.mounted || exit == null || exit == _DetailSheetExit.none) {
    return;
  }
  if (exit == _DetailSheetExit.login) {
    context.push('/login');
  } else if (exit == _DetailSheetExit.send) {
    onSend?.call();
  }
}

class _StickerDetailSheetBody extends ConsumerStatefulWidget {
  const _StickerDetailSheetBody({
    required this.sticker,
    required this.canSend,
  });

  final CatalogSticker sticker;
  final bool canSend;

  @override
  ConsumerState<_StickerDetailSheetBody> createState() =>
      _StickerDetailSheetBodyState();
}

class _StickerDetailSheetBodyState
    extends ConsumerState<_StickerDetailSheetBody> {
  var _handled = false;

  void _popWith(_DetailSheetExit result) {
    if (_handled) return;
    _handled = true;
    Navigator.of(context).pop(result);
  }

  Future<void> _onToggleFavorite() async {
    final auth = ref.read(authStatusProvider).value;
    if (auth?.isAuth != true) {
      _popWith(_DetailSheetExit.login);
      return;
    }
    final l10n = AppLocalizations.of(context);
    final res = await ref
        .read(stickerFavoritesProvider.notifier)
        .toggle(widget.sticker);
    if (!mounted) return;
    if (res.ok) {
      showFToast(
        context: context,
        title: Text(
          res.isFavorite
              ? l10n.stickerAddedToFavorites
              : l10n.stickerRemovedFromFavorites,
        ),
      );
      return;
    }
    if (res.errorCode == 'RATE_LIMITED') {
      showFToast(context: context, title: Text(l10n.commonRateLimited));
      return;
    }
    final msg = switch (res.errorCode) {
      'STICKER_FAVORITE_LIMIT_REACHED' => l10n.stickerFavoriteLimitReached,
      _ => l10n.stickerFavoriteActionFailed,
    };
    await showAppErrorSheet(context, message: msg);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final favState = ref.watch(stickerFavoritesProvider);
    final isFav = favState.contains(widget.sticker.id);
    final busy = favState.isBusy(widget.sticker.id);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: CatalogStickerView(
                sticker: widget.sticker,
                size: 160,
              ),
            ),
            const Gap(12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    widget.sticker.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.sticker.isCustom) ...[
                  const Gap(6),
                  FBadge(
                    variant: FBadgeVariant.secondary,
                    child: Text(l10n.stickerCustomBadge),
                  ),
                ],
              ],
            ),
            const Gap(16),
            SizedBox(
              width: double.infinity,
              child: FButton(
                variant: isFav ? FButtonVariant.secondary : FButtonVariant.primary,
                onPress: busy ? null : _onToggleFavorite,
                prefix: busy
                    ? const FCircularProgress()
                    : Icon(
                        FLucideIcons.star,
                        size: 18,
                      ),
                child: Text(
                  isFav
                      ? l10n.stickerRemoveFromFavorites
                      : l10n.stickerAddToFavorites,
                ),
              ),
            ),
            if (widget.canSend) ...[
              const Gap(8),
              SizedBox(
                width: double.infinity,
                child: FButton(
                  variant: FButtonVariant.outline,
                  onPress: () => _popWith(_DetailSheetExit.send),
                  prefix: const Icon(FLucideIcons.send, size: 16),
                  child: Text(l10n.stickerSendNow),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
