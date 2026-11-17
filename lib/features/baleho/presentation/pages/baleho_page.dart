import 'dart:async';

import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

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
      ref.read(balehoApiProvider).recordEvent(
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
    // Tap grid → preview dulu; aksi hanya setelah user konfirmasi di sheet.
    final open = await showBalehoPlacementSheet(
      context,
      placement: placement,
      frame: frame,
    );
    if (open != true || !mounted || _actionBusy) return;
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
        if (!mounted) return;
        context.push(frame.actionPayload);
      }
      _track('action_success', placementId: placement.id, frameId: frame.id);
    } catch (_) {
      _track('action_fail', placementId: placement.id, frameId: frame.id);
      if (mounted) {
        showFToast(
          context: context,
          title: Text(l10n.balehoActionFailToast),
        );
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
    final refQ = widget.referralUsername == null ||
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

  Future<void> _showPromoInfoSheet() async {
    final startPick = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = sheetContext.theme;
        final sheetL10n = AppLocalizations.of(sheetContext);
        final maxBodyH = MediaQuery.sizeOf(sheetContext).height * 0.45;
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
                    sheetL10n.balehoSlidePromoCaption,
                    softWrap: true,
                    style: theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxBodyH),
                    child: SingleChildScrollView(
                      child: Text(
                        sheetL10n.balehoSlidePromoBody,
                        softWrap: true,
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.foreground.withValues(
                            alpha: 0.85,
                          ),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FButton(
                    onPress: () => Navigator.pop(sheetContext, true),
                    child: Text(sheetL10n.balehoEnterPickMode),
                  ),
                  const SizedBox(height: 8),
                  FButton(
                    variant: FButtonVariant.outline,
                    onPress: () => Navigator.pop(sheetContext, false),
                    child: Text(sheetL10n.commonClose),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (!mounted || startPick != true) return;
    setState(() => _pickMode = true);
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
                FLucideIcons.history,
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
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
          child: SizedBox(
            // Tinggi caption tetap - ganti mode tidak geser grid.
            height: 22,
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
                            style: theme.typography.body.sm.copyWith(
                              color: theme.colors.foreground,
                              fontWeight: FontWeight.w700,
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
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.foreground.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w700,
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
              ),
              _SlideBody(
                slide: 2,
                sellable: false,
                onPlacementTap: _onPlacementTap,
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Slot aksi tetap tinggi - mode pesan tidak dorong/geser grid.
                SizedBox(
                  height: 28,
                  child: _slideIndex == 0 && _pickMode
                      ? (_selection == null
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                l10n.balehoSelectionHint,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: theme.typography.body.sm.copyWith(
                                  color: theme.colors.foreground.withValues(
                                    alpha: 0.85,
                                  ),
                                  fontSize: 12,
                                  height: 1.2,
                                ),
                              ),
                            )
                          : Center(
                              child: GestureDetector(
                                onTap: _continueBooking,
                                behavior: HitTestBehavior.opaque,
                                child: Text(
                                  l10n.balehoContinueBook,
                                  style: theme.typography.body.sm.copyWith(
                                    color: theme.colors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ))
                      : null,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                            vertical: 4,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 8,
                            width: active ? 22 : 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? theme.colors.primary
                                  : theme.colors.mutedForeground.withValues(
                                      alpha: 0.35,
                                    ),
                              borderRadius: BorderRadius.circular(8),
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

class _SlideBody extends ConsumerWidget {
  const _SlideBody({
    required this.slide,
    required this.sellable,
    required this.onPlacementTap,
    this.selection,
    this.onSelectionChanged,
  });

  final int slide;
  final bool sellable;
  final BalehoSelection? selection;
  final BalehoSelectionChanged? onSelectionChanged;
  final BalehoCellTap onPlacementTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(balehoBoardProvider(slide));
    final l10n = AppLocalizations.of(context);

    return async.when(
      loading: () => const Center(child: FCircularProgress()),
      error: (_, _) => Center(child: Text(l10n.balehoLoadFailed)),
      data: (raw) {
        final board = slide == 2
            ? balehoBoardWithSlide2Fixed(
                raw,
                labels: BalehoSlide2Labels(
                  weeklyTitle: l10n.balehoWeeklyLeaderboardTitle,
                  weeklyCta: l10n.balehoWeeklyLeaderboardCta,
                  usahaTitle: l10n.balehoSlide2UsahaTitle,
                  usahaCta: l10n.balehoSlide2UsahaCta,
                  acaraTitle: l10n.balehoSlide2AcaraTitle,
                  acaraCta: l10n.balehoSlide2AcaraCta,
                  wisataTitle: l10n.balehoSlide2WisataTitle,
                  wisataCta: l10n.balehoSlide2WisataCta,
                  karyaTitle: l10n.balehoSlide2KaryaTitle,
                  karyaCta: l10n.balehoSlide2KaryaCta,
                  ensiklopediaTitle: l10n.balehoSlide2EnsiklopediaTitle,
                  ensiklopediaCta: l10n.balehoSlide2EnsiklopediaCta,
                  kamusTitle: l10n.balehoSlide2KamusTitle,
                  kamusCta: l10n.balehoSlide2KamusCta,
                ),
              )
            : raw;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Align(
            alignment: Alignment.topCenter,
            child: BalehoGrid(
              board: board,
              sellable: sellable,
              selection: selection,
              onSelectionChanged: onSelectionChanged,
              onPlacementTap: onPlacementTap,
            ),
          ),
        );
      },
    );
  }
}
