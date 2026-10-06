import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../search_miss/presentation/widgets/search_miss_skeleton_list.dart';
import '../../domain/entities/review_search_miss.dart';
import '../providers/review_search_miss_providers.dart';

/// Panel pencarian kosong verifikator (#88): semua miss yang belum
/// terjawab, termasuk yang belum ditayangkan — panel ini gerbang
/// tayangnya. Tap baris = usul langsung; 👁 = tayangkan ke publik.
///
/// List pakai ListView biasa (tanpa infinite scroll): page admin
/// 50 terbaru, belum ada permintaan load-more.
class ReviewSearchMissPage extends ConsumerWidget {
  const ReviewSearchMissPage({super.key});

  static const _limit = 50;

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(reviewSearchMissProvider);
    await ref.read(reviewSearchMissProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final missesAsync = ref.watch(reviewSearchMissProvider);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Pencarian kosong'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: missesAsync.when(
          loading: () => SearchMissSkeletonList(
            itemCount: _limit.clamp(1, 8),
            padding: const EdgeInsets.only(bottom: 32),
          ),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              const FAlert(
                variant: FAlertVariant.destructive,
                title: Text('Gagal memuat pencarian kosong'),
                icon: Icon(FLucideIcons.circleAlert),
              ),
              const Gap(12),
              Center(
                child: FButton(
                  variant: FButtonVariant.outline,
                  onPress: () => ref.invalidate(reviewSearchMissProvider),
                  child: const Text('Coba lagi'),
                ),
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
                    'Belum ada pencarian kosong yang belum terjawab. Warga yang mencari kata belum ada akan muncul di sini.',
                    style: theme.typography.sm.copyWith(
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
                  'Ketuk baris untuk mengusulkan kata; ketuk 👁 untuk menayangkan pencarian ke beranda publik.',
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
                        subtitle: Text(_subtitle(item)),
                        suffix: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!item.isVisible)
                              IconButton(
                                tooltip: 'Tayangkan ke publik',
                                icon: Icon(
                                  FLucideIcons.eye,
                                  color: theme.colors.mutedForeground,
                                ),
                                onPressed: () => _publish(ref, item),
                              ),
                            Icon(
                              FLucideIcons.chevronRight,
                              color: theme.colors.mutedForeground,
                            ),
                          ],
                        ),
                        onPress: () {
                          AnalyticsService.instance.log(
                            AnalyticsEvents.searchMissTap,
                            params: {'miss_id': item.id},
                          );
                          AnalyticsService.instance.log(
                            AnalyticsEvents.contributeStart,
                            params: {
                              'from': 'review_search_miss',
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

  static String _subtitle(ReviewSearchMiss item) {
    final direction = item.searchIn == 'translation'
        ? 'Indonesia → Sambas'
        : 'Sambas → Indonesia';
    final hits = item.hitCount > 99 ? '99×' : '${item.hitCount}×';
    final status = item.isVisible ? 'tayang' : 'belum tayang';
    return '$direction · $hits dicari · $status';
  }

  Future<void> _publish(WidgetRef ref, ReviewSearchMiss item) async {
    final result = await ref
        .read(reviewSearchMissRepositoryProvider)
        .setVisible(item.id, true);
    result.match(
      (failure) {
        final context = ref.context;
        if (!context.mounted) return;
        showFToast(
          context: context,
          variant: FToastVariant.destructive,
          title: Text(failure.message),
        );
      },
      (_) {
        ref.invalidate(reviewSearchMissProvider);
        final context = ref.context;
        if (!context.mounted) return;
        showFToast(
          context: context,
          title: Text('"${item.term}" tayang di beranda publik'),
        );
      },
    );
  }
}
