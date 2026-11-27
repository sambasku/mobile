import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/back_to_top_button.dart';
import '../../../../shared/widgets/cover_hero.dart';
import '../../../../shared/widgets/profile_hero_shell.dart';
import '../../../../shared/widgets/profile_identity_header.dart';
import '../../../user_profile/presentation/widgets/profile_activity_section.dart'
    show OverlapAboveBox, ProfileBarClearanceHeader;
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../contribution/presentation/utils/open_verifier_contribute.dart';
import '../../../dictionary/dictionary_router.dart';
import '../../domain/entities/vote_deck_item.dart';
import '../../periksa_kata_router.dart';
import '../providers/periksa_kata_providers.dart';
import '../widgets/meaning_vote_row.dart';
import '../widgets/periksa_kata_card_shell.dart';
import '../widgets/periksa_meaning_blurb.dart';
import '../widgets/periksa_vote_rail.dart';
import '../widgets/periksa_vote_split_panel.dart';

List<Widget> _periksaKataCoverSlivers(
  BuildContext context,
  AppLocalizations l10n,
) {
  final barOffset =
      MediaQuery.paddingOf(context).top + ProfileHeroShell.barHeight;
  return [
    SliverPersistentHeader(
      pinned: true,
      delegate: ProfileBarClearanceHeader(height: barOffset),
    ),
    SliverToBoxAdapter(
      child: OverlapAboveBox(
        overlap: barOffset,
        child: CoverHero(
          asset: 'assets/images/periksa_kata_hero.webp',
          title: l10n.feedContributePeriksaKata,
          subtitle: l10n.periksaKataHeroSubtitle,
          semanticLabel: l10n.periksaKataGuideHeroSemantics,
        ),
      ),
    ),
  ];
}

/// Feed Periksa Kata: makna published belum verified.
///
/// Tap lemma membuka [DictionaryRouter.detail] (`/words/:id?meaning=`) -
/// halaman detail kata yang sama (termasuk status menunggu pengecekan).
class PeriksaKataPage extends ConsumerStatefulWidget {
  const PeriksaKataPage({super.key});

  @override
  ConsumerState<PeriksaKataPage> createState() => _PeriksaKataPageState();
}

class _PeriksaKataPageState extends ConsumerState<PeriksaKataPage> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(periksaKataFeedControllerProvider.notifier).setQuery(text);
    });
  }

  Future<void> _refresh() async {
    await ref.read(periksaKataFeedControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authStatusProvider);

    Widget loginScroll() {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          ..._periksaKataCoverSlivers(context, l10n),
          SliverFillRemaining(
            hasScrollBody: false,
            child: _LoginGate(l10n: l10n),
          ),
        ],
      );
    }

    return FScaffold(
      childPad: false,
      child: ProfileHeroShell(
        showBack: true,
        onBack: () => context.pop(),
        backLabel: l10n.commonBack,
        coverHeight: ProfileIdentityHeader.coverHeightOf(
          ProfileHeaderVariant.compact,
          MediaQuery.sizeOf(context).width,
        ),
        title: l10n.feedContributePeriksaKata,
        compactActions: true,
        actions: [
          ProfileHeroAction(
            icon: FLucideIcons.circleHelp,
            tooltip: l10n.periksaKataGuideOpenTooltip,
            onPress: () => context.push(PeriksaKataRouter.guide.path),
          ),
          ProfileHeroAction(
            icon: FLucideIcons.bookPlus,
            tooltip: l10n.activityVoteDeckSuggestWord,
            onPress: () => pushVerifierContribute(
              context,
              analyticsFrom: 'periksa_kata',
              contributeFrom: 'periksa_kata',
            ),
          ),
          ProfileHeroAction(
            icon: FLucideIcons.clipboardList,
            tooltip: l10n.periksaKataHistoryTitle,
            onPress: () => context.push(PeriksaKataRouter.history.path),
          ),
        ],
        scrollView: auth.when(
          loading: () => CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              ..._periksaKataCoverSlivers(context, l10n),
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: FCircularProgress()),
              ),
            ],
          ),
          error: (_, _) => loginScroll(),
          data: (status) => status.isAuth
              ? _FeedBody(
                  onSearchChanged: _onSearchChanged,
                  onRefresh: _refresh,
                )
              : loginScroll(),
        ),
      ),
    );
  }
}

class _LoginGate extends StatelessWidget {
  const _LoginGate({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FLucideIcons.clipboardCheck,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(12),
            Text(
              l10n.periksaKataLoginPrompt,
              textAlign: TextAlign.center,
              style: theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(16),
            FButton(
              onPress: () => context.push('/login'),
              child: Text(l10n.voteDeckLoginCta),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedBody extends ConsumerWidget {
  const _FeedBody({required this.onSearchChanged, required this.onRefresh});

  final ValueChanged<String> onSearchChanged;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final async = ref.watch(periksaKataFeedControllerProvider);
    final leading = <Widget>[
      ..._periksaKataCoverSlivers(context, l10n),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: FTextField(
            control: FTextFieldControl.managed(
              onChange: (value) => onSearchChanged(value.text),
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
        ),
      ),
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 2, 12, 0),
          child: _GuideBanner(),
        ),
      ),
    ];

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: async.when(
        loading: () => Skeletonizer(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              ...leading,
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Bone(
                        width: double.infinity,
                        height: 88,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    childCount: 4,
                  ),
                ),
              ),
              const SliverFillRemaining(
                hasScrollBody: false,
                child: SizedBox.shrink(),
              ),
            ],
          ),
        ),
        error: (err, _) => CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            ...leading,
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        err.toString(),
                        textAlign: TextAlign.center,
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                      const Gap(16),
                      FButton(
                        variant: FButtonVariant.outline,
                        onPress: onRefresh,
                        child: Text(l10n.commonRetry),
                      ),
                    ],
                  ),
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
                ...leading,
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        state.q.isEmpty
                            ? l10n.periksaKataEmpty
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
          return _FeedList(
            items: state.items,
            hasMore: state.hasMore,
            sessionVotes: state.sessionVotes,
            priorVoteIds: state.priorVoteIds,
            leadingSlivers: leading,
          );
        },
      ),
    );
  }
}

/// Banner di atas feed: arahkan ke panduan & simulasi voting.
/// Sekali ditutup tidak muncul lagi (SharedPreferences).
class _GuideBanner extends StatefulWidget {
  const _GuideBanner();

  static const prefsKey = 'periksa_kata_guide_banner_dismissed';

  @override
  State<_GuideBanner> createState() => _GuideBannerState();
}

class _GuideBannerState extends State<_GuideBanner> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    if (!(prefs.getBool(_GuideBanner.prefsKey) ?? false)) {
      setState(() => _visible = true);
    }
  }

  Future<void> _dismiss() async {
    setState(() => _visible = false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_GuideBanner.prefsKey, true);
  }

  /// Aksen teal (bukan `primary`: palet zinc membuat primary hampir hitam
  /// sehingga tint-nya terlihat abu-abu).
  static const _accent = Color(0xFF0F766E);

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _accent.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Expanded(
            child: FTappable(
              onPress: () => context.push(PeriksaKataRouter.guide.path),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 7, 4, 7),
                child: Row(
                  children: [
                    const Icon(
                      FLucideIcons.circleHelp,
                      size: 16,
                      color: _accent,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: l10n.periksaKataGuideBannerAction,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: theme.colors.foreground,
                              ),
                            ),
                            TextSpan(
                              text: '  ${l10n.periksaKataGuideBannerText}',
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Semantics(
            label: l10n.periksaKataGuideBannerDismiss,
            button: true,
            child: FTappable(
              onPress: _dismiss,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(FLucideIcons.x, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedList extends ConsumerStatefulWidget {
  const _FeedList({
    required this.items,
    required this.hasMore,
    required this.sessionVotes,
    required this.priorVoteIds,
    this.leadingSlivers = const [],
  });

  final List<VoteDeckItem> items;
  final bool hasMore;
  final Map<String, int> sessionVotes;
  final Set<String> priorVoteIds;
  final List<Widget> leadingSlivers;

  @override
  ConsumerState<_FeedList> createState() => _FeedListState();
}

class _FeedListState extends ConsumerState<_FeedList> {
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
        .read(periksaKataFeedControllerProvider.notifier)
        .loadMore();
    if (mounted && failure != null) {
      showFToast(context: context, title: Text(failure.message));
    }
    _loadingMore = false;
  }

  @override
  Widget build(BuildContext context) {
    // CustomScrollView + SliverFillRemaining: area kosong di bawah kartu
    // pendek tetap bagian scrollable → pull-to-refresh bisa di-trigger.
    return ScrollWithBackToTop(
      controller: _scroll,
      child: CustomScrollView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          ...widget.leadingSlivers,
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = widget.items[index];
                return _PeriksaKataCard(
                  item: item,
                  sessionVote: widget.sessionVotes[item.id],
                  isPriorVote: widget.priorVoteIds.contains(item.id),
                );
              }, childCount: widget.items.length),
            ),
          ),
          const SliverFillRemaining(
            hasScrollBody: false,
            child: SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _PeriksaKataCard extends ConsumerWidget {
  const _PeriksaKataCard({
    required this.item,
    required this.sessionVote,
    this.isPriorVote = false,
  });

  final VoteDeckItem item;
  final int? sessionVote;
  final bool isPriorVote;

  void _openDetail(BuildContext context) {
    // Halaman detail kata yang sama (published + menunggu pengecekan).
    final path = DictionaryRouter.detail.path.replaceFirst(':id', item.wordId);
    context.push('$path?meaning=${Uri.encodeQueryComponent(item.id)}');
  }

  Future<void> _onVote(BuildContext context, WidgetRef ref, int value) async {
    final auth = ref.read(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) {
      context.push('/login');
      return;
    }
    final l10n = AppLocalizations.of(context);
    // Tap arah yang sama = batalkan vote → konfirmasi dulu.
    if (sessionVote != null && sessionVote == value) {
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
                    subtitle: Text(
                      isPriorVote
                          ? l10n.periksaKataPriorVoteMeta
                          : l10n.periksaKataUnvoteBody,
                    ),
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
      if (confirmed != true || !context.mounted) return;
    }
    final hadVote = sessionVote != null;
    final failure = await ref
        .read(periksaKataFeedControllerProvider.notifier)
        .vote(item: item, value: value);
    if (!context.mounted) return;
    if (failure != null) {
      showFToast(context: context, title: Text(failure.message));
      return;
    }
    final after = ref
        .read(periksaKataFeedControllerProvider)
        .value
        ?.sessionVoteOf(item.id);
    if (hadVote && after == null) {
      showFToast(context: context, title: Text(l10n.periksaKataUnvoteDone));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final translation = (item.translation ?? '').trim();
    final definition = (item.definition ?? '').trim();

    // Compact: lemma / terjemahan / definisi saja (tanpa label & meta).
    final card = PeriksaKataCardShell(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FTappable(
            onPress: () => _openDetail(context),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 8, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PeriksaLemmaHeader(lemma: item.lemma),
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
          myVote: sessionVote,
          disagreeSemantics: l10n.periksaKataDisagree,
          agreeSemantics: l10n.periksaKataAgree,
          onVote: (value) => _onVote(context, ref, value),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Dismissible(
        key: ValueKey('periksa-skip-${item.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          // Provider sudah drop kartu saat sukses; jangan biarkan Dismissible
          // ikut remove (hindari "dismissed widget still in tree").
          await _onSkipReturningFailure(context, ref);
          return false;
        },
        background: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.muted,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FLucideIcons.skipForward,
                    size: 18,
                    color: theme.colors.mutedForeground,
                  ),
                  const Gap(6),
                  Text(
                    l10n.periksaKataSkip,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        child: card,
      ),
    );
  }

  Future<Object?> _onSkipReturningFailure(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final auth = ref.read(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) {
      context.push('/login');
      return 'login';
    }
    final failure = await ref
        .read(periksaKataFeedControllerProvider.notifier)
        .skip(item);
    if (!context.mounted) return failure ?? 'unmounted';
    if (failure != null) {
      showFToast(context: context, title: Text(failure.message));
      return failure;
    }
    return null;
  }
}
