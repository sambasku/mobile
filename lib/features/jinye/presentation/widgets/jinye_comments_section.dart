import 'package:dio/dio.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/stickers/sticker_providers.dart';
import '../../../../shared/stickers/sticker_sheet.dart';
import '../../../../shared/stickers/sticker_view.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/utils/thread_reply_draft.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/thread_edit_sheets.dart';
import '../../../../shared/widgets/thread_message.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../comment/presentation/providers/mention_suggest_providers.dart';
import '../../../comment/presentation/widgets/mention_suggest_overlay.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../../vote/domain/entities/vote_target.dart';
import '../../../vote/presentation/providers/vote_providers.dart';
import '../../../vote/presentation/widgets/vote_buttons.dart';
import '../../data/jinye_providers.dart';
import '../../domain/jinye_models.dart';
import 'jinye_lemma_body.dart';
import 'jinye_link_lemma_sheet.dart';
import 'jinye_word_meaning_sheet.dart';
import 'jinye_word_picker_sheet.dart';

/// Buka thread komentar Jinye (pola sama [showWordCommentsSheet]).
Future<void> showJinyeCommentsSheet(BuildContext context, String jinyeId) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final media = MediaQuery.of(sheetContext);
      final height = (media.size.height - media.viewInsets.bottom) * 0.88;
      return Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: SizedBox(
          height: height,
          child: JinyeCommentsSection(jinyeId: jinyeId),
        ),
      );
    },
  );
}

/// Bar lengket di bawah detail Jinye - jumlah + buka sheet.
class JinyeCommentEntryBar extends ConsumerWidget {
  const JinyeCommentEntryBar({super.key, required this.jinyeId});

  final String jinyeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(jinyeCommentsProvider(jinyeId));
    final comments = async.value;
    final count = comments == null
        ? 0
        : comments.fold<int>(0, (n, c) => n + 1 + c.replies.length);

    // FScaffold Forui tidak menyediakan ancestor Material - bungkus sendiri
    // agar InkWell (splash) tidak throw "No Material widget found".
    return Material(
      color: theme.colors.background,
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: () => showJinyeCommentsSheet(context, jinyeId),
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

/// Thread komentar Jinye di dalam bottom sheet.
class JinyeCommentsSection extends ConsumerStatefulWidget {
  const JinyeCommentsSection({super.key, required this.jinyeId});

  final String jinyeId;

  @override
  ConsumerState<JinyeCommentsSection> createState() =>
      _JinyeCommentsSectionState();
}

class _JinyeCommentsSectionState extends ConsumerState<JinyeCommentsSection> {
  final _bodyCtrl = TextEditingController();
  final _composerFocus = FocusNode();
  ThreadReplyDraft? _replyDraft;
  String? _replyChipHandle;
  String? _replyParentId;
  String? _stagingStickerId;
  bool _submitting = false;

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
    ref.read(mentionSuggestControllerProvider.notifier).onTextChanged(
          _bodyCtrl.text,
          _bodyCtrl.selection.baseOffset,
        );
  }

  bool _isAuth() => ref.read(authStatusProvider).value?.isAuth ?? false;

  void _promptLogin() {
    showFToast(
      context: context,
      title: Text(AppLocalizations.of(context).jinyeLoginFirst),
    );
    context.push('/login');
  }

  void _dismissReply({bool clearComposerPrefix = true}) {
    final draft = _replyDraft;
    if (draft != null && clearComposerPrefix) {
      final rest = stripLeadingReplyDraft(_bodyCtrl.text, draft.prefix);
      _bodyCtrl
        ..text = rest
        ..selection = TextSelection.collapsed(offset: rest.length);
    }
    if (_replyDraft != null ||
        _replyChipHandle != null ||
        _replyParentId != null) {
      setState(() {
        _replyDraft = null;
        _replyChipHandle = null;
        _replyParentId = null;
      });
    }
  }

  void _startReply({
    required JinyeComment target,
    required String parentId,
  }) {
    if (!_isAuth()) {
      _promptLogin();
      return;
    }
    final auth = ref.read(authStatusProvider).value;
    final draft = buildThreadReplyDraft(
      username: target.username,
      body: target.body,
      currentUsername: auth?.username,
    );
    final chipHandle = isLinkablePublicUsername(target.username)
        ? target.username
        : null;
    setState(() {
      _replyParentId = parentId;
      _replyDraft = draft;
      _replyChipHandle = chipHandle;
    });
    _bodyCtrl
      ..text = draft.text
      ..selection = TextSelection.collapsed(offset: draft.cursor);
    _composerFocus.requestFocus();
  }

  void _clearStagingSticker() {
    setState(() => _stagingStickerId = null);
  }

  Future<void> _pickCommentSticker() async {
    if (!_isAuth()) {
      _promptLogin();
      return;
    }
    if (_submitting) return;
    final stickerId = await showCatalogStickerSheet(context);
    if (!mounted || stickerId == null) return;
    setState(() => _stagingStickerId = stickerId);
  }

  Widget? _buildStickerPreview(BuildContext context) {
    final stickerId = _stagingStickerId;
    if (stickerId == null) return null;
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final sticker =
        ref.watch(stickerLookupProvider(stickerId)).asData?.value;
    return Row(
      children: [
        StickerIdView(
          stickerId: stickerId,
          sticker: sticker,
          size: 56,
        ),
        const Gap(8),
        Expanded(
          child: Text(
            l10n.commentAddSticker,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
        FButton.icon(
          variant: FButtonVariant.ghost,
          onPress: _clearStagingSticker,
          child: Icon(
            FLucideIcons.x,
            size: 16,
            color: theme.colors.destructive,
            semanticLabel: l10n.commentRemoveSticker,
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_isAuth()) {
      _promptLogin();
      return;
    }
    final trimmed = _bodyCtrl.text.trim();
    final stickerId = _stagingStickerId;
    if ((trimmed.isEmpty && stickerId == null) || _submitting) return;
    setState(() => _submitting = true);
    try {
      await ref.read(jinyeRepositoryProvider).createComment(
            jinyeId: widget.jinyeId,
            body: trimmed,
            parentId: _replyParentId,
            stickerId: stickerId,
          );
      _bodyCtrl.clear();
      _clearStagingSticker();
      _dismissReply(clearComposerPrefix: false);
      ref.invalidate(jinyeCommentsProvider(widget.jinyeId));
      ref.invalidate(jinyeDetailProvider(widget.jinyeId));
      if (!mounted) return;
      showFToast(context: context, title: Text(l10n.jinyeCommentSent));
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message']
          : null;
      await showAppErrorSheet(
        context,
        message: msg is String && msg.isNotEmpty
            ? msg
            : l10n.jinyeCommentFailed,
      );
    } catch (_) {
      if (!mounted) return;
      await showAppErrorSheet(context, message: l10n.jinyeCommentFailed);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _editComment(JinyeComment comment) async {
    final l10n = AppLocalizations.of(context);
    final saved = await showThreadTextEditSheet(
      context,
      title: l10n.commentEditTitle,
      initialBody: comment.body.trim(),
      saveLabel: l10n.commentEditSave,
      onSave: (body) async {
        if (body.isEmpty) return l10n.commentEditEmpty;
        try {
          await ref.read(jinyeRepositoryProvider).updateComment(
                jinyeId: widget.jinyeId,
                commentId: comment.id,
                body: body,
              );
          ref.invalidate(jinyeCommentsProvider(widget.jinyeId));
          return null;
        } on DioException catch (e) {
          final msg = e.response?.data is Map
              ? (e.response!.data as Map)['message']
              : null;
          return msg is String && msg.isNotEmpty
              ? msg
              : l10n.jinyeCommentFailed;
        } catch (_) {
          return l10n.jinyeCommentFailed;
        }
      },
    );
    if (!mounted || saved == null) return;
    showFToast(
      context: context,
      title: Text(l10n.commentEditSuccess),
    );
  }

  Future<void> _showCommentEditHistory(JinyeComment comment) async {
    final l10n = AppLocalizations.of(context);
    try {
      final history = await ref.read(jinyeRepositoryProvider).commentEditHistory(
            jinyeId: widget.jinyeId,
            commentId: comment.id,
          );
      if (!mounted) return;
      await showThreadTextEditHistorySheet(
        context,
        title: l10n.commentEditHistoryTitle,
        history: ThreadTextEditHistory(
          currentBody: history.currentBody,
          currentUpdatedAt: history.currentUpdatedAt,
          revisions: [
            for (final r in history.revisions)
              ThreadTextEditRevision(body: r.body, createdAt: r.createdAt),
          ],
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message']
          : null;
      await showAppErrorSheet(
        context,
        message: msg is String && msg.isNotEmpty
            ? msg
            : l10n.jinyeEditHistoryFailed,
      );
    } catch (_) {
      if (!mounted) return;
      await showAppErrorSheet(context, message: l10n.jinyeEditHistoryFailed);
    }
  }

  Future<void> _deleteComment(JinyeComment comment) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      barrierColor: Colors.black54,
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
    try {
      await ref.read(jinyeRepositoryProvider).deleteComment(
            jinyeId: widget.jinyeId,
            commentId: comment.id,
          );
      ref.invalidate(jinyeCommentsProvider(widget.jinyeId));
      ref.invalidate(jinyeDetailProvider(widget.jinyeId));
      if (!mounted) return;
      showFToast(context: context, title: Text(l10n.commentDeleted));
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message']
          : null;
      await showAppErrorSheet(
        context,
        message: msg is String && msg.isNotEmpty
            ? msg
            : l10n.jinyeCommentFailed,
      );
    } catch (_) {
      if (!mounted) return;
      await showAppErrorSheet(context, message: l10n.jinyeCommentFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final isAuth = _isAuth();
    final async = ref.watch(jinyeCommentsProvider(widget.jinyeId));
    final comments = async.value;
    final count = comments == null
        ? 0
        : comments.fold<int>(0, (n, c) => n + 1 + c.replies.length);

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
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: FCircularProgress()),
              ),
              error: (_, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Text(l10n.jinyeCommentsLoadFailed),
                    const Gap(12),
                    FButton(
                      onPress: () => ref.invalidate(
                        jinyeCommentsProvider(widget.jinyeId),
                      ),
                      child: Text(l10n.commonRetry),
                    ),
                  ],
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return Text(
                    l10n.jinyeDiscussionEmpty,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  );
                }
                final auth = ref.watch(authStatusProvider).value;
                return Column(
                  children: [
                    for (final c in items)
                      _JinyeCommentTile(
                        comment: c,
                        authUserId: auth?.userId,
                        onReply: (target) => _startReply(
                          target: target,
                          parentId: c.id,
                        ),
                        onEdit: _editComment,
                        onDelete: _deleteComment,
                        onShowEditHistory: _showCommentEditHistory,
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: !isAuth
              ? ThreadLoginPrompt(
                  message: l10n.commentLoginComposerPrompt,
                  onLogin: _promptLogin,
                )
              : ThreadComposer(
                  controller: _bodyCtrl,
                  focusNode: _composerFocus,
                  isSubmitting: _submitting,
                  onSubmit: _submit,
                  onPickSticker: _pickCommentSticker,
                  attachmentPreview: _buildStickerPreview(context),
                  hint: l10n.jinyeCommentHint,
                  replyBanner: _replyDraft == null
                      ? null
                      : ThreadReplyBanner(
                          title: _replyChipHandle != null
                              ? l10n.threadReplyingTo(_replyChipHandle!)
                              : l10n.threadReply,
                          subtitle: _replyDraft!.quotePreview,
                          onDismiss: _dismissReply,
                        ),
                  suggestBuilder: (_) => MentionSuggestOverlay(
                    onSelect: (username) =>
                        insertIntoComposer(_bodyCtrl, username),
                  ),
                ),
        ),
      ],
    );
  }
}

class _JinyeCommentTile extends ConsumerWidget {
  const _JinyeCommentTile({
    required this.comment,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
    required this.onShowEditHistory,
    this.authUserId,
  });

  final JinyeComment comment;
  final String? authUserId;
  final ValueChanged<JinyeComment> onReply;
  final ValueChanged<JinyeComment> onEdit;
  final ValueChanged<JinyeComment> onDelete;
  final ValueChanged<JinyeComment> onShowEditHistory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _JinyeThreadComment(
          comment: comment,
          authUserId: authUserId,
          onReply: () => onReply(comment),
          onEdit: () => onEdit(comment),
          onDelete: () => onDelete(comment),
          onShowEditHistory: () => onShowEditHistory(comment),
        ),
        if (comment.replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Column(
              children: [
                for (final r in comment.replies)
                  _JinyeThreadComment(
                    comment: r,
                    authUserId: authUserId,
                    // 1 tingkat: balas nested tetap ke root comment.
                    onReply: () => onReply(r),
                    onEdit: () => onEdit(r),
                    onDelete: () => onDelete(r),
                    onShowEditHistory: () => onShowEditHistory(r),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _JinyeThreadComment extends ConsumerWidget {
  const _JinyeThreadComment({
    required this.comment,
    this.authUserId,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onShowEditHistory,
  });

  final JinyeComment comment;
  final String? authUserId;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShowEditHistory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final voteTarget = VoteTarget(type: 'jinye_comment', id: comment.id);
    final voteAsync = ref.watch(voteControllerProvider(voteTarget));
    final auth = ref.watch(authStatusProvider).value;
    final isAuth = auth?.isAuth ?? false;
    final canManage =
        comment.isPublished && comment.isOwner(authUserId ?? auth?.userId);
    final detail = ref.watch(jinyeDetailProvider(comment.jinyeId)).value;
    final links = (detail?.lemmaLinks ?? const <JinyeLemmaLink>[])
        .where((l) => l.commentId == comment.id)
        .toList();
    final isVerifier = auth?.role == 'admin' ||
        auth?.role == 'root' ||
        auth?.role == 'reviewer';
    final isOwner =
        isAuth && auth?.userId != null && auth!.userId == comment.userId;
    final bodyText = comment.body.trim();

    return ThreadMessageRow(
      username: comment.username,
      displayName: comment.displayName,
      avatarUrl: comment.avatarUrl,
      body: bodyText,
      bodyWidget: bodyText.isEmpty
          ? null
          : JinyeLemmaBody(
              body: comment.body,
              links: links,
              style: theme.typography.body.sm.copyWith(height: 1.35),
              onLinkLongPress: (link) => _showCommentLemmaLinkActions(
                context,
                ref,
                jinyeId: comment.jinyeId,
                link: link,
                isAuth: isAuth,
                isOwner: isOwner,
                isVerifier: isVerifier,
              ),
              onWordTap: (span, link) => _showCommentWordMeaning(
                context,
                ref,
                jinyeId: comment.jinyeId,
                commentId: comment.id,
                span: span,
                link: link,
                isAuth: isAuth,
              ),
            ),
      dateLabel: formatRelativeCompact(comment.createdAt),
      media: _jinyeCommentMedia(context, ref, comment),
      isEdited: comment.isEdited,
      editedLabel: l10n.commentEdited,
      onShowEditHistory:
          comment.isEdited ? onShowEditHistory : null,
      onEdit: canManage ? onEdit : null,
      onDelete: canManage ? onDelete : null,
      onUsernameTap: isLinkablePublicUsername(comment.username)
          ? () => UserProfileRouter.open(context, comment.username!)
          : null,
      onMentionTap: (mentionedUsername) =>
          UserProfileRouter.open(context, mentionedUsername),
      onReply: comment.isPublished ? onReply : null,
      footer: voteAsync.when(
        loading: () => const VoteButtonsSkeleton(compact: true),
        error: (_, _) => const SizedBox.shrink(),
        data: (view) => VoteButtons(
          upvotes: view.upvotes,
          downvotes: view.downvotes,
          myVote: view.myVote,
          compact: true,
          onVote: (value) async {
            if (!isAuth) {
              showFToast(
                context: context,
                title: Text(l10n.jinyeLoginFirst),
              );
              context.push('/login');
              return;
            }
            final failure = await ref
                .read(voteControllerProvider(voteTarget).notifier)
                .toggle(value);
            if (failure != null && context.mounted) {
              showFToast(
                context: context,
                title: Text(failure.message),
                variant: FToastVariant.destructive,
              );
            }
          },
        ),
      ),
    );
  }
}

Widget? _jinyeCommentMedia(
  BuildContext context,
  WidgetRef ref,
  JinyeComment comment,
) {
  final parts = <Widget>[];
  if (comment.hasSticker) {
    final sticker = ref
        .watch(stickerLookupProvider(comment.stickerId!))
        .asData
        ?.value;
    parts.add(
      Align(
        alignment: Alignment.centerLeft,
        child: StickerIdView(
          stickerId: comment.stickerId!,
          sticker: sticker,
          size: 96,
        ),
      ),
    );
  }
  final l10n = AppLocalizations.of(context);
  final theme = context.theme;
  final displayable =
      comment.images.where((i) => i.displaySource != null).toList();
  if (displayable.isEmpty) {
    if (comment.images.isNotEmpty) {
      parts.add(
        Text(
          l10n.jinyePhotosPendingReview,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      );
    }
  } else {
    parts.add(
      SizedBox(
        height: 72,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: displayable.length,
          separatorBuilder: (_, _) => const Gap(6),
          itemBuilder: (context, index) {
            final src = displayable[index].displaySource!;
            final url = displayImageUrl(src, width: 200) ?? src;
            return ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImageWithFallback(
                  imageUrl: url,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  if (parts.isEmpty) return null;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < parts.length; i++) ...[
        if (i > 0) const Gap(6),
        parts[i],
      ],
    ],
  );
}

Future<void> _showCommentWordMeaning(
  BuildContext context,
  WidgetRef ref, {
  required String jinyeId,
  required String commentId,
  required JinyeSpanSelection span,
  JinyeLemmaLink? link,
  required bool isAuth,
}) async {
  final result = await showJinyeWordMeaningSheet(
    context,
    jinyeId: jinyeId,
    span: span,
    link: link,
    isAuth: isAuth,
    commentId: commentId,
    onLinked: () {
      ref.invalidate(jinyeDetailProvider(jinyeId));
    },
  );
  if (!context.mounted || result == null) return;
  if (result == 'login') {
    context.push('/login');
    return;
  }
  const contributePrefix = 'contribute:';
  if (result.startsWith(contributePrefix)) {
    final lemma =
        Uri.decodeComponent(result.substring(contributePrefix.length));
    context.push(
      '/contribute?lemma=${Uri.encodeQueryComponent(lemma)}',
    );
    return;
  }
  context.push('/words/$result');
}

Future<void> _showCommentLemmaLinkActions(
  BuildContext context,
  WidgetRef ref, {
  required String jinyeId,
  required JinyeLemmaLink link,
  required bool isAuth,
  required bool isOwner,
  required bool isVerifier,
}) async {
  final l10n = AppLocalizations.of(context);
  final action = await showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FTileGroup(
            children: [
              FTile(
                title: Text(l10n.jinyeLemmaOpenWord),
                onPress: () => Navigator.pop(context, 'open'),
              ),
              if (isAuth && !link.isPendingCorrection)
                FTile(
                  title: Text(l10n.jinyeLemmaProposeCorrection),
                  onPress: () => Navigator.pop(context, 'correct'),
                ),
              if (link.isPendingCorrection && isVerifier) ...[
                FTile(
                  title: Text(l10n.jinyeLemmaApproveCorrection),
                  onPress: () => Navigator.pop(context, 'approve'),
                ),
                FTile(
                  title: Text(l10n.jinyeLemmaRejectCorrection),
                  onPress: () => Navigator.pop(context, 'reject'),
                ),
              ],
              if (isOwner || isVerifier)
                FTile(
                  title: Text(l10n.jinyeLemmaDeleteLink),
                  onPress: () => Navigator.pop(context, 'delete'),
                ),
              FTile(
                title: Text(l10n.commonCancel),
                onPress: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  if (action == null || !context.mounted) return;

  final repo = ref.read(jinyeRepositoryProvider);
  try {
    switch (action) {
      case 'open':
        context.push('/words/${link.wordId}');
        return;
      case 'correct':
        if (!isAuth) {
          showFToast(context: context, title: Text(l10n.jinyeLoginFirst));
          context.push('/login');
          return;
        }
        final word = await showJinyeWordPickerSheet(
          context,
          initialQuery: link.lemma ?? '',
        );
        if (word == null || !context.mounted) return;
        await repo.proposeLemmaCorrection(
          jinyeId: jinyeId,
          linkId: link.id,
          wordId: word.id,
        );
        if (context.mounted) {
          showFToast(
            context: context,
            title: Text(l10n.jinyeLemmaCorrectionSuccess),
          );
        }
      case 'approve':
      case 'reject':
        await repo.resolveLemmaCorrection(
          jinyeId: jinyeId,
          linkId: link.id,
          action: action,
        );
        if (context.mounted) {
          showFToast(
            context: context,
            title: Text(l10n.jinyeLemmaResolveSuccess),
          );
        }
      case 'delete':
        await repo.deleteLemmaLink(jinyeId: jinyeId, linkId: link.id);
        if (context.mounted) {
          showFToast(
            context: context,
            title: Text(l10n.jinyeLemmaDeleteSuccess),
          );
        }
      default:
        return;
    }
    ref.invalidate(jinyeDetailProvider(jinyeId));
  } on DioException catch (e) {
    if (!context.mounted) return;
    final msg = e.response?.data is Map
        ? (e.response!.data as Map)['message']
        : null;
    await showAppErrorSheet(
      context,
      message: msg is String && msg.isNotEmpty
          ? msg
          : l10n.jinyeLemmaDeleteFailed,
    );
  } catch (_) {
    if (!context.mounted) return;
    await showAppErrorSheet(context, message: l10n.jinyeLemmaDeleteFailed);
  }
}
