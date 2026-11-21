import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/baleho_api.dart';
import 'baleho_history_page.dart' show BalehoPerfStats, balehoHistoryProvider;

/// Detail performa satu pesanan Baleho (dari riwayat listing).
class BalehoHistoryDetailPage extends ConsumerWidget {
  const BalehoHistoryDetailPage({super.key, required this.placementId});

  final String placementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.balehoHistoryDetailTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/baleho'),
          ),
        ],
      ),
      child: ref
          .watch(balehoHistoryProvider)
          .when(
            skipLoadingOnReload: true,
            loading: () => const Center(child: FCircularProgress()),
            error: (_, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.balehoHistoryLoadFailed,
                    textAlign: TextAlign.center,
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
            data: (items) {
              final item = items.where((e) => e.id == placementId).firstOrNull;
              if (item == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.balehoHistoryDetailNotFound,
                      textAlign: TextAlign.center,
                      style: context.theme.typography.body.sm.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                );
              }
              return _DetailBody(item: item);
            },
          ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.item});

  final BalehoPlacementHistoryItem item;

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

  /// `3 hari 5 jam`: rentang mulai-berakhir, atau mulai-sekarang saat live.
  String _durationLabel(AppLocalizations l10n) {
    final end = item.endsAt ?? DateTime.now();
    var dur = end.difference(item.createdAt);
    if (dur.isNegative) dur = Duration.zero;
    final d = dur.inDays;
    final h = dur.inHours % 24;
    if (d == 0 && h == 0) return l10n.balehoDurationMinutes(dur.inMinutes);
    if (d == 0) return l10n.balehoDurationHours(h);
    if (h == 0) return l10n.balehoDurationDays(d);
    return l10n.balehoDurationDaysHours(d, h);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final muted = theme.colors.mutedForeground;
    final title = (item.title?.trim().isNotEmpty ?? false)
        ? item.title!.trim()
        : l10n.balehoHistoryUntitled;
    final size = '${item.w}x${item.h}';
    final slideLabel = item.slide == 1
        ? l10n.balehoPromoSlide
        : l10n.balehoInternalSlide;
    final endText = item.endsAt == null
        ? null
        : '${formatDateTime(item.endsAt)} · ${_durationLabel(l10n)}';

    FTile metaTile(String label, String value) => FTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 13,
          color: muted,
        ),
      ),
      details: Text(
        value,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: theme.colors.foreground,
        ),
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      children: [
        // Header ringkas: identitas pesanan dalam satu tile.
        FTileGroup(
          children: [
            FTile(
              prefix: item.mediaUrl != null && item.mediaUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.mediaUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            Icon(FLucideIcons.image, size: 20, color: muted),
                      ),
                    )
                  : Icon(FLucideIcons.layoutGrid, size: 20, color: muted),
              title: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(slideLabel),
            ),
          ],
        ),
        const Gap(12),
        // Detail pesanan: label kiri, nilai kanan, satu layar tanpa scroll
        // berlebih.
        FTileGroup(
          children: [
            metaTile(
              l10n.balehoHistoryDetailStatus,
              _statusLabel(l10n, item.status),
            ),
            metaTile(
              l10n.balehoHistoryDetailPosition,
              l10n.balehoHistoryPosition(size, item.col + 1, item.row + 1),
            ),
            metaTile(
              l10n.balehoHistoryDetailCreated,
              formatDateTime(item.createdAt),
            ),
            if (endText != null) metaTile(l10n.balehoHistoryDetailEnd, endText),
          ],
        ),
        const Gap(12),
        Text(
          l10n.balehoHistoryStatsTitle,
          style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(8),
        BalehoPerfStats(item: item),
      ],
    );
  }
}
