import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/format_number.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/hot_topics.dart';
import '../providers/hot_topics_providers.dart';

/// Kartu Sorotan di Home (G4): tab Dicari / Diusulkan / Dekati ambang.
/// Layout padat - pill [FBadge], baris 1 baris, max 3 item (hemat ruang home).
class HotTopicsCard extends ConsumerStatefulWidget {
  const HotTopicsCard({super.key});

  @override
  ConsumerState<HotTopicsCard> createState() => _HotTopicsCardState();
}

class _HotTopicsCardState extends ConsumerState<HotTopicsCard> {
  static const _maxItems = 3;

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

    // Pill sejajar chip "Aktivitas terbaru": ListView full-bleed + padding
    // 12 (bukan Padding luar + Row). Gap hanya antar tab yang tampil -
    // jangan pakai index asli (tab kosong di kiri = pill pertama menjorok).
    final visibleTabs = <({int index, String label})>[
      for (var i = 0; i < tabs.length; i++)
        if (tabs[i].$2.items.isNotEmpty) (index: i, label: tabs[i].$1),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.hotTopicsTitle,
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (active.meta.backfillUsed)
                Text(
                  l10n.hotTopicsBackfillHint,
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),
        const Gap(4),
        SizedBox(
          height: 28,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            itemCount: visibleTabs.length,
            separatorBuilder: (_, _) => const Gap(4),
            itemBuilder: (context, i) {
              final tab = visibleTabs[i];
              final selected = safeTab == tab.index;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _tab = tab.index),
                child: FBadge(
                  variant: selected
                      ? FBadgeVariant.primary
                      : FBadgeVariant.secondary,
                  child: Text(tab.label),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 2, 12, 2),
          child: items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    l10n.hotTopicsTabEmpty,
                    style: theme.typography.body.xs.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0)
                        Container(
                          height: 0.5,
                          color: theme.colors.border.withValues(alpha: 0.4),
                        ),
                      _CompactRow(l10n: l10n, item: items[i]),
                    ],
                  ],
                ),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: title,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: ' · $meta',
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              FLucideIcons.chevronRight,
              size: 14,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
          child: Container(
            height: 12,
            width: 120,
            decoration: BoxDecoration(
              color: theme.colors.secondary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const Gap(4),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 2),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: theme.colors.secondary,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }
}
