import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/encyclopedia.entity.dart';
import '../../encyclopedia_router.dart';
import '../providers/encyclopedia_contribution_providers.dart';
import '../utils/encyclopedia_auth.dart';
import '../utils/encyclopedia_back.dart';

class EncyclopediaMyContributionsPage extends ConsumerStatefulWidget {
  const EncyclopediaMyContributionsPage({super.key});

  @override
  ConsumerState<EncyclopediaMyContributionsPage> createState() =>
      _EncyclopediaMyContributionsPageState();
}

class _EncyclopediaMyContributionsPageState
    extends ConsumerState<EncyclopediaMyContributionsPage> {
  bool _authChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureAuth());
  }

  Future<void> _ensureAuth() async {
    if (!mounted || _authChecked) return;
    _authChecked = true;
    final l10n = AppLocalizations.of(context);
    final ok = await ensureEncyclopediaAuth(
      context,
      ref,
      body: l10n.encyclopediaLoginMyContributionsBody,
    );
    if (!ok && mounted) {
      encyclopediaPopOrGoExplore(context);
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(myEncyclopediaContributionsProvider);
    await ref.read(myEncyclopediaContributionsProvider.future);
  }

  void _openEdit(MyContributionItem item) {
    if (!item.canEdit) return;
    context.push(
      '${EncyclopediaRouter.contribute.path}?contribution_id=${item.id}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final contributionsAsync = ref.watch(myEncyclopediaContributionsProvider);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.encyclopediaMyContributionsTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () => encyclopediaPopOrGoExplore(context),
          ),
        ],
      ),
      child: contributionsAsync.when(
        loading: () => const Center(child: FCircularProgress(size: .sm)),
        error: (_, _) => _ErrorState(
          title: l10n.encyclopediaLoadFailed,
          retry: () => ref.invalidate(myEncyclopediaContributionsProvider),
          retryLabel: l10n.encyclopediaRetry,
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text(
                l10n.encyclopediaMyContributionsEmpty,
                textAlign: TextAlign.center,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            );
          }
          // Horizontal dari childPad - jangan dobel padding ListView.
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
              children: [
                FTileGroup(
                  children: [
                    for (final item in items)
                      _contributionTile(
                        context,
                        item: item,
                        onPress: item.canEdit ? () => _openEdit(item) : null,
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

FTile _contributionTile(
  BuildContext context, {
  required MyContributionItem item,
  VoidCallback? onPress,
}) {
  final l10n = AppLocalizations.of(context);
  final theme = context.theme;
  final editable = item.canEdit;
  final title = item.displayTitle.isNotEmpty
      ? item.displayTitle
      : (item.kind == 'new'
            ? l10n.encyclopediaProposalKindNew
            : l10n.encyclopediaProposalKindEdit);
  final kindLabel = item.kind == 'new'
      ? l10n.encyclopediaProposalKindNew
      : l10n.encyclopediaProposalKindEdit;
  final note = switch (item.status) {
    'rejected' => item.rejectReasonText,
    'needs_revision' => item.revisionNote,
    _ => null,
  };
  final subtitle = note == null || note.isEmpty ? kindLabel : '$kindLabel\n$note';

  return FTile(
    title: Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: editable
            ? theme.colors.foreground
            : theme.colors.mutedForeground,
        fontWeight: editable ? FontWeight.w600 : FontWeight.w400,
      ),
    ),
    subtitle: Text(
      subtitle,
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
        if (editable) ...[
          const Gap(8),
          Icon(
            FLucideIcons.chevronRight,
            color: theme.colors.mutedForeground,
          ),
        ],
      ],
    ),
    onPress: onPress,
  );
}

FBadgeVariant _statusVariant(String status) => switch (status) {
  'approved' => FBadgeVariant.primary,
  'rejected' => FBadgeVariant.destructive,
  'needs_revision' => FBadgeVariant.secondary,
  _ => FBadgeVariant.outline,
};

String _statusLabel(AppLocalizations l10n, String status) => switch (status) {
  'approved' => l10n.encyclopediaStatusApproved,
  'rejected' => l10n.encyclopediaStatusRejected,
  'needs_revision' => l10n.encyclopediaStatusNeedsRevision,
  _ => l10n.encyclopediaStatusPending,
};

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.title,
    required this.retry,
    required this.retryLabel,
  });
  final String title;
  final VoidCallback retry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, textAlign: TextAlign.center),
          const Gap(12),
          FButton(onPress: retry, child: Text(retryLabel)),
        ],
      ),
    );
  }
}
