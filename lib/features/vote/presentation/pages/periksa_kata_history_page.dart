import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/f_colors_x.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../dictionary/dictionary_router.dart';
import '../../../my_votes/domain/entities/my_vote_item.dart';
import '../providers/periksa_kata_providers.dart';
import '../widgets/meaning_vote_row.dart';

/// Riwayat pemeriksaan makna (vote meaning + community_status).
class PeriksaKataHistoryPage extends ConsumerStatefulWidget {
  const PeriksaKataHistoryPage({super.key});

  @override
  ConsumerState<PeriksaKataHistoryPage> createState() =>
      _PeriksaKataHistoryPageState();
}

class _PeriksaKataHistoryPageState
    extends ConsumerState<PeriksaKataHistoryPage> {
  Timer? _debounce;
  int _tabIndex = 0;
  late final PageController _pageController;
  final _chipScroll = ScrollController();
  final _chipKeys = List<GlobalKey>.generate(4, (_) => GlobalKey());

  static const _statuses = <String?>[null, 'pending', 'verified', 'rejected'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _tabIndex);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pageController.dispose();
    _chipScroll.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(periksaKataHistoryControllerProvider.notifier).setQuery(text);
    });
  }

  void _selectTab(int index) {
    if (_tabIndex == index) return;
    setState(() => _tabIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
    ref
        .read(periksaKataHistoryControllerProvider.notifier)
        .setCommunityStatus(_statuses[index]);
    _ensureChipVisible(index);
  }

  void _onPageChanged(int index) {
    if (_tabIndex == index) return;
    setState(() => _tabIndex = index);
    ref
        .read(periksaKataHistoryControllerProvider.notifier)
        .setCommunityStatus(_statuses[index]);
    _ensureChipVisible(index);
  }

  void _ensureChipVisible(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || index < 0 || index >= _chipKeys.length) return;
      final ctx = _chipKeys[index].currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.5,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _refresh() async {
    await ref.read(periksaKataHistoryControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authStatusProvider);
    final theme = context.theme;

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.periksaKataHistoryTitle),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: auth.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (_, _) => Center(child: Text(l10n.periksaKataLoginPrompt)),
        data: (status) {
          if (!status.isAuth) {
            return Center(
              child: FButton(
                onPress: () => context.push('/login'),
                child: Text(l10n.voteDeckLoginCta),
              ),
            );
          }

          final async = ref.watch(periksaKataHistoryControllerProvider);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FTextField(
                control: FTextFieldControl.managed(
                  onChange: (value) => _onSearchChanged(value.text),
                ),
                hint: l10n.periksaKataSearchHint,
                textInputAction: TextInputAction.search,
                clearable: (value) => value.text.isNotEmpty,
                prefixBuilder: (context, style, variants) =>
                    FTextField.prefixIconBuilder(
                      context,
                      style,
                      variants,
                      const Icon(FLucideIcons.search),
                    ),
              ),
              const Gap(6),
              SizedBox(
                height: 28,
                child: ListView.separated(
                  controller: _chipScroll,
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  separatorBuilder: (_, _) => const Gap(4),
                  itemBuilder: (context, i) {
                    final labels = [
                      l10n.periksaKataFilterAll,
                      l10n.periksaKataFilterPending,
                      l10n.periksaKataFilterVerified,
                      l10n.periksaKataFilterRejected,
                    ];
                    final selected = _tabIndex == i;
                    return KeyedSubtree(
                      key: _chipKeys[i],
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _selectTab(i),
                        child: FBadge(
                          variant: selected
                              ? FBadgeVariant.primary
                              : FBadgeVariant.secondary,
                          child: Text(
                            labels[i],
                            style: theme.typography.body.xs.copyWith(
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? theme.colors.primaryForeground
                                  : theme.colors.foreground,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Gap(6),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: 4,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, _) {
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: async.when(
                        loading: () => CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            const SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(child: FCircularProgress()),
                            ),
                          ],
                        ),
                        error: (err, _) => CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Text(
                                  err.toString(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                        data: (state) {
                          if (state.items.isEmpty) {
                            return CustomScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              slivers: [
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Text(
                                        state.q.isEmpty
                                            ? l10n.periksaKataHistoryEmpty
                                            : l10n.periksaKataSearchEmpty,
                                        textAlign: TextAlign.center,
                                        style: theme.typography.body.sm
                                            .copyWith(
                                          color: theme.colors.mutedForeground,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          return _HistoryList(
                            items: state.items,
                            hasMore: state.hasMore,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


class _HistoryList extends ConsumerStatefulWidget {
  const _HistoryList({
    required this.items,
    required this.hasMore,
  });

  final List<MyVoteItem> items;
  final bool hasMore;

  @override
  ConsumerState<_HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends ConsumerState<_HistoryList> {
  final _scroll = ScrollController();
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _maybeLoadMore() async {
    if (_loadingMore || !widget.hasMore || !_scroll.hasClients) return;
    if (_scroll.position.maxScrollExtent - _scroll.position.pixels >= 200) {
      return;
    }
    _loadingMore = true;
    final failure = await ref
        .read(periksaKataHistoryControllerProvider.notifier)
        .loadMore();
    if (mounted && failure != null) {
      showFToast(context: context, title: Text(failure.message));
    }
    _loadingMore = false;
  }

  @override
  Widget build(BuildContext context) {
    // Kartu individual (bukan FTileGroup) - hindari container-dalam-container.
    return CustomScrollView(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _HistoryTile(item: widget.items[index]),
            childCount: widget.items.length,
          ),
        ),
        const SliverFillRemaining(
          hasScrollBody: false,
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _HistoryTile extends ConsumerStatefulWidget {
  const _HistoryTile({required this.item});

  final MyVoteItem item;

  @override
  ConsumerState<_HistoryTile> createState() => _HistoryTileState();
}

class _HistoryTileState extends ConsumerState<_HistoryTile> {
  bool _inFlight = false;

  MyVoteItem get item => widget.item;

  String _statusLabel(AppLocalizations l10n) {
    return switch (item.communityStatus) {
      'verified' => l10n.periksaKataFilterVerified,
      'rejected' => l10n.periksaKataFilterRejected,
      'pending' => l10n.periksaKataFilterPending,
      _ => l10n.periksaKataFilterPending,
    };
  }

  void _openDetail() {
    if (item.word == null) return;
    final path = DictionaryRouter.detail.path.replaceFirst(
      ':id',
      item.word!.id,
    );
    context.push(
      '$path?meaning=${Uri.encodeQueryComponent(item.targetId)}',
    );
  }

  Future<void> _showVoteLockedSheet() async {
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: MediaQuery.of(sheetContext).viewInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FTileGroup(
              children: [
                FTile(
                  title: Text(l10n.periksaKataVoteLockedTitle),
                  subtitle: Text(l10n.periksaKataVoteLockedBody),
                ),
                FTile(
                  title: const Text(''),
                  suffix: FButton(
                    onPress: () => Navigator.of(sheetContext).pop(),
                    child: Text(l10n.commonClose),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _revise(int value) async {
    if (_inFlight) return;
    if (!item.canReviseVote) {
      await _showVoteLockedSheet();
      return;
    }

    // Tap arah yang sama = batal vote → wajib konfirmasi dulu.
    if (value == item.value) {
      final l10n = AppLocalizations.of(context);
      final confirmed = await showModalBottomSheet<bool>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (sheetContext) => Padding(
          padding: MediaQuery.of(sheetContext).viewInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FTileGroup(
                children: [
                  FTile(
                    title: Text(l10n.periksaKataUnvoteTitle),
                    subtitle: Text(l10n.periksaKataUnvoteBody),
                  ),
                  FTile(
                    title: const Text(''),
                    suffix: FButton(
                      variant: FButtonVariant.destructive,
                      onPress: () => Navigator.of(sheetContext).pop(true),
                      child: Text(l10n.periksaKataUnvoteConfirm),
                    ),
                  ),
                  FTile(
                    title: const Text(''),
                    suffix: FButton(
                      onPress: () => Navigator.of(sheetContext).pop(false),
                      child: Text(l10n.commonCancel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    final wasCancel = value == item.value;
    setState(() => _inFlight = true);
    try {
      final failure = await ref
          .read(periksaKataHistoryControllerProvider.notifier)
          .reviseVote(item: item, value: value);
      if (!mounted) return;
      if (failure != null) {
        showFToast(context: context, title: Text(failure.message));
      } else if (wasCancel) {
        showFToast(
          context: context,
          title: Text(AppLocalizations.of(context).periksaKataUnvoteDone),
        );
      }
    } finally {
      if (mounted) setState(() => _inFlight = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final lemma = item.word?.lemma ?? '-';
    final choice = item.value == 1
        ? l10n.periksaKataAgree
        : l10n.periksaKataDisagree;
    final locked = !item.canReviseVote;
    final meta = locked
        ? '$choice · ${_statusLabel(l10n)} · ${l10n.periksaKataVoteLockedMeta}'
        : '$choice · ${_statusLabel(l10n)} · ${formatDateTimeIso(item.votedAt)}';

    // Model sama Periksa Kata: kiri teks, kanan panel jempol kompak, bar bawah.
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: FTappable(
                      onPress: item.word == null ? null : _openDetail,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 6, 8, 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lemma,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.typography.body.sm.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Gap(2),
                            Text(
                              meta,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.typography.body.xs.copyWith(
                                color: theme.colors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colors.secondary,
                      borderRadius: BorderRadius.zero,
                    ),
                    child: SizedBox(
                      width: 100,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Expanded(
                                child: _HistoryVoteIcon(
                                  icon: FLucideIcons.arrowBigDown,
                                  count: item.downvotes,
                                  active: item.value == -1,
                                  enabled: !_inFlight,
                                  idleBg: theme.colors.destructive
                                      .withValues(alpha: 0.12),
                                  idleFg: theme.colors.destructive,
                                  idleBorder: theme.colors.destructive
                                      .withValues(alpha: 0.45),
                                  activeBg: theme.colors.destructive,
                                  activeFg:
                                      theme.colors.destructiveForeground,
                                  semanticsLabel: l10n.periksaKataDisagree,
                                  onPress: () => _revise(-1),
                                ),
                              ),
                              const Gap(4),
                              Expanded(
                                child: _HistoryVoteIcon(
                                  icon: FLucideIcons.arrowBigUp,
                                  count: item.upvotes,
                                  active: item.value == 1,
                                  enabled: !_inFlight,
                                  idleBg: theme.colors.success
                                      .withValues(alpha: 0.12),
                                  idleFg: theme.colors.success,
                                  idleBorder: theme.colors.success
                                      .withValues(alpha: 0.45),
                                  activeBg: theme.colors.success,
                                  activeFg: theme.colors.background,
                                  semanticsLabel: l10n.periksaKataAgree,
                                  onPress: () => _revise(1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
              child: VoteTrustProgress(
                upvotes: item.upvotes,
                downvotes: item.downvotes,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryVoteIcon extends StatelessWidget {
  const _HistoryVoteIcon({
    required this.icon,
    required this.count,
    required this.active,
    required this.enabled,
    required this.idleBg,
    required this.idleFg,
    required this.idleBorder,
    required this.activeBg,
    required this.activeFg,
    required this.semanticsLabel,
    required this.onPress,
  });

  final IconData icon;
  final int count;
  final bool active;
  final bool enabled;
  final Color idleBg;
  final Color idleFg;
  final Color idleBorder;
  final Color activeBg;
  final Color activeFg;
  final String semanticsLabel;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final bg = active ? activeBg : idleBg;
    final fg = active ? activeFg : idleFg;
    final border = active ? activeBg : idleBorder;

    return Semantics(
      button: true,
      label: semanticsLabel,
      value: '$count',
      child: Opacity(
        opacity: enabled || active ? 1 : 0.55,
        child: FTappable(
          onPress: enabled ? onPress : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: border, width: 1.5),
            ),
            child: SizedBox(
              height: 44,
              width: double.infinity,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18, color: fg),
                    const Gap(4),
                    Text(
                      '$count',
                      style: theme.typography.body.sm.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
