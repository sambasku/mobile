import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../dictionary/dictionary_router.dart';
import '../../../my_votes/domain/entities/my_vote_item.dart';
import '../providers/periksa_kata_providers.dart';
import '../widgets/meaning_vote_row.dart';
import '../widgets/periksa_kata_card_shell.dart';
import '../widgets/periksa_meaning_blurb.dart';
import '../widgets/periksa_vote_rail.dart';
import '../widgets/periksa_vote_split_panel.dart';

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
    final theme = context.theme;
    final auth = ref.watch(authStatusProvider);

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
                  itemBuilder: (context, pageIndex) {
                    final filter = _statuses[pageIndex];
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: _buildHistoryTabBody(
                        async: async,
                        filter: filter,
                        l10n: l10n,
                        theme: theme,
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
  Widget _buildHistoryTabBody({
    required AsyncValue<PeriksaKataHistoryState> async,
    required String? filter,
    required AppLocalizations l10n,
    required FThemeData theme,
  }) {
    final notifier = ref.read(periksaKataHistoryControllerProvider.notifier);
    final cached = notifier.cachedForStatus(filter);
    final isActiveTab = filter == _statuses[_tabIndex];

    return async.when(
      loading: () {
        if (cached != null) {
          return _buildHistoryScroll(cached, l10n, theme);
        }
        if (!isActiveTab) {
          return _buildHistoryScroll(
            PeriksaKataHistoryState(communityStatus: filter),
            l10n,
            theme,
          );
        }
        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: FCircularProgress()),
            ),
          ],
        );
      },
      error: (err, _) {
        if (cached != null) {
          return _buildHistoryScroll(cached, l10n, theme);
        }
        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(err.toString(), textAlign: TextAlign.center),
              ),
            ),
          ],
        );
      },
      data: (state) {
        final effective = state.communityStatus == filter
            ? state
            : (cached ??
                PeriksaKataHistoryState(
                  communityStatus: filter,
                  q: state.q,
                ));
        return _buildHistoryScroll(effective, l10n, theme);
      },
    );
  }

  Widget _buildHistoryScroll(
    PeriksaKataHistoryState state,
    AppLocalizations l10n,
    FThemeData theme,
  ) {
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
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return _HistoryList(items: state.items, hasMore: state.hasMore);
  }

}

class _HistoryList extends ConsumerStatefulWidget {
  const _HistoryList({required this.items, required this.hasMore});

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

  void _openDetail() {
    if (item.word == null) return;
    final path = DictionaryRouter.detail.path.replaceFirst(
      ':id',
      item.word!.id,
    );
    context.push('$path?meaning=${Uri.encodeQueryComponent(item.targetId)}');
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
    unawaited(HapticFeedback.mediumImpact());
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
    final lemma = item.word?.lemma ?? '-';
    final translation = (item.translation ?? '').trim();
    final definition = (item.definition ?? '').trim();

    // Compact: lemma / terjemahan / definisi saja (tanpa label & meta).
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: PeriksaKataCardShell(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FTappable(
              onPress: item.word == null ? null : _openDetail,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 8, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PeriksaLemmaHeader(lemma: lemma),
                    PeriksaMeaningBlurb(
                      translation: translation,
                      definition: definition,
                    ),
                  ],
                ),
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
        voteRail: PeriksaVoteRail(
          child: PeriksaVoteSplitPanel(
            upvotes: item.upvotes,
            downvotes: item.downvotes,
            myVote: item.value,
            disagreeSemantics: l10n.periksaKataDisagree,
            agreeSemantics: l10n.periksaKataAgree,
            onVote: (value) => _revise(value),
          ),
        ),
      ),
    );
  }
}


