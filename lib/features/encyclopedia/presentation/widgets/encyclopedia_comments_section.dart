import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/utils/thread_reply_draft.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/thread_edit_sheets.dart';
import '../../../../shared/widgets/thread_message.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../comment/presentation/providers/mention_suggest_providers.dart';
import '../../../comment/presentation/widgets/mention_suggest_overlay.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../domain/encyclopedia.entity.dart';
import '../providers/encyclopedia_comment_providers.dart';

/// Buka thread komentar artikel (pola sama [showWordCommentsSheet]).
Future<void> showEncyclopediaCommentsSheet(
  BuildContext context,
  String articleId,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final media = MediaQuery.of(sheetContext);
      final height = (media.size.height - media.viewInsets.bottom) * 0.88;
      return Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: SizedBox(
          height: height,
          child: EncyclopediaCommentsSection(articleId: articleId),
        ),
      );
    },
  );
}

/// Bar lengket di bawah detail artikel - jumlah + buka sheet.
class EncyclopediaCommentEntryBar extends ConsumerWidget {
  const EncyclopediaCommentEntryBar({super.key, required this.articleId});

  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(articleCommentListControllerProvider(articleId));
    final count = async.value?.items.length ?? 0;

    return Material(
      color: theme.colors.background,
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: () => showEncyclopediaCommentsSheet(context, articleId),
          child: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.colors.border)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Icon(
                  FLucideIcons.messageSquare,
                  size: 18,
                  color: theme.colors.foreground,
                ),
                const Gap(8),
                Text(
                  l10n.commentSectionTitle(count),
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                Icon(
                  FLucideIcons.chevronUp,
                  size: 16,
                  color: theme.colors.mutedForeground,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Thread komentar artikel di dalam bottom sheet.
class EncyclopediaCommentsSection extends ConsumerStatefulWidget {
  const EncyclopediaCommentsSection({super.key, required this.articleId});

  final String articleId;

  @override
  ConsumerState<EncyclopediaCommentsSection> createState() =>
      _EncyclopediaCommentsSectionState();
}

class _EncyclopediaCommentsSectionState
    extends ConsumerState<EncyclopediaCommentsSection> {
  final _bodyCtrl = TextEditingController();
  final _composerFocus = FocusNode();
  ThreadReplyDraft? _replyDraft;
  String? _replyChipHandle;

  @override
  void initState() {
    super.initState();
    _bodyCtrl.addListener(_onBodyChanged);
  }

  @override
  void dispose() {
    _bodyCtrl.removeListener(_onBodyChanged);
    _bodyCtrl.dispose();
    _composerFocus.dispose();
    super.dispose();
  }

  void _onBodyChanged() {
    ref
        .read(mentionSuggestControllerProvider.notifier)
        .onTextChanged(_bodyCtrl.text, _bodyCtrl.selection.baseOffset);
  }

  Widget _buildMentionSuggest(BuildContext context) {
    return MentionSuggestOverlay(
      onSelect: (username) => insertIntoComposer(_bodyCtrl, username),
    );
  }

  bool _isAuth() {
    return ref.read(authStatusProvider).value?.isAuth ?? false;
  }

  void _promptLogin() {
    showFToast(
      context: context,
      title: Text(AppLocalizations.of(context).commentLoginPrompt),
      variant: FToastVariant.primary,
    );
    context.push('/login');
  }

  void _startReply(ArticleComment comment) {
    if (!_isAuth()) {
      _promptLogin();
      return;
    }
    if (!comment.isPublished) return;
    final auth = ref.read(authStatusProvider).value;
    final draft = buildThreadReplyDraft(
      username: comment.user.username,
      body: comment.body,
      currentUsername: auth?.username,
    );
    final chipHandle = isLinkablePublicUsername(comment.user.username)
        ? comment.user.username
        : null;
    setState(() {
      _replyDraft = draft;
      _replyChipHandle = chipHandle;
    });
    _bodyCtrl
      ..text = draft.text
      ..selection = TextSelection.collapsed(offset: draft.cursor);
    _composerFocus.requestFocus();
  }

  void _dismissReply({bool clearComposerPrefix = true}) {
    final draft = _replyDraft;
    if (draft != null && clearComposerPrefix) {
      final rest = stripLeadingReplyDraft(_bodyCtrl.text, draft.prefix);
      _bodyCtrl
        ..text = rest
        ..selection = TextSelection.collapsed(offset: rest.length);
    }
    if (_replyDraft != null || _replyChipHandle != null) {
      setState(() {
        _replyDraft = null;
        _replyChipHandle = null;
      });
    }
  }

  Widget? _commentMedia(ArticleComment comment) {
    final url = comment.imageUrl?.trim();
    if (url == null || url.isEmpty || !comment.isPublished) return null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedNetworkImageWithFallback(imageUrl: url, fit: BoxFit.cover),
      ),
    );
  }

  Future<void> _submitText() async {
    if (!_isAuth()) {
      _promptLogin();
      return;
    }
    final l10n = AppLocalizations.of(context);
    final code = await ref
        .read(articleCommentListControllerProvider(widget.articleId).notifier)
        .create(_bodyCtrl.text);
    if (!mounted) return;
    if (code == null) {
      _bodyCtrl.clear();
      _dismissReply(clearComposerPrefix: false);
      showFToast(
        context: context,
        title: Text(l10n.commentSent),
        variant: FToastVariant.primary,
      );
    } else if (code == 'empty') {
      showFToast(
        context: context,
        title: Text(l10n.commentEditEmpty),
        variant: FToastVariant.destructive,
      );
    } else {
      showFToast(
        context: context,
        title: Text(l10n.encyclopediaCommentFailed),
        variant: FToastVariant.destructive,
      );
    }
  }

  Future<void> _editComment(ArticleComment comment) async {
    final l10n = AppLocalizations.of(context);
    final saved = await showThreadTextEditSheet(
      context,
      title: l10n.commentEditTitle,
      initialBody: comment.body.trim(),
      saveLabel: l10n.commentEditSave,
      onSave: (body) async {
        if (body.isEmpty) return l10n.commentEditEmpty;
        final code = await ref
            .read(
              articleCommentListControllerProvider(widget.articleId).notifier,
            )
            .updateComment(comment, body);
        if (code == null) return null;
        if (code == 'empty') return l10n.commentEditEmpty;
        return l10n.encyclopediaCommentFailed;
      },
    );
    if (!mounted || saved == null) return;
    showFToast(
      context: context,
      title: Text(l10n.commentEditSuccess),
      variant: FToastVariant.primary,
    );
  }

  Future<void> _deleteComment(ArticleComment comment) async {
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
                  title: Text(l10n.commentDeleteTitle),
                  subtitle: Text(l10n.commentDeleteBody),
                ),
                FTile(
                  title: const Text(''),
                  suffix: FButton(
                    variant: FButtonVariant.destructive,
                    onPress: () => Navigator.of(sheetContext).pop(true),
                    child: Text(l10n.commentDeleteConfirm),
                  ),
                ),
                FTile(
                  title: const Text(''),
                  suffix: FButton(
                    onPress: () => Navigator.of(sheetContext).pop(false),
                    child: Text(l10n.commentDeleteCancel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    final code = await ref
        .read(articleCommentListControllerProvider(widget.articleId).notifier)
        .delete(comment);
    if (!mounted) return;
    showFToast(
      context: context,
      title: Text(
        code == null ? l10n.commentDeleted : l10n.encyclopediaCommentFailed,
      ),
      variant: code == null
          ? FToastVariant.primary
          : FToastVariant.destructive,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authStatusProvider).value;
    final async = ref.watch(
      articleCommentListControllerProvider(widget.articleId),
    );
    final listState = async.value;
    final count = listState?.items.length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: theme.colors.mutedForeground,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.commentSectionTitle(count),
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: async.when(
              loading: () => const _CommentsSkeleton(),
              error: (_, _) => _CommentsError(
                message: l10n.commentLoadFailed,
                onRetry: () => ref.invalidate(
                  articleCommentListControllerProvider(widget.articleId),
                ),
              ),
              data: (state) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.items.isEmpty)
                    Text(
                      l10n.commentEmpty,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    )
                  else
                    ...state.items.map((c) {
                      final canManage =
                          auth != null &&
                          c.isPublished &&
                          c.isOwner(auth.userId);
                      return ThreadMessageRow(
                        username: c.user.username,
                        displayName: c.user.displayName,
                        avatarUrl: c.user.avatarUrl,
                        isVerifier: c.user.isVerifier,
                        body: c.body,
                        dateLabel: formatRelativeCompact(
                          DateTime.tryParse(c.createdAt ?? ''),
                        ),
                        metaParts: [
                          if (c.isTakenDown) l10n.commentTakenDownModerator,
                          if (c.isDeletedByAuthor) l10n.commentDeletedByAuthor,
                        ],
                        isRedacted: !c.isPublished,
                        isEdited: c.isEdited,
                        editedLabel: l10n.commentEdited,
                        onEdit: canManage ? () => _editComment(c) : null,
                        onDelete: canManage ? () => _deleteComment(c) : null,
                        onReply: c.isPublished ? () => _startReply(c) : null,
                        onUsernameTap: isLinkablePublicUsername(c.user.username)
                            ? () =>
                                  UserProfileRouter.open(context, c.user.username!)
                            : null,
                        onMentionTap: (mentionedUsername) =>
                            UserProfileRouter.open(context, mentionedUsername),
                        media: _commentMedia(c),
                      );
                    }),
                  if (state.hasMore)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FButton(
                          variant: FButtonVariant.ghost,
                          onPress: state.isLoadingMore
                              ? null
                              : () => ref
                                    .read(
                                      articleCommentListControllerProvider(
                                        widget.articleId,
                                      ).notifier,
                                    )
                                    .loadMore(),
                          prefix: state.isLoadingMore
                              ? const FCircularProgress()
                              : null,
                          child: Text(
                            state.isLoadingMore
                                ? l10n.commentLoading
                                : l10n.commentLoadMore,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: !_isAuth()
              ? ThreadLoginPrompt(
                  message: l10n.commentLoginComposerPrompt,
                  onLogin: _promptLogin,
                )
              : ThreadComposer(
                  controller: _bodyCtrl,
                  focusNode: _composerFocus,
                  isSubmitting: listState?.isSubmitting ?? false,
                  onSubmit: _submitText,
                  hint: l10n.encyclopediaCommentPlaceholder,
                  replyBanner: _replyDraft == null
                      ? null
                      : ThreadReplyBanner(
                          title: _replyChipHandle != null
                              ? l10n.threadReplyingTo(_replyChipHandle!)
                              : l10n.threadReply,
                          subtitle: _replyDraft!.quotePreview,
                          onDismiss: _dismissReply,
                        ),
                  suggestBuilder: _buildMentionSuggest,
                ),
        ),
      ],
    );
  }
}

class _CommentsSkeleton extends StatelessWidget {
  const _CommentsSkeleton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < 2; i++)
          ThreadMessageRow(
            username: l10n.commentSkeletonUsername,
            displayName: l10n.commentSkeletonName,
            avatarUrl: null,
            isVerifier: false,
            body: l10n.commentSkeletonBody,
            dateLabel: l10n.commentSkeletonDate,
          ),
      ],
    );
  }
}

class _CommentsError extends StatelessWidget {
  const _CommentsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FAlert(
      variant: FAlertVariant.destructive,
      title: Text(message),
      subtitle: Text(AppLocalizations.of(context).commentLoadRetry),
    );
  }
}
