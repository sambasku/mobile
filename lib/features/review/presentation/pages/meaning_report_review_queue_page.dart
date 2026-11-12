import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/format_datetime.dart' show formatDateTimeIso;
import '../../../../shared/widgets/tile_group_list.dart';
import '../../data/repositories/meaning_report_review_repository_impl.dart';
import '../../review_router.dart';
import '../providers/meaning_report_review_providers.dart';

class MeaningReportReviewQueuePage extends ConsumerWidget {
  const MeaningReportReviewQueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final async = ref.watch(meaningReportReviewListProvider);
    final l10n = AppLocalizations.of(context);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.reviewMeaningReportQueueTitle),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: async.when(
        loading: () {
          final viewportHeight = MediaQuery.sizeOf(context).height;
          final skeletonPerPage = (viewportHeight ~/ 80) + 2;
              return Skeletonizer(
            enabled: true,
            child: ListView.builder(
              itemCount: skeletonPerPage,
              itemBuilder: (_, _) => FTile(
                title: const Text('lemma skeleton'),
                subtitle: const Text('definisi skeleton'),
              ),
            ),
          );
        },
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                error is MeaningReportReviewFailure
                    ? error.message
                    : l10n.reviewMeaningReportQueueLoadFailed,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(12),
              FButton(
                variant: FButtonVariant.outline,
                onPress: () => ref.invalidate(meaningReportReviewListProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (state) => _QueueList(state: state),
      ),
    );
  }
}

class _QueueList extends ConsumerWidget {
  const _QueueList({required this.state});

  final MeaningReportReviewListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);

    Future<void> refresh() async {
      ref.invalidate(meaningReportReviewListProvider);
      await ref.read(meaningReportReviewListProvider.future);
    }

    if (state.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: refresh,
        child: LayoutBuilder(
          builder: (context, constraints) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: constraints.maxHeight,
                child: Center(
                  child: Text(
                    l10n.reviewMeaningReportQueueEmpty,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: TileGroupList<MeaningReportReviewItem>(
        items: state.items,
        hasMore: state.hasMore,
        onLoadMore: () =>
            ref.read(meaningReportReviewListProvider.notifier).loadMore(),
        tileBuilder: (context, item) => FTile(
          title: Text(item.lemma),
          subtitle: Text(
            [
              if (item.meaningDefinition != null &&
                  item.meaningDefinition!.trim().isNotEmpty)
                item.meaningDefinition!.trim(),
              if (item.createdAt.isNotEmpty)
                formatDateTimeIso(item.createdAt),
            ].whereType<String>().where((e) => e.isNotEmpty).join(' · '),
          ),
          suffix: const Icon(FLucideIcons.chevronRight),
          onPress: () => context.push(
            ReviewRouter.meaningReportDetailPath(item.id),
          ),
        ),
      ),
    );
  }
}
