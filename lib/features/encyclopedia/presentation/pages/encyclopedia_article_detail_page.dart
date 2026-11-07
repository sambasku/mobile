import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/contributor_appreciation.dart';
import '../../../../shared/widgets/sambasku_markdown.dart';
import '../../data/encyclopedia_providers.dart';
import '../../domain/encyclopedia.entity.dart';
import '../providers/encyclopedia_detail_providers.dart';
import '../utils/encyclopedia_auth.dart';
import '../utils/encyclopedia_back.dart';
import '../widgets/encyclopedia_comments_section.dart';

class EncyclopediaArticleDetailPage extends ConsumerStatefulWidget {
  const EncyclopediaArticleDetailPage({super.key, required this.slug});
  final String slug;

  @override
  ConsumerState<EncyclopediaArticleDetailPage> createState() =>
      _EncyclopediaArticleDetailPageState();
}

class _EncyclopediaArticleDetailPageState
    extends ConsumerState<EncyclopediaArticleDetailPage> {
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

    return FScaffold(
      // Padding manual di scroll - jangan dobel dengan childPad default.
      childPad: false,
      header: FHeader.nested(
        title: Text(
          article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        prefixes: [
          FHeaderAction.back(
            onPress: () => encyclopediaPopOrGoExplore(context),
          ),
        ],
        suffixes: [
          FHeaderAction(
            icon: _busyBookmark
                ? const Icon(FLucideIcons.loaderCircle)
                : Icon(
                    bookmarked
                        ? FLucideIcons.bookmarkCheck
                        : FLucideIcons.bookmark,
                  ),
            onPress: _busyBookmark ? null : () => _toggleBookmark(article),
          ),
        ],
      ),
      // Pola lemma: bar entri komentar di bawah, thread di sheet.
      footer: EncyclopediaCommentEntryBar(articleId: article.id),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.coverUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: CachedNetworkImageWithFallback(
                      imageUrl: article.coverUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            Text(
              article.title,
              style: theme.typography.display.lg.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const Gap(12),
            Row(
              children: [
                Icon(
                  FLucideIcons.user,
                  size: 16,
                  color: theme.colors.mutedForeground,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    article.author.displayName ??
                        article.author.username ??
                        l10n.dictSpeakerAnonymous,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ),
                if (article.author.isVerifier)
                  FBadge(
                    variant: FBadgeVariant.outline,
                    child: Text(l10n.encyclopediaAuthorBy),
                  ),
              ],
            ),
            const Gap(16),
            if (article.excerpt.isNotEmpty)
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
            // Apresiasi pengusul di paling bawah halaman.
            if (isLinkablePublicUsername(article.author.username))
              ContributorAppreciationSection(
                label: l10n.usahaContributorProposedBy,
                contributors: [
                  ContributorCredit(
                    username: article.author.username!,
                    displayName: article.author.displayName ?? '',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
