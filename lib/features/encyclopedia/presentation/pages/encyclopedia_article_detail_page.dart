import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../data/encyclopedia_providers.dart';
import '../../domain/encyclopedia.entity.dart';
import '../providers/encyclopedia_detail_providers.dart';
import '../utils/encyclopedia_auth.dart';
import '../utils/encyclopedia_back.dart';

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
  final _commentCtrl = TextEditingController();
  bool _sendingComment = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

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

  Future<void> _sendComment(String articleId) async {
    final l10n = AppLocalizations.of(context);
    final okAuth = await ensureEncyclopediaAuth(
      context,
      ref,
      body: l10n.encyclopediaLoginCommentBody,
    );
    if (!okAuth || !mounted) return;
    final body = _commentCtrl.text.trim();
    if (body.isEmpty) return;
    setState(() => _sendingComment = true);
    _commentCtrl.clear();
    try {
      await ref
          .read(encyclopediaRepositoryProvider)
          .postComment(articleId, {'body': body});
      if (!mounted) return;
      showFToast(
        context: context,
        title: Text(l10n.encyclopediaCommentSubmit),
      );
      ref.invalidate(encyclopediaCommentsProvider(articleId));
    } catch (_) {
      if (!mounted) return;
      showFToast(
        context: context,
        title: Text(l10n.encyclopediaCommentFailed),
      );
    } finally {
      if (mounted) setState(() => _sendingComment = false);
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 84),
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
            MarkdownBody(
              data: article.bodyMd.isEmpty
                  ? '_${l10n.encyclopediaBodyEmpty}_'
                  : article.bodyMd,
              styleSheet: MarkdownStyleSheet(
                p: theme.typography.body.sm,
                h1: theme.typography.display.lg,
                h2: theme.typography.display.md,
                h3: theme.typography.display.sm,
                blockquote: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              fitContent: true,
              selectable: true,
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
              MarkdownBody(
                data: article.referencesMd!,
                styleSheet: MarkdownStyleSheet(
                  p: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                  listBullet: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                fitContent: true,
                selectable: true,
              ),
            ],
            const Gap(24),
            Text(
              l10n.encyclopediaCommentsTitle,
              style: theme.typography.display.sm.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(12),
            _CommentForm(
              controller: _commentCtrl,
              sending: _sendingComment,
              onSend: () => _sendComment(article.id),
            ),
            const Gap(16),
            _CommentList(articleId: article.id),
          ],
        ),
      ),
    );
  }
}

class _CommentForm extends StatelessWidget {
  const _CommentForm({
    required this.controller,
    required this.sending,
    required this.onSend,
  });
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l10n.encyclopediaCommentPlaceholder,
              hintStyle: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
              filled: true,
              fillColor: theme.colors.secondary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
              isDense: true,
            ),
          ),
        ),
        const Gap(12),
        IconButton(
          onPressed: sending ? null : onSend,
          icon: sending
              ? const FCircularProgress(size: .sm)
              : Icon(FLucideIcons.send, size: 20, color: theme.colors.primary),
        ),
      ],
    );
  }
}

class _CommentList extends ConsumerWidget {
  const _CommentList({required this.articleId});
  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final commentsAsync = ref.watch(encyclopediaCommentsProvider(articleId));
    return commentsAsync.when(
      loading: () => const Center(child: FCircularProgress()),
      error: (_, _) => Text(
        l10n.encyclopediaLoadFailed,
        style: theme.typography.body.sm,
      ),
      data: (comments) {
        if (comments.isEmpty) {
          return Text(
            l10n.encyclopediaCommentEmpty,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final c in comments)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: theme.colors.primary,
                      child: Text(
                        (c.user.displayName?.isNotEmpty ?? false)
                            ? c.user.displayName![0].toUpperCase()
                            : (c.user.username?.isNotEmpty ?? false)
                            ? c.user.username![0].toUpperCase()
                            : '?',
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.primaryForeground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.user.displayName ??
                                c.user.username ??
                                l10n.dictSpeakerAnonymous,
                            style: theme.typography.body.sm.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Gap(4),
                          Text(c.body, style: theme.typography.body.sm),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
