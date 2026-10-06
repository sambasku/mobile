import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/theme/f_colors_x.dart';
import '../../../../core/widgets/swipe_decision_card.dart';
import '../../../search_miss/presentation/widgets/search_miss_skeleton_list.dart';
import '../../domain/entities/review_search_miss.dart';
import '../../domain/failures/review_failure.dart';
import '../providers/review_search_miss_providers.dart';

/// Panel pencarian kosong verifikator (#88): semua miss yang belum
/// terjawab, termasuk yang belum ditayangkan — panel ini gerbang
/// tayangnya.
///
/// Mekanisme sama seperti area verifikator: satu kartu, swipe +
/// tombol aksi, pindah kartu optimis TANPA menunggu request selesai.
/// Kalau request gagal, kartu kembali ke depan + toast destructive.
/// - kanan / [Tayang] → tayangkan ke beranda publik (miss belum tayang)
/// - kiri / [Singkirkan] → soft delete (spam / tidak layak)
/// - atas / [Lewati] → skip PER USER (`POST /:id/skip`): miss hilang
///   dari panel user ini saja, verifikator lain tetap melihatnya
/// - ketuk kartu → form usulan; `search_in=lemma` → term ke field
///   lemma Sambas, `search_in=translation` → field terjemahan Indonesia
class ReviewSearchMissPage extends ConsumerStatefulWidget {
  const ReviewSearchMissPage({super.key});

  @override
  ConsumerState<ReviewSearchMissPage> createState() =>
      _ReviewSearchMissPageState();
}

class _ReviewSearchMissPageState extends ConsumerState<ReviewSearchMissPage> {
  /// Salinan deck lokal — diisi sekali dari provider; aksi optimis
  /// tidak menyentuh provider supaya tidak me-reset deck di tengah jalan.
  List<ReviewSearchMiss>? _deck;
  int _pos = 0;

  bool get _deckDone =>
      _deck != null && _pos >= _deck!.length;

  Future<void> _refresh() async {
    setState(() {
      _deck = null;
      _pos = 0;
    });
    ref.invalidate(reviewSearchMissProvider);
    await ref.read(reviewSearchMissProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final missesAsync = ref.watch(reviewSearchMissProvider);

    return missesAsync.when(
      loading: () => _scaffold(SearchMissSkeletonList(
        itemCount: 8,
        padding: const EdgeInsets.only(bottom: 32),
      )),
      error: (error, _) => _scaffold(ListView(
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
      )),
      data: (items) {
        _deck ??= List.of(items);

        if (items.isEmpty) {
          return _scaffold(_emptyText(
            'Belum ada pencarian kosong yang belum terjawab. Warga yang mencari kata belum ada akan muncul di sini.',
          ));
        }
        if (_deckDone) {
          return _scaffold(_emptyText(
            'Selesai — semua pencarian kosong sudah ditangani.',
            onRefresh: _refresh,
          ));
        }

        final item = _deck![_pos];
        return _scaffold(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Kanan tayang · kiri singkirkan · atas lewati — atau ketuk kartu untuk mengusulkan.',
                style: theme.typography.sm
                    .copyWith(color: theme.colors.mutedForeground),
              ),
              const Gap(12),
              Expanded(
                child: Center(
                  child: SwipeDecisionCard(
                    itemKey: item.id,
                    enabled: true,
                    onSwiped: (direction) => _onSwiped(item, direction),
                    positiveLabel: 'Tayang',
                    negativeLabel: 'Singkirkan',
                    skipLabel: 'Lewati',
                    positiveIcon: FLucideIcons.eye,
                    negativeIcon: FLucideIcons.x,
                    skipIcon: FLucideIcons.skipForward,
                    positiveColor: theme.colors.success,
                    negativeColor: theme.colors.destructive,
                    child: _MissCardBody(
                      item: item,
                      onTap: () => _openContribute(item),
                    ),
                  ),
                ),
              ),
            ],
          ),
          footer: _actionBar(item),
        );
      },
    );
  }

  Widget _scaffold(Widget child, {Widget? footer}) => FScaffold(
        childPad: true,
        footer: footer,
        header: FHeader.nested(
          title: const Text('Pencarian kosong'),
          prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        ),
        child: child,
      );

  Widget _emptyText(String message, {VoidCallback? onRefresh}) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
        children: [
          Text(
            message,
            style: context.theme.typography.sm
                .copyWith(color: context.theme.colors.mutedForeground),
          ),
          if (onRefresh != null) ...[
            const Gap(16),
            Center(
              child: FButton(
                variant: FButtonVariant.outline,
                onPress: onRefresh,
                prefix: const Icon(FLucideIcons.refreshCw),
                child: const Text('Muat ulang'),
              ),
            ),
          ],
        ],
      );

  Widget _actionBar(ReviewSearchMiss item) {
    final theme = context.theme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            Expanded(
              child: FButton(
                variant: FButtonVariant.outline,
                size: FButtonSizeVariant.sm,
                onPress: () => _decide(item, SwipeDecisionDirection.skip),
                prefix: const Icon(FLucideIcons.skipForward),
                child: const Text('Lewati'),
              ),
            ),
            const Gap(8),
            Expanded(
              child: FButton(
                variant: FButtonVariant.outline,
                size: FButtonSizeVariant.sm,
                onPress: () => _decide(item, SwipeDecisionDirection.negative),
                prefix: Icon(
                  FLucideIcons.x,
                  color: theme.colors.destructive,
                ),
                child: const Text('Singkirkan'),
              ),
            ),
            const Gap(8),
            Expanded(
              child: FButton(
                variant: FButtonVariant.outline,
                size: FButtonSizeVariant.sm,
                // Sudah tayang → tanpa aksi (kartu spring back saat swipe).
                onPress: item.isVisible
                    ? null
                    : () => _decide(item, SwipeDecisionDirection.positive),
                prefix: Icon(
                  FLucideIcons.eye,
                  color: theme.colors.success,
                ),
                child: const Text('Tayang'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Swipe: pindah kartu SEGERA (optimis), request menyusul.
  Future<bool> _onSwiped(
    ReviewSearchMiss item,
    SwipeDecisionDirection direction,
  ) async {
    // Sudah tayang → swipe kanan tidak menimbulkan aksi (spring back).
    if (direction == SwipeDecisionDirection.positive && item.isVisible) {
      return false;
    }
    _decide(item, direction);
    return true;
  }

  /// Advance sync + kirim request tanpa await; gagal → kartu kembali
  /// ke depan + toast destructive (pola reviewSubmitQueue di area verif).
  void _decide(ReviewSearchMiss item, SwipeDecisionDirection direction) {
    setState(() => _pos++);
    final repo = ref.read(reviewSearchMissRepositoryProvider);
    final future = switch (direction) {
      SwipeDecisionDirection.positive => repo.setVisible(item.id, true),
      SwipeDecisionDirection.negative => repo.dismiss(item.id),
      SwipeDecisionDirection.skip => repo.skip(item.id),
    };
    future.then((result) {
      result.match(
        (failure) => _onFailure(item, failure),
        (_) {
          if (!mounted) return;
          if (direction == SwipeDecisionDirection.positive) {
            _toast('"${item.term}" tayang di beranda publik');
          }
        },
      );
    });
  }

  void _onFailure(ReviewSearchMiss item, ReviewFailure failure) {
    if (!mounted) return;
    setState(() {
      final at = _pos.clamp(0, _deck!.length);
      _deck!.insert(at, item);
      _pos = at;
    });
    _toast(failure.message, destructive: true);
  }

  void _openContribute(ReviewSearchMiss item) {
    AnalyticsService.instance.log(
      AnalyticsEvents.searchMissTap,
      params: {'miss_id': item.id},
    );
    AnalyticsService.instance.log(
      AnalyticsEvents.contributeStart,
      params: {'from': 'review_search_miss'},
    );
    // lemma/translation → ContributePage prefill ke field yang sesuai.
    final q = Uri(
      queryParameters: <String, String>{
        'lemma': item.term,
        'search_in': item.searchIn,
        'miss_id': item.id,
      },
    ).query;
    context.push('/contribute?$q');
  }

  void _toast(String message, {bool destructive = false}) {
    final context = this.context;
    if (!context.mounted) return;
    showFToast(
      context: context,
      variant: destructive ? FToastVariant.destructive : FToastVariant.primary,
      title: Text(message),
    );
  }
}

/// Isi kartu: term besar, meta chip, hint. Ketuk → form usulan.
class _MissCardBody extends StatelessWidget {
  const _MissCardBody({required this.item, required this.onTap});

  final ReviewSearchMiss item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final direction = item.searchIn == 'translation'
        ? 'Indonesia → Sambas'
        : 'Sambas → Indonesia';
    final hits = item.hitCount > 99 ? '99×' : '${item.hitCount}×';
    final status = item.isVisible ? 'tayang' : 'belum tayang';
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              item.term,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.xl
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            const Gap(10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaChip(icon: FLucideIcons.languages, label: direction),
                _MetaChip(icon: FLucideIcons.search, label: '$hits dicari'),
                _MetaChip(
                  icon: item.isVisible
                      ? FLucideIcons.eye
                      : FLucideIcons.eyeOff,
                  label: status,
                ),
              ],
            ),
            const Gap(18),
            Text(
              'Ketuk untuk mengusulkan kata ini.',
              style: theme.typography.sm
                  .copyWith(color: theme.colors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colors.muted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colors.mutedForeground),
          const Gap(4),
          Text(
            label,
            style: theme.typography.xs
                .copyWith(color: theme.colors.mutedForeground),
          ),
        ],
      ),
    );
  }
}
