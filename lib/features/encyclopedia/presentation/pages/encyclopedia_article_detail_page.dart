import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/widgets/back_to_top_button.dart';
import '../../../../shared/widgets/content_related_section.dart';
import '../../../../shared/widgets/contributor_appreciation.dart';
import '../../../../shared/widgets/profile_hero_shell.dart';
import '../../../../shared/widgets/sambasku_markdown.dart';
import '../../data/encyclopedia_providers.dart';
import '../../domain/encyclopedia.entity.dart';
import '../../encyclopedia_router.dart';
import '../providers/encyclopedia_detail_providers.dart';
import '../utils/encyclopedia_auth.dart';
import '../utils/encyclopedia_back.dart';
import '../widgets/encyclopedia_article_hero.dart';
import '../widgets/encyclopedia_clap_button.dart';
import '../../../../shared/entity_comments/entity_comment.dart';
import '../../../../shared/entity_comments/entity_comments_section.dart';

/// Ruang di atas gesture bar supaya tombol back-to-top tidak tertutup footer komentar.
const _kBackToTopAboveFooter = 72.0;

class EncyclopediaArticleDetailPage extends ConsumerStatefulWidget {
  const EncyclopediaArticleDetailPage({super.key, required this.slug});
  final String slug;

  @override
  ConsumerState<EncyclopediaArticleDetailPage> createState() =>
      _EncyclopediaArticleDetailPageState();
}

class _EncyclopediaArticleDetailPageState
    extends ConsumerState<EncyclopediaArticleDetailPage> {
  final _scroll = ScrollController();

  bool _viewRecorded = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _recordView(String slug) async {
    try {
      await ref.read(encyclopediaRepositoryProvider).recordView(slug);
    } catch (_) {
      // best-effort
    }
  }

  bool? _bookmarked;
  String? _bookmarkedForId;
  bool _busyBookmark = false;

  void _syncBookmarkFrom(EncyclopediaArticle article) {
    if (_bookmarkedForId == article.id) return;
    _bookmarkedForId = article.id;
    _bookmarked = article.bookmarked ?? false;
  }

  Future<void> _toggleBookmark(EncyclopediaArticle article) async {
    if (_busyBookmark || !mounted) return;
    final l10n = AppLocalizations.of(context);
    final okAuth = await ensureEncyclopediaAuth(
      context,
      ref,
      body: l10n.encyclopediaLoginBookmarkBody,
    );
    if (!okAuth || !mounted) return;
    setState(() => _busyBookmark = true);
    try {
      final resp = await ref
          .read(encyclopediaRepositoryProvider)
          .toggleBookmark(article.id);
      if (!mounted) return;
      setState(() {
        _bookmarked = resp.data?.bookmarked ?? false;
        _busyBookmark = false;
      });
      showFToast(
        context: context,
        title: Text(
          (_bookmarked ?? false)
              ? l10n.encyclopediaBookmarkAdded
              : l10n.encyclopediaBookmarkRemoved,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _busyBookmark = false);
      showFToast(
        context: context,
        title: Text(l10n.encyclopediaBookmarkFailed),
      );
    }
  }

  Future<void> _openSuggestEdit(EncyclopediaArticle article) async {
    final l10n = AppLocalizations.of(context);
    final okAuth = await ensureEncyclopediaAuth(
      context,
      ref,
      body: l10n.encyclopediaLoginContributeBody,
    );
    if (!okAuth || !mounted) return;
    context.push(EncyclopediaRouter.contributeEditPath(article.slug));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final articleAsync = ref.watch(encyclopediaArticleProvider(widget.slug));
    final article = switch (articleAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };

    if (article != null) {
      _syncBookmarkFrom(article);
      if (!_viewRecorded) {
        _viewRecorded = true;
        unawaited(_recordView(article.slug));
      }
    }

    if (article == null) {
      return FScaffold(
        header: FHeader.nested(
          title: Text(l10n.encyclopediaDetailTitle),
          prefixes: [
            FHeaderAction.back(
              onPress: () => encyclopediaPopOrGoExplore(context),
            ),
          ],
        ),
        child: Center(
          child: articleAsync.isLoading
              ? const FCircularProgress()
              : Text(l10n.encyclopediaLoadFailed),
        ),
      );
    }

    final bookmarked = _bookmarked ?? false;
    final coverUrl = article.coverUrl?.trim();
    final hasCover = coverUrl != null && coverUrl.isNotEmpty;
    final width = MediaQuery.sizeOf(context).width;
    final coverHeight = hasCover ? width / encyclopediaHeroAspect : 0.0;

    final bodyColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ArticleTopMeta(article: article, l10n: l10n),
        if (!hasCover) ...[
          Text(
            article.title,
            style: theme.typography.display.lg.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(12),
        ],
        if (!hasCover && article.excerpt.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              article.excerpt,
              style: theme.typography.body.sm.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const Gap(16),
        ],
        FTileGroup(
          label: Text(l10n.encyclopediaDetailActions),
          children: [
            FTile(
              prefix: const Icon(FLucideIcons.pencil, size: 18),
              title: Text(l10n.encyclopediaProposeEdit),
              suffix: const Icon(FLucideIcons.chevronRight, size: 16),
              onPress: () => unawaited(_openSuggestEdit(article)),
            ),
          ],
        ),
        const Gap(16),
        SambaskuMarkdown(
          data: article.bodyMd.isEmpty
              ? '_${l10n.encyclopediaBodyEmpty}_'
              : article.bodyMd,
        ),
        if (article.referencesMd != null &&
            article.referencesMd!.isNotEmpty) ...[
          const Gap(24),
          Text(
            l10n.encyclopediaReferencesTitle,
            style: theme.typography.display.sm.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(8),
          SambaskuMarkdown(data: article.referencesMd!),
        ],
        ContentRelatedSection(items: article.related),
        const Gap(16),
        EncyclopediaClapButton(
          articleId: article.id,
          initialTotal: article.clapTotal,
          initialMine: article.myClapCount,
        ),
      ],
    );

    final bookmarkIcon = _busyBookmark
        ? FLucideIcons.loaderCircle
        : bookmarked
            ? FLucideIcons.bookmarkCheck
            : FLucideIcons.bookmark;

    return FScaffold(
      childPad: false,
      footer: EntityCommentEntryBar(target: EntityCommentTarget.article, entityId: article.id),
      child: ProfileHeroShell(
        showBack: true,
        onBack: () => encyclopediaPopOrGoExplore(context),
        backLabel: l10n.commonBack,
        title: article.title,
        coverHeight: coverHeight,
        actions: [
          ProfileHeroAction(
            icon: bookmarkIcon,
            tooltip: l10n.encyclopediaBookmarkToggleSemantics,
            onPress: _busyBookmark
                ? () {}
                : () => unawaited(_toggleBookmark(article)),
          ),
        ],
        scrollView: ScrollWithBackToTop(
          controller: _scroll,
          bottom: _kBackToTopAboveFooter,
          child: CustomScrollView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (hasCover)
                SliverToBoxAdapter(
                  child: EncyclopediaArticleHero(
                    coverUrl: coverUrl,
                    title: article.title,
                    excerpt: article.excerpt,
                  ),
                ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  12,
                  hasCover ? 12 : MediaQuery.paddingOf(context).top +
                      ProfileHeroShell.barHeight + 8,
                  12,
                  24,
                ),
                sliver: SliverToBoxAdapter(child: bodyColumn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Meta artikel di atas isi: apresiasi pengusul, kategori, tag.
class _ArticleTopMeta extends StatelessWidget {
  const _ArticleTopMeta({required this.article, required this.l10n});

  final EncyclopediaArticle article;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final tags = [
      for (final t in article.tags)
        if (t.trim().isNotEmpty) t.trim(),
    ];
    final categoryName = article.category.name.trim();
    final showBadges = categoryName.isNotEmpty || tags.isNotEmpty;
    final showContributor =
        isLinkablePublicUsername(article.author.username);

    if (!showContributor && !showBadges) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showContributor)
          ContributorAppreciationSection(
            label: l10n.usahaContributorProposedBy,
            contributors: [
              ContributorCredit(
                username: article.author.username!,
                displayName: article.author.displayName ?? '',
              ),
            ],
          ),
        if (showBadges) ...[
          if (showContributor) const Gap(10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (categoryName.isNotEmpty)
                FBadge(
                  variant: FBadgeVariant.secondary,
                  child: Text(categoryName),
                ),
              for (final tag in tags)
                FBadge(
                  variant: FBadgeVariant.outline,
                  child: Text(tag),
                ),
            ],
          ),
        ],
        const Gap(16),
      ],
    );
  }
}