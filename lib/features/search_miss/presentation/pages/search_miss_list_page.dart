import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/format_number.dart';
import '../../domain/entities/search_miss.dart';
import '../providers/search_miss_list_providers.dart';
import '../widgets/search_miss_skeleton_list.dart';
import '../../../../l10n/app_localizations.dart';

/// Halaman list "Dicari warga" (ex-tab Kontribusi).
class SearchMissListPage extends ConsumerWidget {
  const SearchMissListPage({super.key});

  static const _limit = 30;

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(searchMissListProvider(_limit));
    await ref.read(searchMissListProvider(_limit).future);
  }

  Future<void> _openMissActions(BuildContext context, SearchMiss item) async {
    final l10n = AppLocalizations.of(context);
    AnalyticsService.instance.log(
      AnalyticsEvents.searchMissTap,
      params: {'miss_id': item.id},
    );
    final choice = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: MediaQuery.of(sheetContext).viewInsets,
        child: SafeArea(
          top: false,
          child: FTileGroup(
            children: [
              FTile(
                title: Text(item.term),
                subtitle: Text(_missSubtitle(item, l10n)),
              ),
              FTile(
                title: Text(l10n.dictProposeThisWord),
                onPress: () => Navigator.pop(sheetContext, 'propose'),
              ),
              FTile(
                title: Text(l10n.dictCorrectSpellingCta),
                onPress: () => Navigator.pop(sheetContext, 'correct'),
              ),
            ],
          ),
        ),
      ),
    );
    if (!context.mounted || choice == null) return;
    AnalyticsService.instance.log(
      AnalyticsEvents.contributeStart,
      params: {
        'guest': 1,
        'from': choice == 'correct' ? 'search_miss_correct' : 'search_miss',
      },
    );
    final q = Uri(
      queryParameters: <String, String>{
        'lemma': item.term,
        'search_in': item.searchIn,
        'miss_id': item.id,
        if (choice == 'correct') 'correction': '1',
      },
    ).query;
    context.push('/contribute?$q');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final missesAsync = ref.watch(searchMissListProvider(_limit));

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.searchMissTitle),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: missesAsync.when(
          loading: () => SearchMissSkeletonList(
            itemCount: 8,
            padding: const EdgeInsets.only(bottom: 32),
            header: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Pilih kata yang warga cari tapi belum ada, nanti form usulannya terbuka.',
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          ),
          error: (_, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              FAlert(
                variant: FAlertVariant.destructive,
                title: Text(AppLocalizations.of(context).searchMissLoadFailed),
                icon: const Icon(FLucideIcons.circleAlert),
              ),
            ],
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
                children: [
                  Text(
                    'Belum ada kata yang dicari warga. Coba lagi dalam beberapa saat, atau usulkan kata baru dari menu di atas.',
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
              );
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                Text(
                  'Pilih kata yang warga cari tapi belum ada, nanti form usulannya terbuka.',
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                const Gap(12),
                FTileGroup(
                  children: [
                    for (final item in items)
                      FTile(
                        title: Text(item.term),
                        subtitle: Text(_missSubtitle(item, l10n)),
                        suffix: Icon(
                          FLucideIcons.chevronRight,
                          color: theme.colors.mutedForeground,
                        ),
                        onPress: () => _openMissActions(context, item),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _missSubtitle(SearchMiss item, AppLocalizations l10n) {
    final direction = item.searchIn == 'translation'
        ? l10n.searchMissDirectionIdToSbs
        : l10n.searchMissDirectionSbsToId;
    return '$direction · ${l10n.searchMissHitCount(formatRibuan(item.hitCount))}';
  }
}
