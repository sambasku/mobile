import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/services/analytics_service.dart';
import '../../domain/entities/search_miss.dart';
import '../providers/search_miss_list_providers.dart';
import '../widgets/search_miss_skeleton_list.dart';

/// Halaman list "Dicari warga" (ex-tab Kontribusi).
class SearchMissListPage extends ConsumerWidget {
  const SearchMissListPage({super.key});

  static const _limit = 30;

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(searchMissListProvider(_limit));
    await ref.read(searchMissListProvider(_limit).future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final missesAsync = ref.watch(searchMissListProvider(_limit));

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Dicari warga'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: missesAsync.when(
          loading: () => SearchMissSkeletonList(
            itemCount: 8,
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
            header: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Pilih kata yang warga cari tapi belum ada, nanti form usulannya terbuka.',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          ),
          error: (_, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
            children: const [
              FAlert(
                variant: FAlertVariant.destructive,
                title: Text('Gagal memuat daftar pencarian'),
                icon: Icon(FLucideIcons.circleAlert),
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
                    'Belum ada kata yang dicari warga. Coba lagi nanti, atau usulkan kata baru dari menu di atas.',
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
              );
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
              children: [
                Text(
                  'Pilih kata yang warga cari tapi belum ada, nanti form usulannya terbuka.',
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                const Gap(12),
                FTileGroup(
                  children: [
                    for (final item in items)
                      FTile(
                        title: Text(item.term),
                        subtitle: Text(_missSubtitle(item)),
                        suffix: Icon(
                          FLucideIcons.chevronRight,
                          color: theme.colors.mutedForeground,
                        ),
                        onPress: () {
                          AnalyticsService.instance.log(
                            AnalyticsEvents.searchMissTap,
                            params: {'miss_id': item.id},
                          );
                          AnalyticsService.instance.log(
                            AnalyticsEvents.contributeStart,
                            params: {
                              'guest': 1,
                              'from': 'search_miss',
                            },
                          );
                          final q = Uri(
                            queryParameters: <String, String>{
                              'lemma': item.term,
                              'search_in': item.searchIn,
                              'miss_id': item.id,
                            },
                          ).query;
                          context.push('/contribute?$q');
                        },
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

  static String _missSubtitle(SearchMiss item) {
    final direction = item.searchIn == 'translation'
        ? 'Indonesia → Sambas'
        : 'Sambas → Indonesia';
    final hits = item.hitCount > 99 ? '99×' : '${item.hitCount}×';
    return '$direction · $hits dicari';
  }
}
