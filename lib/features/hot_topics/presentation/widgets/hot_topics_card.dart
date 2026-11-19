import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/format_number.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/hot_topics.dart';
import '../providers/hot_topics_providers.dart';

/// Kartu Trending di Home (G4): tab Dicari / Diusulkan / Dekati ambang.
/// Layout compact - chip tab `.xs`, baris padat, max 5 item.
class HotTopicsCard extends ConsumerStatefulWidget {
  const HotTopicsCard({super.key});

  @override
  ConsumerState<HotTopicsCard> createState() => _HotTopicsCardState();
}

class _HotTopicsCardState extends ConsumerState<HotTopicsCard> {
  static const _maxItems = 5;

  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(hotTopicsProvider);
    final bundle = async.asData?.value;

    if (async.isLoading && bundle == null) {
      return const _HotTopicsSkeleton();
    }
    if (bundle == null || bundle.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final tabs = [
      (l10n.hotTopicsTabSearched, bundle.searched),
      (l10n.hotTopicsTabProposed, bundle.proposed),
      (l10n.hotTopicsTabNearThreshold, bundle.nearThreshold),
    ];
    // Skip ke tab pertama yang punya item.
    final safeTab = () {
      if (tabs[_tab].$2.items.isNotEmpty) return _tab;
      for (var i = 0; i < tabs.length; i++) {
        if (tabs[i].$2.items.isNotEmpty) return i;
      }
      return 0;
    }();
    if (safeTab != _tab) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _tab = safeTab);
      });
    }

    final active = tabs[safeTab].$2;
    final items = active.items.take(_maxItems).toList(growable: false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.hotTopicsTitle,
            style: theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < tabs.length; i++)
                  if (tabs[i].$2.items.isNotEmpty) ...[
                    if (i > 0) const Gap(6),
                    FButton(
                      size: .xs,
                      mainAxisSize: MainAxisSize.min,
                      variant: safeTab == i
                          ? FButtonVariant.primary
                          : FButtonVariant.outline,
                      onPress: () => setState(() => _tab = i),
                      child: Text(tabs[i].$1),
                    ),
                  ],
              ],
            ),
          ),
          const Gap(4),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.hotTopicsTabEmpty,
                style: theme.typography.body.xs.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            )
          else
            Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    Container(
                      height: 0.5,
                      color: theme.colors.border.withValues(alpha: 0.45),
                    ),
                  _CompactRow(l10n: l10n, item: items[i]),
                ],
              ],
            ),
          if (active.meta.backfillUsed) ...[
            const Gap(2),
            Text(
              l10n.hotTopicsBackfillHint,
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompactRow extends StatelessWidget {
  const _CompactRow({required this.l10n, required this.item});

  final AppLocalizations l10n;
  final HotTopicItem item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final (:title, :meta, :onPress) = switch (item) {
      HotSearchedItem(
        :final id,
        :final term,
        :final direction,
        :final hitCount,
      ) =>
        (
          title: term,
          meta:
              '${direction == 'translation' ? l10n.dictLangIndonesia : l10n.dictLangSambas}'
              ' · ${l10n.searchMissHitCount(formatRibuan(hitCount))}',
          onPress: () {
            final q = Uri(
              queryParameters: {
                'lemma': term,
                'search_in': direction,
                'miss_id': id,
              },
            ).query;
            context.push('/contribute?$q');
          },
        ),
      HotProposedItem(:final wordId, :final lemma) => (
        title: lemma,
        meta: l10n.hotTopicsProposedSubtitle,
        onPress: () => context.push('/words/$wordId'),
      ),
      HotNearThresholdItem(
        :final wordId,
        :final meaningId,
        :final lemma,
        :final net,
        :final definitionPreview,
      ) =>
        (
          title: lemma,
          meta: definitionPreview == null || definitionPreview.isEmpty
              ? l10n.hotTopicsNearNet('$net')
              : '${l10n.hotTopicsNearNet('$net')} · $definitionPreview',
          onPress: () => context.push('/words/$wordId?meaning_id=$meaningId'),
        ),
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.xs.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              FLucideIcons.chevronRight,
              size: 16,
              color: theme.colors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}

class _HotTopicsSkeleton extends StatelessWidget {
  const _HotTopicsSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 12,
            width: 120,
            decoration: BoxDecoration(
              color: theme.colors.secondary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Gap(6),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: theme.colors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}
