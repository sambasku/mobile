import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../shared/utils/public_account_name.dart';
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
    final async = ref.watch(analyticsActivityFeedProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Aktivitas terbaru',
          style: theme.typography.sm.copyWith(fontWeight: FontWeight.w700),
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
                loading: () => const Center(child: FCircularProgress()),
                error: (_, _) => AnalyticsActivityErrorRetry(
                  message: 'Gagal memuat aktivitas.',
                  onRetry: () =>
                      ref.invalidate(analyticsActivityFeedProvider),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Belum ada aktivitas.',
                        style: theme.typography.xs.copyWith(
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
    final dateLabel = formatRelativeCompact(
      DateTime.tryParse(item.createdAt),
    );
    final canOpenProfile = isLinkablePublicUsername(item.actorUsername);
    final subtitle = item.subtitle?.trim();
    final trailingMeta = [
      if (dateLabel.isNotEmpty) dateLabel,
      if (subtitle != null && subtitle.isNotEmpty) subtitle,
    ].join(' · ');

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UserAvatar(
          name: item.actorLabel,
          imageUrl: item.avatarUrl,
          size: 28,
        ),
        const Gap(8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Flexible(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: canOpenProfile
                          ? () => UserProfileRouter.open(
                                context,
                                item.actorUsername!,
                              )
                          : null,
                      child: Text(
                        item.actorLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.sm.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: canOpenProfile
                              ? theme.colors.primary
                              : theme.colors.foreground,
                        ),
                      ),
                    ),
                  ),
                  if (trailingMeta.isNotEmpty) ...[
                    const Gap(6),
                    Text(
                      trailingMeta,
                      style: theme.typography.xs.copyWith(
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
                style: theme.typography.sm.copyWith(height: 1.2),
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
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: theme.typography.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
        GestureDetector(
          onTap: onRetry,
          child: Text(
            'Coba lagi',
            style: theme.typography.xs.copyWith(
              color: theme.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
