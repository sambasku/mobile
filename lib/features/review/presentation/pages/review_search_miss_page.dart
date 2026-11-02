import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/theme/f_colors_x.dart';
import '../../../../core/widgets/swipe_decision_card.dart';
import '../../../../shared/widgets/tile_group_list.dart';
import '../../../search_miss/presentation/widgets/search_miss_skeleton_list.dart';
import '../../domain/entities/review_search_miss.dart';
import '../../domain/failures/review_failure.dart';
import '../providers/review_search_miss_providers.dart';
import '../../../../shared/utils/message_dialog.dart';

/// Panel pencarian kosong verifikator (#88): semua miss yang belum
/// terjawab, termasuk yang belum ditayangkan — panel ini gerbang
/// tayangnya.
///
/// Mekanisme sama seperti area verifikator: satu kartu, swipe +
/// tombol aksi, pindah kartu optimis TANPA menunggu request selesai.
/// Kalau request gagal, kartu kembali ke depan + toast destructive.
/// - kanan / [Tayang] → tayangkan ke beranda publik (miss belum tayang);
///   miss yang SUDAH tayang → kartu tetap maju + toast info (#137,
///   dulu spring back diam-diam sehingga swipe terasa "mati")
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

  /// false = daftar (pintu masuk, pola "Mulai tinjau"), true = sesi swipe.
  /// Tap tombol/tile di daftar → masuk sesi; back dari sesi → kembali daftar.
  bool _session = false;

  bool get _deckDone => _deck != null && _pos >= _deck!.length;

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
      loading: () => _scaffold(
        SearchMissSkeletonList(
          itemCount: 8,
          padding: const EdgeInsets.only(bottom: 32),
        ),
      ),
      error: (error, _) => _scaffold(
        ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            FAlert(
              variant: FAlertVariant.destructive,
              title: Text(AppLocalizations.of(context).reviewSearchMissLoadFailed),
              icon: Icon(FLucideIcons.circleAlert),
            ),
            const Gap(12),
            Center(
              child: FButton(
                variant: FButtonVariant.outline,
                onPress: () => ref.invalidate(reviewSearchMissProvider),
                child: Text(AppLocalizations.of(context).commonRetry),
              ),
            ),
          ],
        ),
      ),
      data: (items) {
        _deck ??= List.of(items);

        if (items.isEmpty) {
          return _scaffold(
            _emptyText(
              AppLocalizations.of(context).reviewSearchMissEmpty,
            ),
          );
        }

        // Sesi selesai / belum masuk sesi → daftar.
        if (!_session || _deckDone) {
          return _scaffold(_list(_deckDone));
        }

        final item = _deck![_pos];
        return _scaffold(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.of(context).reviewSearchMissSwipeHint,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(12),
              Expanded(
                // Jarak minimum card ↔ action bar (#97: tanpa padding ini
                // card menempel footer + bottomNav, terasa padat).
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: SwipeDecisionCard(
                      itemKey: item.id,
                      enabled: true,
                      onSwiped: (direction) => _onSwiped(item, direction),
                      // Samakan pendahulu (verifikasi/vote): overlay ikon,
                      // bukan teks label - ikon sudah dipass di bawah.
                      overlayStyle: SwipeDecisionOverlayStyle.icon,
                      positiveLabel: AppLocalizations.of(context).reviewSearchMissPublish,
                      negativeLabel: AppLocalizations.of(context).reviewSearchMissDismiss,
                      skipLabel: AppLocalizations.of(context).commonSkip,
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
              ),
            ],
          ),
          footer: _actionBar(item),
        );
      },
    );
  }

  /// Daftar (pintu masuk): tombol "Mulai tinjau" + tile per item —
  /// pola sama dengan antrean usulan (ReviewQueuePage).
  Widget _list(bool done) {
    final items = _deck!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (done)
          // ListView butuh tinggi terbatas — ada di dalam Column.
          Expanded(
            child: _emptyText(
              AppLocalizations.of(context).reviewSearchMissDone,
              onRefresh: _refresh,
            ),
          )
        else ...[
          FButton(
            onPress: items.isEmpty
                ? null
                : () => setState(() {
                    _session = true;
                    _pos = 0;
                  }),
            // Tanpa prefix icon: icon+spacing+label melebihi lebar layar
            // 320px (overflow 6px).
            child: Text(AppLocalizations.of(context).reviewQueueStartCount('${items.length}')),
          ),
          const Gap(12),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: TileGroupList<ReviewSearchMiss>(
                items: items,
                hasMore: false,
                onLoadMore: () async {},
                tileBuilder: (context, item) => _MissTile(
                  item: item,
                  onPress: () => setState(() {
                    _session = true;
                    _pos = items.indexOf(item);
                  }),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _scaffold(Widget child, {Widget? footer}) => FScaffold(
    childPad: true,
    footer: footer,
    header: FHeader.nested(
      title: Text(AppLocalizations.of(context).reviewSearchMissTitle),
      prefixes: [
        FHeaderAction.back(
          onPress: () {
            // Masih di sesi swipe → kembali ke daftar dulu.
            if (_session) {
              setState(() => _session = false);
            } else {
              context.pop();
            }
          },
        ),
      ],
    ),
    child: child,
  );

  Widget _emptyText(String message, {VoidCallback? onRefresh}) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
    children: [
      Text(
        message,
        style: context.theme.typography.body.sm.copyWith(
          color: context.theme.colors.mutedForeground,
        ),
      ),
      if (onRefresh != null) ...[
        const Gap(16),
        Center(
          child: FButton(
            variant: FButtonVariant.outline,
            onPress: onRefresh,
            prefix: Icon(FLucideIcons.refreshCw),
            child: Text(AppLocalizations.of(context).reviewSearchMissReload),
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
            // Ikon-only, pola sama dengan action bar Area Verifikator —
            // label + prefix muat cuma di layar lebar (overflow di 320px).
            Expanded(
              child: FButton.icon(
                variant: FButtonVariant.outline,
                size: FButtonSizeVariant.sm,
                semanticsLabel: AppLocalizations.of(context).commonSkip,
                onPress: () => _decide(item, SwipeDecisionDirection.skip),
                child: const Icon(FLucideIcons.skipForward),
              ),
            ),
            const Gap(8),
            Expanded(
              child: FButton.icon(
                variant: FButtonVariant.outline,
                size: FButtonSizeVariant.sm,
                semanticsLabel: AppLocalizations.of(context).reviewSearchMissDismiss,
                onPress: () => _decide(item, SwipeDecisionDirection.negative),
                child: Icon(FLucideIcons.x, color: theme.colors.destructive),
              ),
            ),
            const Gap(8),
            Expanded(
              child: FButton.icon(
                variant: FButtonVariant.outline,
                size: FButtonSizeVariant.sm,
                semanticsLabel: AppLocalizations.of(context).reviewSearchMissCorrect,
                onPress: () => _openEditTerm(item),
                child: const Icon(FLucideIcons.pencil),
              ),
            ),
            const Gap(8),
            Expanded(
              child: FButton.icon(
                variant: FButtonVariant.outline,
                size: FButtonSizeVariant.sm,
                semanticsLabel: AppLocalizations.of(context).reviewSearchMissPublish,
                // Sudah tayang → tombol nonaktif (swipe kanan = lewati, #137).
                onPress: item.isVisible
                    ? null
                    : () => _decide(item, SwipeDecisionDirection.positive),
                child: Icon(FLucideIcons.eye, color: theme.colors.success),
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
    // Sudah tayang → tidak ada aksi server, tapi kartu TETAP maju + info
    // (#137: dulu spring back diam-diam → swipe terasa gagal).
    if (direction == SwipeDecisionDirection.positive && item.isVisible) {
      setState(() => _pos++);
      _toast(AppLocalizations.of(context).reviewSearchMissSkippedToast(item.term));
      return true;
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
      result.match((failure) => _onFailure(item, failure), (_) {
        if (!mounted) return;
        if (direction == SwipeDecisionDirection.positive) {
          _toast(AppLocalizations.of(context).reviewSearchMissPublishedToast(item.term));
        }
      });
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

  /// Koreksi term salah ketik (tombol pensil): dialog prefilled term lama →
  /// PATCH /:id {term} — kartu tetap (bukan aksi deck), deck di-update lokal.
  Future<void> _openEditTerm(ReviewSearchMiss item) async {
    final controller = TextEditingController(text: item.term);
    final result = await showFMessageDialog<String>(
      context: context,
      title: Text(AppLocalizations.of(context).reviewSearchMissCorrect),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppLocalizations.of(context).reviewSearchMissCorrectHint),
          Gap(12),
          FTextField(
            control: FTextFieldControl.managed(controller: controller),
            label: Text(AppLocalizations.of(context).reviewSearchMissTerm),
            autofocus: true,
          ),
        ],
      ),
      actions: (dialogContext) => [
        FButton(
          variant: FButtonVariant.outline,
          onPress: () => Navigator.of(dialogContext).pop(),
          child: Text(AppLocalizations.of(context).commonCancel),
        ),
        FButton(
          onPress: () => Navigator.of(dialogContext).pop(controller.text.trim()),
          child: Text(AppLocalizations.of(context).commonSave),
        ),
      ],
    );
    final term = result;
    if (term == null || term.isEmpty || term == item.term) return;
    final res = await ref
        .read(reviewSearchMissRepositoryProvider)
        .updateTerm(item.id, term);
    if (!mounted) return;
    res.match((failure) => _toast(failure.message, destructive: true), (_) {
      setState(() {
        final i = _deck!.indexOf(item);
        if (i >= 0) {
          _deck![i] = ReviewSearchMiss(
            id: item.id,
            term: term,
            searchIn: item.searchIn,
            hitCount: item.hitCount,
            isVisible: item.isVisible,
            isFulfilled: item.isFulfilled,
          );
        }
      });
      _toast(AppLocalizations.of(context).reviewSearchMissCorrectedToast(term));
    });
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

/// Tile daftar: ketuk → masuk sesi swipe mulai item ini.
class _MissTile extends StatelessWidget with FTileMixin {
  const _MissTile({required this.item, required this.onPress});

  final ReviewSearchMiss item;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final direction = item.searchIn == 'translation'
        ? AppLocalizations.of(context).reviewSearchMissDirectionIdSbs
        : AppLocalizations.of(context).reviewSearchMissDirectionSbsId;
    return FTile(
      prefix: Icon(
        item.isVisible ? FLucideIcons.eye : FLucideIcons.search,
        color: theme.colors.primary,
      ),
      title: Text(item.term),
      subtitle: Text(
        AppLocalizations.of(context).reviewSearchMissDirectionHitsFull(
          direction,
          item.hitCount,
          item.isVisible
              ? AppLocalizations.of(context).reviewSearchMissVisibleSuffix
              : AppLocalizations.of(context).reviewSearchMissNotPublished,
        ),
      ),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: onPress,
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
        ? AppLocalizations.of(context).reviewSearchMissDirectionIdSbs
        : AppLocalizations.of(context).reviewSearchMissDirectionSbsId;
    final hits = item.hitCount > 99 ? '99×' : '${item.hitCount}×';
    final status = item.isVisible ? 'tayang' : AppLocalizations.of(context).reviewSearchMissNotPublished;
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
              style: theme.typography.body.xl.copyWith(fontWeight: FontWeight.w700),
            ),
            const Gap(10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaChip(icon: FLucideIcons.languages, label: direction),
                _MetaChip(icon: FLucideIcons.search, label: AppLocalizations.of(context).reviewSearchMissHitsText(hits)),
                _MetaChip(
                  icon: item.isVisible ? FLucideIcons.eye : FLucideIcons.eyeOff,
                  label: status,
                ),
              ],
            ),
            const Gap(18),
            Text(
              AppLocalizations.of(context).reviewSearchMissTapToSuggest,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
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
          // Flexible + ellipsis: Wrap membatasi lebar chip; label panjang
          // dipotong rapi, bukan overflow.
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
