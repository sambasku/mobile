import 'package:material_ui/material_ui.dart' show Theme;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/widgets/public_account_name.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../domain/entities/analytics_activity_item.dart';
import '../providers/admin_analytics_providers.dart';

const _activityFeedLimit = 12;
const _activityRowHeight = 56.0;
const _activityBodyHeight = _activityFeedLimit * _activityRowHeight;

/// Feed campuran: vote, komentar, diskusi, search-miss tayang.
class AnalyticsActivityFeedSection extends ConsumerWidget {
  const AnalyticsActivityFeedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(analyticsActivityFeedProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.analyticsFeedTitle,
          style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.colors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: SizedBox(
              height: _activityBodyHeight,
              child: async.when(
                skipLoadingOnReload: true,
                loading: () => const _ActivityFeedSkeleton(),
                error: (_, _) => AnalyticsActivityErrorRetry(
                  message: l10n.analyticsFeedError,
                  onRetry: () => ref.invalidate(analyticsActivityFeedProvider),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        l10n.analyticsFeedEmpty,
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final item in items)
                        SizedBox(
                          key: ValueKey('${item.kind.name}-${item.id}'),
                          height: _activityRowHeight,
                          width: double.infinity,
                          child: _ActivityRow(item: item),
                        ),
                      if (items.length < _activityFeedLimit) const Spacer(),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});

  final AnalyticsActivityItem item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final dateLabel = formatRelativeCompact(DateTime.tryParse(item.createdAt));
    final canOpenProfile = isLinkablePublicUsername(item.actorUsername);
    final subtitle = item.subtitle?.trim();
    final trailingMeta = [
      if (dateLabel.isNotEmpty) dateLabel,
      if (subtitle != null && subtitle.isNotEmpty) subtitle,
    ].join(' · ');

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UserAvatar(name: item.actorLabel, imageUrl: item.avatarUrl, size: 28),
        const Gap(8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Flexible(
                    child: PublicAccountName(
                      label: item.actorLabel,
                      isVerifier: item.isVerifier,
                      onTap: canOpenProfile
                          ? () => UserProfileRouter.open(
                              context,
                              item.actorUsername!,
                            )
                          : null,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: canOpenProfile
                            ? theme.colors.primary
                            : theme.colors.foreground,
                      ),
                    ),
                  ),
                  if (trailingMeta.isNotEmpty) ...[
                    const Gap(6),
                    Text(
                      trailingMeta,
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.mutedForeground,
                        height: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                item.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.body.sm.copyWith(height: 1.2),
              ),
            ],
          ),
        ),
      ],
    );

    final path = item.navigatePath;
    if (path == null || path.isEmpty) return content;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push(path),
      child: content,
    );
  }
}

AnalyticsActivityItem _placeholderActivity(AppLocalizations l10n) =>
    AnalyticsActivityItem(
      kind: AnalyticsActivityKind.comment,
      id: 'skeleton',
      createdAt: '2026-09-21T00:00:00.000Z',
      actorLabel: 'Warga Sambas',
      body: 'aktivitas singkat satu baris',
      subtitle: l10n.adminAnalyticsSkeletonKata,
    );

class _ActivityFeedSkeleton extends StatelessWidget {
  const _ActivityFeedSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = context.theme.colors.muted;
    final placeholder = _placeholderActivity(AppLocalizations.of(context));
    PaintingEffect shimmerResolver(Brightness brightness) => ShimmerEffect(
      baseColor: isDark
          ? muted.withValues(alpha: 0.35)
          : const Color(0xFFE7E7EA),
      highlightColor: isDark
          ? muted.withValues(alpha: 0.55)
          : const Color(0xFFF4F4F5),
      duration: const Duration(milliseconds: 1500),
    );

    return SkeletonizerConfig(
      data: SkeletonizerConfigData(effectResolver: shimmerResolver),
      child: IgnorePointer(
        child: Skeletonizer(
          enabled: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _activityFeedLimit; i++)
                SizedBox(
                  height: _activityRowHeight,
                  width: double.infinity,
                  child: _ActivityRow(item: placeholder),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnalyticsActivityErrorRetry extends StatelessWidget {
  const AnalyticsActivityErrorRetry({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
        GestureDetector(
          onTap: onRetry,
          child: Text(
            l10n.commonRetry,
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
