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
import '../../data/culinary_contribution_api.dart';
import '../../domain/entities/culinary_proposal.dart';
import '../culinary_labels.dart';
import '../providers/cuisine_providers.dart';

/// Status usulan kuliner milik akun yang sedang masuk.
///
/// Data dari `GET /api/v1/culinary/contributions/mine` (semua kind: usulan
/// baru, usul perbaikan, relasi, status buka, arsip).
class CulinaryProposalsPage extends ConsumerStatefulWidget {
  const CulinaryProposalsPage({super.key});

  @override
  ConsumerState<CulinaryProposalsPage> createState() =>
      _CulinaryProposalsPageState();
}

class _CulinaryProposalsPageState extends ConsumerState<CulinaryProposalsPage> {
  @override
  void initState() {
    super.initState();
    unawaited(AnalyticsService.instance.logUsulanKulinerOpen());
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final l10n = AppLocalizations.of(context);
    final authed = ref.watch(authStatusProvider).value?.isAuth == true;
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.culinaryProposalsTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go('/explore/cuisine'),
          ),
        ],
      ),
      child: !authed
          ? const _LoginGate()
          : ref
                .watch(culinaryProposalsProvider)
                .when(
                  loading: () =>
                      const Center(child: FCircularProgress(size: .sm)),
                  error: (err, _) => _ErrorBody(
                    onRetry: () => ref.invalidate(culinaryProposalsProvider),
                    message: err is CulinaryException
                        ? err.message
                        : l10n.culinaryProposalsLoadFailed,
                  ),
                  data: (items) {
                    if (items.isEmpty) return const _EmptyBody();
                    return RefreshIndicator(
                      onRefresh: () =>
                          ref.refresh(culinaryProposalsProvider.future),
                      child: TileGroupList<CulinaryProposal>(
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
    CulinaryProposal item,
  ) async {
    final l10n = AppLocalizations.of(context);
    // Path = hasil pop: hindari race pop lalu aksi di navigator yang sama.
    final ok = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: FTileGroup(
          children: [
            FTile(
              title: Text(l10n.culinaryProposalsCancelTitle),
              subtitle: Text(item.title),
            ),
            FTile(title: Text(l10n.culinaryProposalsCancelBody)),
            FTile(
              title: Text(l10n.culinaryCancelAction),
              suffix: FButton(
                variant: FButtonVariant.destructive,
                onPress: () => Navigator.pop(ctx, true),
                child: Text(l10n.culinaryCancelAction),
              ),
            ),
            FTile(
              title: Text(l10n.commonClose),
              onPress: () => Navigator.pop(ctx, false),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref
          .read(culinaryContributionApiProvider)
          .cancelContribution(item.id);
      ref.invalidate(culinaryProposalsProvider);
    } on CulinaryException catch (e) {
      if (!context.mounted) return;
      await showAppErrorSheet(
        context,
        title: l10n.culinaryProposalsCancelFailed,
        message: e.message,
      );
    }
  }
}

class _ProposalRow extends StatelessWidget {
  const _ProposalRow({required this.item, required this.onCancel});

  final CulinaryProposal item;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final pending = item.canCancel;
    final meta = [
      culinaryKindLabel(l10n, item.kind),
      formatDateShort(item.createdAt),
    ].where((s) => s.isNotEmpty).join(' · ');
    final note = item.status == 'needs_revision'
        ? item.revisionNote
        : item.status == 'rejected'
        ? culinaryRejectDisplay(
            l10n,
            code: item.rejectReasonCode,
            text: item.rejectReasonText,
          )
        : null;
    return FTile(
      prefix: Icon(
        FLucideIcons.utensilsCrossed,
        color: pending ? theme.colors.foreground : theme.colors.mutedForeground,
      ),
      title: Text(
        item.title.isEmpty ? l10n.culinaryProposalsTitle : item.title,
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
        note == null || note.trim().isEmpty ? meta : '$meta\n$note',
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      suffix: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FBadge(
            variant: _statusVariant(item.status),
            child: Text(culinaryStatusLabel(l10n, item.status)),
          ),
          if (item.canCancel) ...[
            const Gap(8),
            FButton(
              variant: FButtonVariant.outline,
              size: FButtonSizeVariant.sm,
              onPress: onCancel,
              child: Text(l10n.culinaryCancelAction),
            ),
          ],
        ],
      ),
    );
  }
}

FBadgeVariant _statusVariant(String status) => switch (status) {
  'approved' => FBadgeVariant.primary,
  'rejected' => FBadgeVariant.destructive,
  'needs_revision' => FBadgeVariant.secondary,
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
              FLucideIcons.utensilsCrossed,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              l10n.culinaryProposalsLoginGate,
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
            FLucideIcons.utensilsCrossed,
            size: 40,
            color: theme.colors.mutedForeground,
          ),
        ),
        const Gap(10),
        Text(
          l10n.culinaryProposalsEmpty,
          textAlign: TextAlign.center,
          style: theme.typography.body.md.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(4),
        Text(
          l10n.culinaryProposalsEmptyHint,
          textAlign: TextAlign.center,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        const Gap(16),
        Center(
          child: FButton(
            variant: FButtonVariant.outline,
            onPress: () => context.push('/explore/cuisine/usul'),
            child: Text(l10n.culinaryProposalsEmptyCta),
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
        title: AppLocalizations.of(context).culinaryProposalsLoadFailedTitle,
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
