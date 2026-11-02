import 'dart:async';

import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/tile_group_list.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/entities/usaha.dart';
import '../../usaha_router.dart';
import '../providers/usaha_providers.dart';
import '../usaha_labels.dart';

/// Klaim pengelolaan milik user + statusnya.
class UsahaClaimsPage extends ConsumerStatefulWidget {
  const UsahaClaimsPage({super.key});

  @override
  ConsumerState<UsahaClaimsPage> createState() => _UsahaClaimsPageState();
}

class _UsahaClaimsPageState extends ConsumerState<UsahaClaimsPage> {
  @override
  void initState() {
    super.initState();
    unawaited(AnalyticsService.instance.logUsahaClaimsOpen());
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final l10n = AppLocalizations.of(context);
    final authed = ref.watch(authStatusProvider).value?.isAuth == true;
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.usahaClaimsTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go(UsahaRouter.list.path),
          ),
        ],
      ),
      child: !authed
          ? const _LoginGate()
          : ref
                .watch(usahaClaimsControllerProvider)
                .when(
                  loading: () =>
                      const Center(child: FCircularProgress(size: .sm)),
                  error: (err, _) => _ErrorBody(
                    onRetry: () =>
                        ref.invalidate(usahaClaimsControllerProvider),
                    message: err is UsahaException
                        ? err.message
                        : l10n.usahaClaimsLoadFailed,
                  ),
                  data: (items) {
                    if (items.isEmpty) return const _EmptyBody();
                    return RefreshIndicator(
                      onRefresh: () =>
                          ref.refresh(usahaClaimsControllerProvider.future),
                      child: TileGroupList<UsahaClaim>(
                        items: items,
                        hasMore: false,
                        onLoadMore: () async {},
                        tileBuilder: (ctx, item) => _ClaimRow(
                          item: item,
                          onCancel: () => _confirmCancel(ctx, ref, item),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    WidgetRef ref,
    UsahaClaim item,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: FTileGroup(
          children: [
            FTile(
              title: Text(l10n.usahaClaimCancelTitle),
              subtitle: Text(l10n.usahaClaimCancelBody),
              suffix: FButton(
                variant: FButtonVariant.destructive,
                onPress: () => Navigator.pop(ctx, true),
                child: Text(l10n.usahaCancelAction),
              ),
            ),
            FTile(
              title: Text(l10n.usahaLeaveForNow),
              suffix: FButton(
                variant: FButtonVariant.outline,
                onPress: () => Navigator.pop(ctx, false),
                child: Text(l10n.usahaNevermind),
              ),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(usahaClaimsControllerProvider.notifier).cancel(item.id);
    } on UsahaException catch (e) {
      if (!context.mounted) return;
      await showAppErrorSheet(
        context,
        message: e.message,
        title: l10n.usahaClaimCancelFailed,
      );
    }
  }
}

class _ClaimRow extends StatelessWidget {
  const _ClaimRow({required this.item, required this.onCancel});

  final UsahaClaim item;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final pending = item.status == UsahaClaimStatus.pending;
    final name = item.usahaName ?? l10n.usahaTitle;
    final note = item.status == UsahaClaimStatus.rejected
        ? usahaRejectDisplay(
            l10n,
            code: item.rejectReasonCode,
            text: item.rejectReasonText,
          )
        : null;
    final submittedAt = l10n.usahaSubmittedAt(formatDateShort(item.createdAt));

    return FTile(
      prefix: Icon(
        FLucideIcons.keyRound,
        color: pending ? theme.colors.foreground : theme.colors.mutedForeground,
      ),
      title: Text(
        name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: pending
              ? theme.colors.foreground
              : theme.colors.mutedForeground,
          fontWeight: pending ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      subtitle: Text(
        note == null ? submittedAt : '$submittedAt\n$note',
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      suffix: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FBadge(
            variant: _variant(item.status),
            child: Text(usahaClaimStatusLabel(l10n, item.status)),
          ),
          if (pending) ...[
            const Gap(8),
            FButton(
              variant: FButtonVariant.outline,
              size: FButtonSizeVariant.sm,
              onPress: onCancel,
              child: Text(l10n.usahaCancelAction),
            ),
          ],
        ],
      ),
    );
  }

  static FBadgeVariant _variant(UsahaClaimStatus status) => switch (status) {
    UsahaClaimStatus.approved => FBadgeVariant.primary,
    UsahaClaimStatus.rejected => FBadgeVariant.destructive,
    UsahaClaimStatus.cancelled => FBadgeVariant.outline,
    UsahaClaimStatus.pending => FBadgeVariant.secondary,
  };
}

class _LoginGate extends StatelessWidget {
  const _LoginGate();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FLucideIcons.keyRound,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              l10n.usahaClaimsLoginGate,
              style: theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => context.push('/login'),
              child: Text(l10n.authLoginAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const Gap(48),
        Center(
          child: Icon(
            FLucideIcons.shieldCheck,
            size: 40,
            color: theme.colors.mutedForeground,
          ),
        ),
        const Gap(10),
        Text(
          l10n.usahaClaimsEmpty,
          textAlign: TextAlign.center,
          style: theme.typography.body.md.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(4),
        Text(
          l10n.usahaClaimsEmptyHint,
          textAlign: TextAlign.center,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

class _ErrorBody extends StatefulWidget {
  const _ErrorBody({required this.onRetry, required this.message});

  final VoidCallback onRetry;
  final String message;

  @override
  State<_ErrorBody> createState() => _ErrorBodyState();
}

class _ErrorBodyState extends State<_ErrorBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showAppErrorSheet(
        context,
        message: widget.message,
        title: AppLocalizations.of(context).usahaClaimsLoadFailedTitle,
        onRetry: widget.onRetry,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => widget.onRetry(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [SizedBox(height: 240)],
      ),
    );
  }
}
