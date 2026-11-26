import 'dart:async';

import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/models/external_link.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/header_action_icon.dart';
import '../../../../core/widgets/theme_toggle_header_action.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/auth_router.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../baleho_router.dart';
import '../../domain/baleho_models.dart';
import '../providers/baleho_board_provider.dart';
import '../widgets/baleho_grid.dart';
import '../widgets/baleho_placement_sheet.dart';

/// Tab Baleho: 2 slide (promo + internal), grid 4x6, dot indicator.
class BalehoPage extends ConsumerStatefulWidget {
  const BalehoPage({super.key, this.initialSlide = 0, this.referralUsername});

  final int initialSlide;
  final String? referralUsername;

  @override
  ConsumerState<BalehoPage> createState() => _BalehoPageState();
}

class _BalehoPageState extends ConsumerState<BalehoPage> {
  late final PageController _pageController;
  var _slideIndex = 0;
  BalehoSelection? _selection;

  /// Mode pilih/drag slot - harus dinyalakan dulu supaya tidak bentrok swipe slide.
  var _pickMode = false;

  /// Guard anti double-open CTA setelah sheet konfirmasi.
  var _actionBusy = false;
  final _impressedIds = <String>{};

  @override
  void initState() {
    super.initState();
    _slideIndex = widget.initialSlide.clamp(0, 1);
    _pageController = PageController(initialPage: _slideIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _exitPickMode() {
    setState(() {
      _pickMode = false;
      _selection = null;
    });
  }

  void _track(
    String eventType, {
    required String placementId,
    String? frameId,
  }) {
    unawaited(
      ref
          .read(balehoApiProvider)
          .recordEvent(
            placementId: placementId,
            frameId: frameId,
            eventType: eventType,
          ),
    );
  }

  void _recordImpressions(BalehoBoard board) {
    final api = ref.read(balehoApiProvider);
    for (final p in board.placements) {
      if (p.frames.isEmpty) continue;
      if (p.status != 'live') continue;
      if (!_impressedIds.add(p.id)) continue;
      unawaited(
        api.recordEvent(
          placementId: p.id,
          frameId: p.frames.first.id,
          eventType: 'impression',
        ),
      );
    }
  }

  Future<void> _onPlacementTap(
    BalehoPlacement placement,
    BalehoFrame frame,
  ) async {
    if (!mounted || _actionBusy) return;
    _track('tap', placementId: placement.id, frameId: frame.id);

    // Tile curated Peringkat Mingguan: langsung ke halaman, tanpa sheet.
    if (placement.id == BalehoBoard.weeklyLeaderboardPlacementId) {
      await _runPlacementAction(placement, frame);
      return;
    }

    // Iklan biasa: preview dulu. Copy + aksi dari frame parent (pertama),
    // bukan frame child yang sedang tampil di carousel.
    final parent = balehoParentFrame(placement) ?? frame;
    final open = await showBalehoPlacementSheet(
      context,
      placement: placement,
      frame: frame,
    );
    if (open != true || !mounted || _actionBusy) return;
    await _runPlacementAction(placement, parent);
  }

  Future<void> _runPlacementAction(
    BalehoPlacement placement,
    BalehoFrame frame,
  ) async {
    if (!mounted || _actionBusy) return;
    _actionBusy = true;
    _track('action', placementId: placement.id, frameId: frame.id);
    final l10n = AppLocalizations.of(context);
    try {
      if (frame.actionType == 'external') {
        final uri = Uri.tryParse(frame.actionPayload);
        if (uri == null) {
          _track('action_fail', placementId: placement.id, frameId: frame.id);
          if (mounted) {
            showFToast(
              context: context,
              title: Text(l10n.balehoActionFailToast),
            );
          }
          return;
        }
        await launchExternalUrl(uri);
      } else {
        final path = frame.actionPayload.trim();
        if (path.isEmpty) return;
        if (!mounted) return;
        context.push(path);
      }
      _track('action_success', placementId: placement.id, frameId: frame.id);
    } catch (_) {
      _track('action_fail', placementId: placement.id, frameId: frame.id);
      if (mounted) {
        showFToast(context: context, title: Text(l10n.balehoActionFailToast));
      }
    } finally {
      _actionBusy = false;
    }
  }

  Future<void> _continueBooking() async {
    final sel = _selection;
    if (sel == null) return;
    final authed = ref.read(authStatusProvider).value?.isAuth ?? false;
    if (!authed) {
      if (!mounted) return;
      context.push(AuthRouter.login.path);
      return;
    }
    if (!mounted) return;
    final refQ =
        widget.referralUsername == null ||
            widget.referralUsername!.trim().isEmpty
        ? ''
        : '&ref=${Uri.encodeQueryComponent(widget.referralUsername!.trim())}';
    final ok = await context.push<bool>(
      '/baleho/pesan?col=${sel.col}&row=${sel.row}&w=${sel.w}&h=${sel.h}$refQ',
    );
    if (ok == true && mounted) {
      _exitPickMode();
      ref.invalidate(balehoBoardProvider(1));
    }
  }

  void _goToSlide(int index) {
    if (_pickMode) _exitPickMode();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _onVacantCellTap(int col, int row) {
    return _showPromoInfoSheet(
      seedSelection: BalehoSelection(col: col, row: row, w: 1, h: 1),
    );
  }

  Future<void> _onHeldSlotTap() {
    final l10n = AppLocalizations.of(context);
    return _showBalehoInfoSheet(
      title: l10n.balehoSlotHeldInfoTitle,
      body: l10n.balehoSlotHeldInfoBody,
    );
  }

  Future<void> _showBalehoInfoSheet({
    required String title,
    required String body,
  }) async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = sheetContext.theme;
        final sheetL10n = AppLocalizations.of(sheetContext);
        return Padding(
          padding: MediaQuery.viewInsetsOf(sheetContext),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    softWrap: true,
                    style: theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    softWrap: true,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.foreground.withValues(alpha: 0.85),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FButton(
                    onPress: () => Navigator.pop(sheetContext),
                    child: Text(sheetL10n.commonClose),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPromoInfoSheet({BalehoSelection? seedSelection}) async {
    final board = ref.read(balehoBoardProvider(1)).asData?.value;
    if (board != null && board.isFullyOccupied) {
      final l10n = AppLocalizations.of(context);
      await _showBalehoInfoSheet(
        title: l10n.balehoBoardFullTitle,
        body: l10n.balehoBoardFullBody,
      );
      return;
    }

    final priceAsync = ref.read(balehoPricePerCellPerDayProvider.future);
    final startPick = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (sheetContext) => _BalehoPromoPricingSheet(
        priceAsync: priceAsync,
        onPickSlot: () => Navigator.pop(sheetContext, true),
        onClose: () => Navigator.pop(sheetContext, false),
      ),
    );
    if (!mounted || startPick != true) return;
    setState(() {
      _pickMode = true;
      // Tap dari grid kosong: langsung pilih sel itu (1x1) sebagai jangkar.
      if (seedSelection != null) {
        _selection = seedSelection;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = FTheme.of(context);
    final slideLabels = [l10n.balehoPromoSlide, l10n.balehoInternalSlide];

    ref.listen(balehoBoardProvider(1), (_, next) {
      next.whenData(_recordImpressions);
    });
    ref.listen(balehoBoardProvider(2), (_, next) {
      next.whenData(_recordImpressions);
    });

    return Column(
      children: [
        FHeader(
          title: const BrandWordmark(),
          suffixes: [
            FHeaderAction(
              icon: const Icon(
                FLucideIcons.refreshCw,
                size: kHeaderActionIconSize,
              ),
              onPress: () {
                ref.invalidate(balehoBoardProvider(1));
                ref.invalidate(balehoBoardProvider(2));
              },
            ),
            FHeaderAction(
              icon: const Icon(
                FLucideIcons.clipboardList,
                size: kHeaderActionIconSize,
              ),
              onPress: () {
                final authed =
                    ref.read(authStatusProvider).value?.isAuth ?? false;
                if (!authed) {
                  context.push(AuthRouter.login.path);
                  return;
                }
                context.push(BalehoRouter.history.path);
              },
            ),
            const ThemeToggleHeaderAction(),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
          child: SizedBox(
            // Tinggi caption tetap - ganti mode tidak geser grid.
            height: 20,
            child: _slideIndex == 0
                ? Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickMode ? null : _showPromoInfoSheet,
                          behavior: HitTestBehavior.opaque,
                          child: Text(
                            l10n.balehoSlidePromoCaption,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: theme.typography.body.xs.copyWith(
                              color: theme.colors.foreground.withValues(
                                alpha: 0.85,
                              ),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 56,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _pickMode
                              ? GestureDetector(
                                  onTap: _exitPickMode,
                                  behavior: HitTestBehavior.opaque,
                                  child: Text(
                                    l10n.balehoCancelSelection,
                                    textAlign: TextAlign.right,
                                    style: theme.typography.body.sm.copyWith(
                                      color: theme.colors.foreground,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      height: 1.2,
                                    ),
                                  ),
                                )
                              : Semantics(
                                  button: true,
                                  label: l10n.balehoSlidePromoInfoSemantics,
                                  child: GestureDetector(
                                    onTap: _showPromoInfoSheet,
                                    behavior: HitTestBehavior.opaque,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Icon(
                                        FLucideIcons.info,
                                        size: 14,
                                        color: theme.colors.foreground
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  )
                : Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.balehoSlideInternalCaption,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.foreground.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        height: 1.2,
                      ),
                    ),
                  ),
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            // Mode pilih = kunci swipe supaya drag ukuran tidak ganti slide.
            physics: _pickMode
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            onPageChanged: (i) {
              setState(() {
                _slideIndex = i;
                _pickMode = false;
                _selection = null;
              });
            },
            children: [
              _SlideBody(
                slide: 1,
                // Drag/tap pilih slot hanya setelah mode aktif.
                sellable: _pickMode,
                selection: _selection,
                onSelectionChanged: (s) => setState(() => _selection = s),
                onPlacementTap: _onPlacementTap,
                onVacantTap: _onVacantCellTap,
                onHeldTap: _onHeldSlotTap,
              ),
              _SlideBody(
                slide: 2,
                sellable: false,
                onPlacementTap: _onPlacementTap,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          // Satu baris bawah tetap (note promo / aksi mode pilih + indikator
          // halaman) agar area bawah compact & tidak menggeser grid.
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 18),
            child: Row(
              children: [
                Expanded(
                  child: _slideIndex == 0 && _pickMode
                      ? (_selection == null
                            ? Text(
                                l10n.balehoSelectionHint,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: theme.typography.body.sm.copyWith(
                                  color: theme.colors.foreground.withValues(
                                    alpha: 0.85,
                                  ),
                                  fontSize: 11,
                                  height: 1.2,
                                ),
                              )
                            : GestureDetector(
                                onTap: _continueBooking,
                                behavior: HitTestBehavior.opaque,
                                child: Text(
                                  l10n.balehoContinueBook,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.typography.body.sm.copyWith(
                                    color: theme.colors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    height: 1.2,
                                  ),
                                ),
                              ))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FLucideIcons.info,
                              size: 11,
                              color: theme.colors.mutedForeground,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                l10n.balehoFooterPromoNote,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: theme.typography.body.xs.copyWith(
                                  color: theme.colors.mutedForeground,
                                  fontSize: 10,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(2, (i) {
                    final active = i == _slideIndex;
                    return Semantics(
                      button: true,
                      selected: active,
                      label: slideLabels[i],
                      child: GestureDetector(
                        onTap: () => _goToSlide(i),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 6,
                            width: active ? 18 : 6,
                            decoration: BoxDecoration(
                              color: active
                                  ? theme.colors.primary
                                  : theme.colors.mutedForeground.withValues(
                                      alpha: 0.35,
                                    ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BalehoPromoPricingSheet extends StatelessWidget {
  const _BalehoPromoPricingSheet({
    required this.priceAsync,
    required this.onPickSlot,
    required this.onClose,
  });

  final Future<int> priceAsync;
  final VoidCallback onPickSlot;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final amountFmt = NumberFormat.decimalPattern('id');
    final maxH = MediaQuery.sizeOf(context).height * 0.85;

    return Padding(
      padding: MediaQuery.viewInsetsOf(context),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        FLucideIcons.megaphone,
                        size: 20,
                        color: theme.colors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.balehoSlidePromoCaption,
                            softWrap: true,
                            style: theme.typography.body.md.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colors.foreground,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            l10n.balehoSlidePromoBody,
                            softWrap: true,
                            style: theme.typography.body.xs.copyWith(
                              color: theme.colors.mutedForeground,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Semantics(
                      button: true,
                      label: l10n.commonClose,
                      child: GestureDetector(
                        onTap: onClose,
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: Center(
                            child: Icon(
                              FLucideIcons.x,
                              size: 18,
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FutureBuilder<int>(
                  future: priceAsync,
                  initialData: 3000,
                  builder: (context, snap) {
                    final price = snap.data ?? 3000;
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colors.primary.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colors.primary.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                l10n.balehoPricingStartFrom,
                                style: theme.typography.body.xs.copyWith(
                                  color: theme.colors.mutedForeground,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              FBadge(
                                variant: FBadgeVariant.secondary,
                                child: Text(l10n.balehoPricingBadge),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.end,
                            spacing: 6,
                            runSpacing: 2,
                            children: [
                              Text(
                                l10n.balehoPricingCurrencyValue(
                                  amountFmt.format(price),
                                ),
                                style: theme.typography.body.lg.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  color: theme.colors.foreground,
                                  height: 1.15,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text(
                                  l10n.balehoPricingPerUnit,
                                  style: theme.typography.body.xs.copyWith(
                                    color: theme.colors.mutedForeground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Container(
                              height: 0.5,
                              color: theme.colors.border,
                            ),
                          ),
                          Text(
                            l10n.balehoPricingEstimateHeading,
                            style: theme.typography.body.xs.copyWith(
                              color: theme.colors.mutedForeground,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _PromoEstimateTile(
                                  daysLabel: l10n.balehoPricingDaysShort(1),
                                  amountLabel: l10n.balehoPricingCurrencyValue(
                                    amountFmt.format(price),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _PromoEstimateTile(
                                  daysLabel: l10n.balehoPricingDaysShort(7),
                                  amountLabel: l10n.balehoPricingCurrencyValue(
                                    amountFmt.format(price * 7),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _PromoEstimateTile(
                                  daysLabel: l10n.balehoPricingDaysShort(30),
                                  amountLabel: l10n.balehoPricingCurrencyValue(
                                    amountFmt.format(price * 30),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                _PromoPricingPoint(
                  icon: FLucideIcons.grid2x2,
                  text: l10n.balehoPricingPointSize,
                ),
                const SizedBox(height: 10),
                _PromoPricingPoint(
                  icon: FLucideIcons.calculator,
                  text: l10n.balehoQuoteFormulaHint,
                ),
                const SizedBox(height: 10),
                _PromoPricingPoint(
                  icon: FLucideIcons.eye,
                  text: l10n.balehoPricingPointReach,
                ),
                const SizedBox(height: 18),
                FButton(
                  prefix: const Icon(FLucideIcons.layoutGrid, size: 16),
                  onPress: onPickSlot,
                  child: Text(l10n.balehoEnterPickMode),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PromoEstimateTile extends StatelessWidget {
  const _PromoEstimateTile({
    required this.daysLabel,
    required this.amountLabel,
  });

  final String daysLabel;
  final String amountLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            daysLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.body.xs.copyWith(
              fontSize: 11,
              color: theme.colors.mutedForeground,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            amountLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.body.xs.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: theme.colors.foreground,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoPricingPoint extends StatelessWidget {
  const _PromoPricingPoint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: theme.colors.secondary,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 14, color: theme.colors.foreground),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            softWrap: true,
            style: theme.typography.body.xs.copyWith(
              fontSize: 12.5,
              color: theme.colors.foreground.withValues(alpha: 0.88),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _SlideBody extends ConsumerWidget {
  const _SlideBody({
    required this.slide,
    required this.sellable,
    required this.onPlacementTap,
    this.selection,
    this.onSelectionChanged,
    this.onVacantTap,
    this.onHeldTap,
  });

  final int slide;
  final bool sellable;
  final BalehoSelection? selection;
  final BalehoSelectionChanged? onSelectionChanged;
  final BalehoCellTap onPlacementTap;
  final BalehoVacantTap? onVacantTap;
  final VoidCallback? onHeldTap;

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(balehoBoardProvider(slide));
    await ref.read(balehoBoardProvider(slide).future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(balehoBoardProvider(slide));
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: async.when(
        skipLoadingOnReload: true,
        loading: () => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: const [
            Align(alignment: Alignment.topCenter, child: _BalehoGridSkeleton()),
          ],
        ),
        error: (_, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 160,
              child: Center(child: Text(l10n.balehoLoadFailed)),
            ),
          ],
        ),
        data: (raw) {
          final board = slide == 2
              ? balehoBoardWithSlide2Fixed(
                  raw,
                  labels: BalehoSlide2Labels(
                    weeklyTitle: l10n.balehoWeeklyLeaderboardTitle,
                    weeklyCta: l10n.balehoWeeklyLeaderboardCta,
                  ),
                )
              : raw;
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: BalehoGrid(
                  board: board,
                  sellable: sellable,
                  selection: selection,
                  onSelectionChanged: onSelectionChanged,
                  onPlacementTap: onPlacementTap,
                  onVacantTap: onVacantTap,
                  onHeldTap: onHeldTap,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Skeleton grid 4x6 - bentuk sama dengan [BalehoGrid] saat board load.
class _BalehoGridSkeleton extends StatelessWidget {
  const _BalehoGridSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = context.theme.colors.muted;
    PaintingEffect shimmerResolver(Brightness brightness) => ShimmerEffect(
      baseColor: isDark
          ? muted.withValues(alpha: 0.35)
          : const Color(0xFFE7E7EA),
      highlightColor: isDark
          ? muted.withValues(alpha: 0.55)
          : const Color(0xFFF4F4F5),
      duration: const Duration(milliseconds: 1500),
    );

    return SkeletonizerConfig(
      data: SkeletonizerConfigData(effectResolver: shimmerResolver),
      child: IgnorePointer(
        child: Skeletonizer(
          enabled: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final cols = BalehoBoard.prototypeCols;
              final rows = BalehoBoard.prototypeRows;
              final cell = width / cols;
              return SizedBox(
                width: width,
                height: cell * rows,
                child: Column(
                  children: [
                    for (var r = 0; r < rows; r++)
                      Expanded(
                        child: Row(
                          children: [
                            for (var c = 0; c < cols; c++)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Bone(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
