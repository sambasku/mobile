import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/format_number.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/hot_topics.dart';
import '../providers/hot_topics_providers.dart';

/// Kartu Hot di Home (G4): tab Dicari / Diusulkan / Dekati ambang.
class HotTopicsCard extends ConsumerStatefulWidget {
  const HotTopicsCard({super.key});

  @override
  ConsumerState<HotTopicsCard> createState() => _HotTopicsCardState();
}

class _HotTopicsCardState extends ConsumerState<HotTopicsCard> {
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.hotTopicsTitle,
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < tabs.length; i++)
                if (tabs[i].$2.items.isNotEmpty)
                  FButton(
                    variant: safeTab == i
                        ? FButtonVariant.primary
                        : FButtonVariant.outline,
                    onPress: () => setState(() => _tab = i),
                    child: Text(tabs[i].$1),
                  ),
            ],
          ),
          const Gap(8),
          if (active.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                l10n.hotTopicsTabEmpty,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            )
          else
            FTileGroup(
              children: [
                for (final item in active.items) _tile(context, l10n, item),
              ],
            ),
          if (active.meta.backfillUsed) ...[
            const Gap(4),
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

  FTile _tile(BuildContext context, AppLocalizations l10n, HotTopicItem item) {
    return switch (item) {
      HotSearchedItem(:final id, :final term, :final direction, :final hitCount) =>
        FTile(
          title: Text(term),
          subtitle: Text(
            '${direction == 'translation' ? l10n.dictLangIndonesia : l10n.dictLangSambas}'
            ' · ${l10n.searchMissHitCount(formatRibuan(hitCount))}',
          ),
          suffix: const Icon(FLucideIcons.chevronRight),
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
      HotProposedItem(:final wordId, :final lemma) => FTile(
          title: Text(lemma),
          subtitle: Text(l10n.hotTopicsProposedSubtitle),
          suffix: const Icon(FLucideIcons.chevronRight),
          onPress: () => context.push('/words/$wordId'),
        ),
      HotNearThresholdItem(
        :final wordId,
        :final meaningId,
        :final lemma,
        :final net,
        :final definitionPreview,
      ) =>
        FTile(
          title: Text(lemma),
          subtitle: Text(
            definitionPreview == null || definitionPreview.isEmpty
                ? l10n.hotTopicsNearNet('$net')
                : '${l10n.hotTopicsNearNet('$net')} · $definitionPreview',
          ),
          suffix: const Icon(FLucideIcons.chevronRight),
          onPress: () => context.push('/words/$wordId?meaning_id=$meaningId'),
        ),
    };
  }
}

class _HotTopicsSkeleton extends StatelessWidget {
  const _HotTopicsSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 14,
            width: 72,
            decoration: BoxDecoration(
              color: theme.colors.secondary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Gap(8),
          Container(
            height: 72,
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
