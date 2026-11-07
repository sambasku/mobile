import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../l10n/app_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final contributionsAsync = ref.watch(myEncyclopediaContributionsProvider);

    return FScaffold(
      header: FHeader.nested(
        title: Text(l10n.encyclopediaMyContributionsTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () => encyclopediaPopOrGoExplore(context),
          ),
        ],
      ),
      child: contributionsAsync.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (_, _) => _ErrorState(
          title: l10n.encyclopediaLoadFailed,
          retry: () => ref.invalidate(myEncyclopediaContributionsProvider),
          retryLabel: l10n.encyclopediaRetry,
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.encyclopediaMyContributionsEmpty,
                  textAlign: TextAlign.center,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Gap(12),
            itemBuilder: (context, index) {
              final c = items[index];
              final statusColor = switch (c.status) {
                'approved' => theme.colors.primary,
                'rejected' => theme.colors.destructive,
                _ => theme.colors.secondary,
              };
              final statusTextColor = switch (c.status) {
                'approved' => theme.colors.primaryForeground,
                'rejected' => theme.colors.destructiveForeground,
                _ => theme.colors.foreground,
              };
              final statusLabel = switch (c.status) {
                'approved' => l10n.encyclopediaStatusApproved,
                'rejected' => l10n.encyclopediaStatusRejected,
                _ => l10n.encyclopediaStatusPending,
              };
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colors.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            c.article?['title'] as String? ??
                                (c.kind == 'new'
                                    ? l10n.encyclopediaProposalKindNew
                                    : l10n.encyclopediaProposalKindEdit),
                            style: theme.typography.body.md.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusLabel,
                            style: theme.typography.body.xs.copyWith(
                              color: statusTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (c.rejectReasonText != null &&
                        c.rejectReasonText!.isNotEmpty) ...[
                      const Gap(8),
                      Text(
                        c.rejectReasonText!,
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.destructive,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, textAlign: TextAlign.center),
            const Gap(12),
            FButton(onPress: retry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}
