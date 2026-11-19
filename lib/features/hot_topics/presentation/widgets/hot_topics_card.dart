import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/format_number.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/hot_topics.dart';
import '../providers/hot_topics_providers.dart';

/// Kartu Sorotan di Home: tab Hits / Usulan / Dicari.
/// Tinggi list tetap 10 slot supaya kontainer tidak loncat saat ganti tab.
class HotTopicsCard extends ConsumerStatefulWidget {
  const HotTopicsCard({super.key});

  @override
  ConsumerState<HotTopicsCard> createState() => _HotTopicsCardState();
}

class _HotTopicsCardState extends ConsumerState<HotTopicsCard> {
  static const _slotCount = 10;
  static const _columnCount = 2;
  /// Judul + subtitle + badge + chevron; row rapat supaya container compact.
  static const _cellHeight = 36.0;
  static const _rowGap = 1.0;
  static const _colGap = 8.0;

  static int get _rowCount => (_slotCount / _columnCount).ceil();

  static double get _listHeight =>
      _rowCount * _cellHeight + (_rowCount - 1) * _rowGap;

  /// Urutan kolom-mayor: kiri 1-5, kanan 6-10. Slot tanpa data = item null.
  static List<List<({int rank, HotTopicItem? item})>> _columnMajorChunks(
    List<HotTopicItem> items,
  ) {
    // Selalu 5 baris × 2 kolom; sisa diisi placeholder rank + "-".
    const perCol = 5; // == _rowCount
    assert(perCol == _rowCount);
    return List.generate(_columnCount, (col) {
      return [
        for (var r = 0; r < perCol; r++)
          (
            rank: col * perCol + r + 1,
            item: col * perCol + r < items.length
                ? items[col * perCol + r]
                : null,
          ),
      ];
    });
  }

  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(hotTopicsProvider);
    final bundle = async.asData?.value;

    if (async.isLoading && bundle == null) {
      return const _HotTopicsSkeleton();
    }
    // Error / belum ada data sama sekali: gagal senyap, jangan block feed.
    if (bundle == null) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final tabs = [
      (
        label: l10n.hotTopicsTabNearThreshold,
        tab: bundle.viewed,
        emptyIcon: FLucideIcons.chartNoAxesColumn,
        emptyBody: l10n.hotTopicsTabEmptyNearBody,
      ),
      (
        label: l10n.hotTopicsTabProposed,
        tab: bundle.proposed,
        emptyIcon: FLucideIcons.inbox,
        emptyBody: l10n.hotTopicsTabEmptyProposedBody,
      ),
      (
        label: l10n.hotTopicsTabSearched,
        tab: bundle.searched,
        emptyIcon: FLucideIcons.searchX,
        emptyBody: l10n.hotTopicsTabEmptySearchedBody,
      ),
    ];
    final safeTab = _tab.clamp(0, tabs.length - 1);
    final active = tabs[safeTab];
    final items = active.tab.items.take(_slotCount).toList(growable: false);
    final columns = items.isEmpty
        ? const <List<({int rank, HotTopicItem? item})>>[]
        : _columnMajorChunks(items);

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
              if (active.tab.meta.backfillUsed)
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
            itemCount: tabs.length,
            separatorBuilder: (_, _) => const Gap(4),
            itemBuilder: (context, i) {
              final selected = safeTab == i;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _tab = i),
                child: FBadge(
                  variant: selected
                      ? FBadgeVariant.primary
                      : FBadgeVariant.secondary,
                  child: Text(tabs[i].label),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: SizedBox(
            height: _listHeight,
            child: items.isEmpty
                ? _HotTopicsEmpty(
                    icon: active.emptyIcon,
                    title: l10n.hotTopicsTabEmpty,
                    body: active.emptyBody,
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var c = 0; c < columns.length; c++) ...[
                        if (c > 0) const Gap(_colGap),
                        Expanded(
                          child: Column(
                            children: [
                              for (var r = 0; r < columns[c].length; r++) ...[
                                if (r > 0) const Gap(_rowGap),
                                SizedBox(
                                  height: _cellHeight,
                                  child: _CompactCell(
                                    l10n: l10n,
                                    rank: columns[c][r].rank,
                                    item: columns[c][r].item,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _HotTopicsEmpty extends StatelessWidget {
  const _HotTopicsEmpty({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: theme.colors.mutedForeground),
            const Gap(10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(4),
            Text(
              body,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactCell extends StatelessWidget {
  const _CompactCell({
    required this.l10n,
    required this.rank,
    required this.item,
  });

  final AppLocalizations l10n;
  final int rank;
  final HotTopicItem? item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final empty = item == null;
    final (:title, :meta, :onPress) = switch (item) {
      null => (
        title: l10n.hotTopicsEmptySlot,
        meta: '',
        onPress: null as void Function()?,
      ),
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
      HotViewedItem(:final wordId, :final lemma, :final viewCount) => (
        title: lemma,
        meta: l10n.hotTopicsViewCount(formatRibuan(viewCount)),
        onPress: () => context.push('/words/$wordId'),
      ),
    };

    final rankStyle = theme.typography.body.xs.copyWith(
      color: empty ? theme.colors.mutedForeground : theme.colors.primary,
      fontWeight: FontWeight.w700,
      fontSize: 11,
      fontFeatures: const [FontFeature.tabularFigures()],
      height: 1,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPress,
      child: Opacity(
        opacity: empty ? 0.55 : 1,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.secondary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: SizedBox(
                width: 22,
                height: 22,
                child: Center(
                  child: Text(
                    '$rank',
                    textAlign: TextAlign.center,
                    style: rankStyle,
                  ),
                ),
              ),
            ),
            const Gap(6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.15,
                      color: empty ? theme.colors.mutedForeground : null,
                    ),
                  ),
                  if (!empty) ...[
                    const Gap(1),
                    Text(
                      meta,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.mutedForeground,
                        fontSize: 10,
                        height: 1.1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              FLucideIcons.chevronRight,
              size: 14,
              color: theme.colors.mutedForeground.withValues(
                alpha: empty ? 0.35 : 1,
              ),
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
            height: 28,
            decoration: BoxDecoration(
              color: theme.colors.secondary,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const Gap(2),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 2),
          child: Container(
            height: _HotTopicsCardState._listHeight,
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
