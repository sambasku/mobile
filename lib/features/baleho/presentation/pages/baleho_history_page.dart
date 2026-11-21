import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../core/utils/format_number.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/tile_group_list.dart';
import '../../../auth/auth_router.dart';
import '../../baleho_router.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/baleho_api.dart';
import '../providers/baleho_board_provider.dart';

/// Riwayat pesanan Baleho milik user login.
class BalehoHistoryPage extends ConsumerWidget {
  const BalehoHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authStatusProvider);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.balehoHistoryTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/baleho'),
          ),
        ],
      ),
      child: auth.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (_, _) => _GuestBody(
          message: l10n.balehoHistoryLoginRequired,
          onLogin: () => context.push(AuthRouter.login.path),
          loginLabel: l10n.commonLoginRequiredShort,
        ),
        data: (status) => status.isAuth
            ? const _HistoryList()
            : _GuestBody(
                message: l10n.balehoHistoryLoginRequired,
                onLogin: () => context.push(AuthRouter.login.path),
                loginLabel: l10n.commonLoginRequiredShort,
              ),
      ),
    );
  }
}

class _GuestBody extends StatelessWidget {
  const _GuestBody({
    required this.message,
    required this.onLogin,
    required this.loginLabel,
  });

  final String message;
  final VoidCallback onLogin;
  final String loginLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FLucideIcons.history,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              message,
              style: theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            FButton(
              variant: FButtonVariant.outline,
              onPress: onLogin,
              child: Text(loginLabel),
            ),
          ],
        ),
      ),
    );
  }
}

final balehoHistoryProvider =
    FutureProvider.autoDispose<List<BalehoPlacementHistoryItem>>((ref) {
      return ref.watch(balehoApiProvider).listMyPlacements();
    });

String _balehoStatusLabel(AppLocalizations l10n, String status) =>
    switch (status) {
      'pending_review' => l10n.balehoStatusPendingReview,
      'awaiting_payment' => l10n.balehoStatusAwaitingPayment,
      'live' => l10n.balehoStatusLive,
      'paused' => l10n.balehoStatusPaused,
      'rejected' => l10n.balehoStatusRejected,
      'cancelled' => l10n.balehoStatusCancelled,
      'expired' => l10n.balehoStatusExpired,
      _ => status,
    };

bool _balehoIsEndingSoon(BalehoPlacementHistoryItem item) {
  if (item.status != 'live' || item.endsAt == null) return false;
  final now = DateTime.now();
  final until = now.add(const Duration(hours: 24));
  return item.endsAt!.isAfter(now) && !item.endsAt!.isAfter(until);
}

class _HistoryList extends ConsumerWidget {
  const _HistoryList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final async = ref.watch(balehoHistoryProvider);

    Future<void> refresh() async {
      ref.invalidate(balehoHistoryProvider);
      await ref.read(balehoHistoryProvider.future);
    }

    return async.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: FCircularProgress()),
      error: (_, _) => RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.balehoHistoryLoadFailed,
                    textAlign: TextAlign.center,
                    style: theme.typography.body.sm,
                  ),
                  const Gap(12),
                  FButton(
                    variant: FButtonVariant.outline,
                    onPress: () => ref.invalidate(balehoHistoryProvider),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.balehoHistoryEmpty,
                    textAlign: TextAlign.center,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: refresh,
          child: TileGroupList<BalehoPlacementHistoryItem>(
            items: items,
            hasMore: false,
            onLoadMore: () async {},
            tileBuilder: (context, item) => _BalehoHistoryTile(item: item),
          ),
        );
      },
    );
  }
}

class _BalehoHistoryTile extends StatelessWidget with FTileMixin {
  const _BalehoHistoryTile({required this.item});

  final BalehoPlacementHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final title = (item.title?.trim().isNotEmpty ?? false)
        ? item.title!.trim()
        : l10n.balehoHistoryUntitled;
    final size = '${item.w}x${item.h}';
    final pos = l10n.balehoHistoryPosition(size, item.col + 1, item.row + 1);
    final endingSoon = _balehoIsEndingSoon(item);
    final expired = item.status == 'expired';
    final rawImage = item.mediaUrl?.trim();
    final thumbUrl = displayImageUrl(rawImage, width: 96, height: 96);

    return FTile(
      title: Text(title),
      subtitle: Text(
        [
          _balehoStatusLabel(l10n, item.status),
          pos,
          formatDateTime(item.createdAt),
          if (endingSoon) l10n.balehoHistoryEndingSoonHint,
          if (expired) l10n.balehoHistoryRebookHint,
        ].join(' · '),
      ),
      prefix: Icon(
        FLucideIcons.layoutGrid,
        color: theme.colors.mutedForeground,
      ),
      suffix: thumbUrl == null
          ? const Icon(FLucideIcons.chevronRight)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  button: true,
                  label: l10n.notificationViewImage,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: rawImage == null || rawImage.isEmpty
                        ? null
                        : () => showImagePreview(context, urls: [rawImage]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CachedNetworkImageWithFallback(
                          imageUrl: thumbUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const Gap(8),
                const Icon(FLucideIcons.chevronRight),
              ],
            ),
      onPress: () =>
          context.push('${BalehoRouter.history.path}/${item.id}'),
    );
  }
}

/// Ringkasan biaya pesanan (quoted/CPC). Metrik funnel/CTR ditunda ke versi
/// berikutnya.
class BalehoPerfStats extends StatelessWidget {
  const BalehoPerfStats({super.key, required this.item});

  final BalehoPlacementHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
      height: 1.35,
    );

    final costBits = <String>[
      if (item.quotedAmount != null)
        l10n.balehoHistoryStatQuoted(formatRibuan(item.quotedAmount!)),
      if (item.cpcIdr != null)
        l10n.balehoHistoryStatCpc(formatRibuan(item.cpcIdr!)),
    ];

    if (costBits.isEmpty) {
      return Text(l10n.balehoHistoryCostEmpty, style: muted);
    }

    return Text(costBits.join(' · '), style: muted);
  }
}
