import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../core/utils/format_number.dart';
import '../../../../l10n/app_localizations.dart';
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

class _HistoryList extends ConsumerWidget {
  const _HistoryList();

  String _statusLabel(AppLocalizations l10n, String status) => switch (status) {
    'pending_review' => l10n.balehoStatusPendingReview,
    'awaiting_payment' => l10n.balehoStatusAwaitingPayment,
    'live' => l10n.balehoStatusLive,
    'paused' => l10n.balehoStatusPaused,
    'rejected' => l10n.balehoStatusRejected,
    'cancelled' => l10n.balehoStatusCancelled,
    'expired' => l10n.balehoStatusExpired,
    _ => status,
  };

  bool _isEndingSoon(BalehoPlacementHistoryItem item) {
    if (item.status != 'live' || item.endsAt == null) return false;
    final now = DateTime.now();
    final until = now.add(const Duration(hours: 24));
    return item.endsAt!.isAfter(now) && !item.endsAt!.isAfter(until);
  }

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
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Gap(8),
            itemBuilder: (context, index) {
              final item = items[index];
              final title = (item.title?.trim().isNotEmpty ?? false)
                  ? item.title!.trim()
                  : l10n.balehoHistoryUntitled;
              final size = '${item.w}x${item.h}';
              final pos = l10n.balehoHistoryPosition(
                size,
                item.col + 1,
                item.row + 1,
              );
              final endingSoon = _isEndingSoon(item);
              final expired = item.status == 'expired';
              final subtitleLines = <String>[
                '${_statusLabel(l10n, item.status)} · $pos',
                formatDateTime(item.createdAt),
                if (endingSoon) l10n.balehoHistoryEndingSoonHint,
                if (expired) l10n.balehoHistoryRebookHint,
              ];
              // Listing mengikuti pola tile inbox notifikasi: identitas +
              // status satu baris, thumbnail di kanan, angka performa di detail.
              final thumb = item.mediaUrl != null && item.mediaUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.mediaUrl!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          FLucideIcons.image,
                          size: 20,
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    )
                  : null;
              return FTile(
                prefix: Icon(
                  FLucideIcons.layoutGrid,
                  size: 20,
                  color: theme.colors.primary,
                ),
                title: Text(title),
                subtitle: Text(subtitleLines.join(' · ')),
                suffix: expired
                    ? FButton(
                        variant: FButtonVariant.outline,
                        onPress: () => context.go('/baleho'),
                        child: Text(l10n.balehoHistoryRebookCta),
                      )
                    : thumb == null
                    ? const Icon(FLucideIcons.chevronRight)
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          thumb,
                          const Gap(8),
                          const Icon(FLucideIcons.chevronRight),
                        ],
                      ),
                onPress: () =>
                    context.push('${BalehoRouter.history.path}/${item.id}'),
              );
            },
          ),
        );
      },
    );
  }
}

/// Baris metrik padat: funnel + rasio + biaya. Tanpa CPM - pemilik
/// pesanan cukup lihat angka mentah dan biaya (quoted/CPC).
class BalehoPerfStats extends StatelessWidget {
  const BalehoPerfStats({super.key, required this.item});

  final BalehoPlacementHistoryItem item;

  String _pct(double v) =>
      v == v.roundToDouble() ? '${v.toInt()}' : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final muted = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
      height: 1.35,
    );
    final valueStyle = theme.typography.body.sm.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.2,
    );

    Widget cell(String label, String value) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: valueStyle),
            const Gap(2),
            Text(
              label,
              style: muted,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    final rateBits = <String>[
      if (item.impressions > 0)
        l10n.balehoHistoryStatCtr(_pct(item.ctrPercent)),
      if (item.taps > 0)
        l10n.balehoHistoryStatActionRate(_pct(item.actionRatePercent)),
      if (item.actions > 0)
        l10n.balehoHistoryStatSuccessRate(_pct(item.successRatePercent)),
    ];

    final costBits = <String>[
      if (item.quotedAmount != null)
        l10n.balehoHistoryStatQuoted(formatRibuan(item.quotedAmount!)),
      if (item.cpcIdr != null)
        l10n.balehoHistoryStatCpc(formatRibuan(item.cpcIdr!)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            cell(
              l10n.balehoHistoryStatImpressions,
              formatRibuan(item.impressions),
            ),
            cell(l10n.balehoHistoryStatTaps, formatRibuan(item.taps)),
            cell(l10n.balehoHistoryStatActions, formatRibuan(item.actions)),
          ],
        ),
        if (rateBits.isNotEmpty) ...[
          const Gap(4),
          Text(rateBits.join(' · '), style: muted),
        ],
        if (costBits.isNotEmpty) ...[
          const Gap(2),
          Text(costBits.join(' · '), style: muted),
        ],
      ],
    );
  }
}
