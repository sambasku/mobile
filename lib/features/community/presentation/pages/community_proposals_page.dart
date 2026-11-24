import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/tile_group_list.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../explore/explore_router.dart';
import '../../data/community_api.dart';
import '../../domain/community_org.dart';
import '../providers/community_providers.dart';

/// Status usulan komunitas milik akun yang sedang masuk.
class CommunityProposalsPage extends ConsumerWidget {
  const CommunityProposalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final authed = ref.watch(authStatusProvider).value?.isAuth == true;

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.communityProposalsTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go('/explore/komunitas'),
          ),
        ],
      ),
      child: !authed
          ? const _LoginGate()
          : ref
                .watch(communityMineControllerProvider)
                .when(
                  loading: () =>
                      const Center(child: FCircularProgress(size: .sm)),
                  error: (err, _) => _ErrorBody(
                    message: err is CommunityException
                        ? err.message
                        : l10n.communityProposalsLoadFailed,
                    onRetry: () =>
                        ref.invalidate(communityMineControllerProvider),
                  ),
                  data: (items) {
                    if (items.isEmpty) return const _EmptyBody();
                    return RefreshIndicator(
                      onRefresh: () =>
                          ref.refresh(communityMineControllerProvider.future),
                      child: TileGroupList<CommunityProposal>(
                        items: items,
                        hasMore: false,
                        onLoadMore: () async {},
                        tileBuilder: (ctx, item) => _ProposalRow(
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
    CommunityProposal item,
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
              title: Text(l10n.communityProposalCancelTitle),
              subtitle: Text(l10n.communityProposalCancelBody),
              suffix: FButton(
                variant: FButtonVariant.destructive,
                onPress: () => Navigator.pop(ctx, true),
                child: Text(l10n.communityProposalCancelAction),
              ),
            ),
            FTile(
              title: Text(l10n.communityProposalCancelKeepTitle),
              suffix: FButton(
                variant: FButtonVariant.outline,
                onPress: () => Navigator.pop(ctx, false),
                child: Text(l10n.communityProposalCancelKeepAction),
              ),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(communityMineControllerProvider.notifier).cancel(item.id);
    } on CommunityException catch (e) {
      if (!context.mounted) return;
      await showAppErrorSheet(
        context,
        title: l10n.communityProposalCancelFailed,
        message: e.message,
      );
    }
  }
}

class _ProposalRow extends StatelessWidget {
  const _ProposalRow({required this.item, required this.onCancel});

  final CommunityProposal item;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final pending = item.status == 'pending';
    final meta = _createdAtLabel(item.createdAt);
    final note = item.status == 'rejected' ? item.reviewNote : null;

    return FTile(
      prefix: Icon(
        FLucideIcons.users,
        color: pending ? theme.colors.foreground : theme.colors.mutedForeground,
      ),
      title: Text(
        item.name.isEmpty ? l10n.communityProposalsTitle : item.name,
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
        note == null || note.isEmpty ? meta : '$meta\n$note',
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      suffix: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FBadge(
            variant: _statusVariant(item.status),
            child: Text(_statusLabel(l10n, item.status)),
          ),
          if (item.canCancel) ...[
            const Gap(8),
            FButton(
              variant: FButtonVariant.outline,
              size: FButtonSizeVariant.sm,
              onPress: onCancel,
              child: Text(l10n.communityProposalCancelAction),
            ),
          ],
        ],
      ),
    );
  }
}

String _createdAtLabel(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  final local = parsed.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
}

String _statusLabel(AppLocalizations l10n, String status) => switch (status) {
  'approved' => l10n.communityProposalStatusApproved,
  'rejected' => l10n.communityProposalStatusRejected,
  'cancelled' => l10n.communityProposalStatusCancelled,
  _ => l10n.communityProposalStatusPending,
};

FBadgeVariant _statusVariant(String status) => switch (status) {
  'approved' => FBadgeVariant.primary,
  'rejected' => FBadgeVariant.destructive,
  'cancelled' => FBadgeVariant.secondary,
  _ => FBadgeVariant.outline,
};

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
              FLucideIcons.users,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              l10n.communityProposalsLoginGate,
              style: theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => context.push('/login'),
              child: Text(l10n.commonLoginRequiredShort),
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
            FLucideIcons.clipboardList,
            size: 40,
            color: theme.colors.mutedForeground,
          ),
        ),
        const Gap(10),
        Text(
          l10n.communityProposalsEmpty,
          textAlign: TextAlign.center,
          style: theme.typography.body.md.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(4),
        Text(
          l10n.communityProposalsEmptyHint,
          textAlign: TextAlign.center,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        const Gap(16),
        Center(
          child: FButton(
            variant: FButtonVariant.outline,
            onPress: () => context.push(ExploreRouter.communityContribute.path),
            child: Text(l10n.communityProposalsEmptyCta),
          ),
        ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FLucideIcons.triangleAlert,
              size: 40,
              color: theme.colors.destructive,
            ),
            const Gap(10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.typography.body.md,
            ),
            const Gap(16),
            FButton(
              variant: FButtonVariant.outline,
              onPress: onRetry,
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
