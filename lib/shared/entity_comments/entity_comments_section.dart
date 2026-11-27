import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/utils/format_datetime.dart';
import '../../features/auth/auth_router.dart';
import '../../features/auth/presentation/providers/auth_status_providers.dart';
import '../../features/comment/data/providers/comment_data_providers.dart';
import '../../features/comment/domain/entities/comment_image.dart';
import '../../features/comment/presentation/providers/mention_suggest_providers.dart';
import '../../features/comment/presentation/widgets/mention_suggest_overlay.dart';
import '../../features/jinye/data/jinye_providers.dart';
import '../../features/user_profile/user_profile_router.dart';
import '../../features/vote/domain/entities/vote_target.dart';
import '../../features/vote/presentation/providers/vote_providers.dart';
import '../../features/vote/presentation/widgets/vote_buttons.dart';
import '../../l10n/app_localizations.dart';
import '../span_lemma/span_lemma_exports.dart';
import '../stickers/sticker_providers.dart';
import '../stickers/sticker_sheet.dart';
import '../stickers/sticker_view.dart';
import '../ugc_comment_lemma/ugc_comment_lemma_interaction.dart';
import '../utils/error_bottom_sheet.dart';
import '../utils/image_sheet_drawer.dart';
import '../utils/photo_pick_constants.dart';
import '../utils/public_account_name.dart';
import '../utils/thread_reply_draft.dart';
import '../widgets/image_crop_page.dart';
import '../widgets/record_thread_audio_sheet.dart';
import '../widgets/slide_fade_in.dart';
import '../widgets/thread_audio_player.dart';
import '../widgets/thread_comment_image.dart';
import '../widgets/thread_edit_sheets.dart';
import '../widgets/thread_message.dart';
import 'entity_comment.dart';
import 'entity_comment_providers.dart';

typedef EntityCommentCopy = ({
  String Function(int count) title,
  String empty,
  String hint,
});

EntityCommentCopy entityCommentCopy(
  AppLocalizations l10n,
  EntityCommentTarget target,
) {
  return switch (target) {
    EntityCommentTarget.word => (
        title: (c) => l10n.encyclopediaCommentsTitle,
        empty: l10n.commentEmpty,
        hint: l10n.encyclopediaCommentPlaceholder,
      ),
    EntityCommentTarget.article => (
        title: (c) => l10n.encyclopediaCommentsTitle,
        empty: l10n.commentEmpty,
        hint: l10n.encyclopediaCommentPlaceholder,
      ),
    EntityCommentTarget.jinye => (
        title: (c) => l10n.jinyeCommentsTitle,
        empty: l10n.jinyeDiscussionEmpty,
        hint: l10n.jinyeCommentHint,
      ),
    EntityCommentTarget.place => (
        title: (c) => l10n.placeCommentsTitle,
        empty: l10n.placeCommentsEmpty,
        hint: l10n.placeCommentHint,
      ),
    EntityCommentTarget.usaha => (
        title: (c) => l10n.usahaCommentsTitle,
        empty: l10n.usahaCommentsEmpty,
        hint: l10n.usahaCommentHint,
      ),
    EntityCommentTarget.cuisine => (
        title: (c) => l10n.cuisineCommentsTitle,
        empty: l10n.cuisineCommentsEmpty,
        hint: l10n.cuisineCommentHint,
      ),
    EntityCommentTarget.event => (
        title: (c) => l10n.eventCommentsTitle,
        empty: l10n.eventCommentsEmpty,
        hint: l10n.eventCommentHint,
      ),
    EntityCommentTarget.karya => (
        title: (c) => l10n.karyaCommentsTitle,
        empty: l10n.karyaCommentsEmpty,
        hint: l10n.karyaCommentHint,
      ),
  };
}

Future<void> showEntityCommentsSheet(
  BuildContext context, {
  required EntityCommentTarget target,
  required String entityId,
}) {
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
          child: EntityCommentsSection(target: target, entityId: entityId),
        ),
      );
    },
  );
}

class EntityCommentEntryBar extends ConsumerWidget {
  const EntityCommentEntryBar({
    super.key,
    required this.target,
    required this.entityId,
  });

  final EntityCommentTarget target;
  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final key = EntityCommentListKey(target, entityId);
    final async = ref.watch(entityCommentListControllerProvider(key));
    final count = async.value?.totalLoadedCount ?? 0;
    final copy = entityCommentCopy(l10n, target);

    return Material(
      color: theme.colors.background,
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: () => showEntityCommentsSheet(
            context,
            target: target,
            entityId: entityId,
          ),
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
                Expanded(
                  child: Text(
                    '${copy.title(count)} ($count)',
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class EntityCommentsSection extends ConsumerStatefulWidget {
  const EntityCommentsSection({
    super.key,
    required this.target,
    required this.entityId,
  });

  final EntityCommentTarget target;
  final String entityId;

  @override
  ConsumerState<EntityCommentsSection> createState() =>
      _EntityCommentsSectionState();
}

class _EntityCommentsSectionState extends ConsumerState<EntityCommentsSection> {
  final _bodyCtrl = TextEditingController();
  final _composerFocus = FocusNode();
  CommentImageStaging? _stagingImage;
  String? _localPreviewPath;
  String? _stagingStickerId;
  bool _uploadingImage = false;
  String? _replyParentId;
  ThreadReplyDraft? _replyDraft;
  String? _replyChipHandle;
  bool _initialLoaded = false;
  final Set<String> _seenIds = <String>{};
  final Set<String> _justAddedIds = <String>{};

  void _syncSeenIds(List<EntityComment> items, {required bool isLoadingMore}) {
    if (!_initialLoaded) {
      for (final c in items) {
        _seenIds.add(c.id);
        for (final r in c.replies) {
          _seenIds.add(r.id);
        }
      }
      _initialLoaded = true;
      return;
    }
    for (final c in items) {
      if (_seenIds.add(c.id) && !isLoadingMore) {
        _justAddedIds.add(c.id);
      }
      for (final r in c.replies) {
        if (_seenIds.add(r.id) && !isLoadingMore) {
          _justAddedIds.add(r.id);
        }
      }
    }
  }

  EntityCommentListKey get _key =>
      EntityCommentListKey(widget.target, widget.entityId);

  @override
  void initState() {
    super.initState();
    _bodyCtrl.addListener(_onBodyChanged);
  }

  @override
  void dispose() {
    _bodyCtrl
      ..removeListener(_onBodyChanged)
      ..dispose();
    _composerFocus.dispose();
    super.dispose();
  }

  void _onBodyChanged() {
    ref.read(mentionSuggestControllerProvider.notifier).onTextChanged(
          _bodyCtrl.text,
          _bodyCtrl.selection.baseOffset,
        );
  }

  bool _isAuth() => ref.read(authStatusProvider).value?.isAuth == true;

  void _promptLogin() {
    context.push(AuthRouter.login.path);
  }

  void _startReply({
    required EntityComment target,
    required String rootParentId,
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
      _replyParentId = rootParentId;
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
    if (clearComposerPrefix && draft != null && _bodyCtrl.text == draft.text) {
      _bodyCtrl.clear();
    }
    if (_replyParentId != null ||
        _replyDraft != null ||
        _replyChipHandle != null) {
      setState(() {
        _replyParentId = null;
        _replyDraft = null;
        _replyChipHandle = null;
      });
    }
  }

  void _clearStagingPhoto() {
    setState(() {
      _stagingImage = null;
      _localPreviewPath = null;
    });
  }

  void _clearStagingSticker() {
    setState(() => _stagingStickerId = null);
  }

  Future<void> _pickCommentSticker() async {
    if (!_isAuth()) {
      _promptLogin();
      return;
    }
    if (_uploadingImage) return;
    final stickerId = await showCatalogStickerSheet(context);
    if (!mounted || stickerId == null) return;
    setState(() {
      _stagingStickerId = stickerId;
      _stagingImage = null;
      _localPreviewPath = null;
    });
  }

  Future<void> _pickCommentPhoto() async {
    if (!_isAuth()) {
      _promptLogin();
      return;
    }
    if (_uploadingImage) return;
    _clearStagingSticker();
    final l10n = AppLocalizations.of(context);
    showImageSheetDrawer(
      context,
      filePicker: false,
      mediaExplorerPicker: false,
      cropEnabled: false,
      maxWidth: kPhotoPickMaxWidth,
      maxHeight: kPhotoPickMaxHeight,
      imageQuality: kPhotoPickQuality,
      onRemoved: _clearStagingPhoto,
      onPicked: (file) async {
        await Future<void>.delayed(Duration.zero);
        if (!mounted) return;
        final File? cropped;
        try {
          cropped = await cropImage(context, file.path);
        } catch (_) {
          if (!mounted) return;
          showFToast(
            context: context,
            title: Text(l10n.commentPhotoUploadFailed),
            variant: FToastVariant.destructive,
          );
          return;
        }
        if (cropped == null || !mounted) return;
        final croppedFile = cropped;
        setState(() {
          _uploadingImage = true;
          _localPreviewPath = croppedFile.path;
          _stagingImage = null;
        });
        try {
          final staging = await ref
              .read(commentImageUploadServiceProvider)
              .upload(croppedFile);
          if (!mounted) return;
          setState(() {
            _stagingImage = staging;
            _uploadingImage = false;
          });
        } on CommentImageUploadUnavailable {
          if (!mounted) return;
          setState(() {
            _uploadingImage = false;
            _localPreviewPath = null;
          });
          showFToast(
            context: context,
            title: Text(l10n.commentPhotoUploadFailed),
            variant: FToastVariant.destructive,
          );
        } catch (_) {
          if (!mounted) return;
          setState(() {
            _uploadingImage = false;
            _localPreviewPath = null;
          });
          showFToast(
            context: context,
            title: Text(l10n.commentPhotoUploadFailed),
            variant: FToastVariant.destructive,
          );
        }
      },
    );
  }

  Widget? _buildAttachmentPreview(BuildContext context) {
    final stickerId = _stagingStickerId;
    if (stickerId != null) {
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
    if (_localPreviewPath == null && _stagingImage == null) return null;
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final path = _localPreviewPath;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 56,
            height: 56,
            child: path != null
                ? Image.file(File(path), fit: BoxFit.cover)
                : ColoredBox(color: theme.colors.secondary),
          ),
        ),
        const Gap(8),
        Expanded(
          child: Text(
            _uploadingImage ? l10n.commentPhotoUploading : l10n.commentAddPhoto,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
        if (_uploadingImage)
          const FCircularProgress(size: .sm)
        else
          FButton(
            variant: FButtonVariant.ghost,
            onPress: _clearStagingPhoto,
            child: Text(l10n.commentRemovePhoto),
          ),
      ],
    );
  }

  Widget? _commentMedia(EntityComment comment) {
    if (!comment.isPublished) return null;
    final parts = <Widget>[];
    if (comment.hasAudio) {
      parts.add(
        ThreadAudioPlayer(
          url: comment.audioUrl!,
          durationMs: comment.audioDurationMs,
        ),
      );
    }
    for (final img in comment.allImages) {
      parts.add(ThreadCommentImage(image: img));
    }
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

  Future<void> _submit() async {
    if (!_isAuth()) {
      _promptLogin();
      return;
    }
    if (_uploadingImage) return;
    final l10n = AppLocalizations.of(context);
    final hadPhoto = _stagingImage != null;
    final parentId = _replyParentId;
    final code = await ref
        .read(entityCommentListControllerProvider(_key).notifier)
        .create(
          _bodyCtrl.text,
          parentId: parentId,
          image: _stagingImage,
          stickerId: _stagingStickerId,
        );
    if (!mounted) return;
    if (code == null) {
      _bodyCtrl.clear();
      _clearStagingPhoto();
      _clearStagingSticker();
      _dismissReply(clearComposerPrefix: false);
      showFToast(context: context, title: Text(l10n.commentSent));
      if (hadPhoto) {
        showFToast(
          context: context,
          title: Text(l10n.commentPhotoCheckedNote),
        );
      }
    } else if (code == 'empty') {
      showFToast(context: context, title: Text(l10n.commentEditEmpty));
    } else {
      await showAppErrorSheet(context, message: l10n.commentSendFailed);
    }
  }

  Future<void> _recordAudioComment() async {
    if (!_isAuth()) {
      _promptLogin();
      return;
    }
    final caption = _bodyCtrl.text.trim();
    final parentId = _replyParentId;
    final l10n = AppLocalizations.of(context);
    await showRecordThreadAudioSheet(
      context,
      title: l10n.commentRecordTitle,
      subtitle: l10n.commentRecordBody,
      submitLabel: l10n.commentRecordSubmit,
      onSubmit: ({required audioFile, required durationMs}) async {
        final code = await ref
            .read(entityCommentListControllerProvider(_key).notifier)
            .createAudio(
              audioFile: audioFile,
              durationMs: durationMs,
              body: caption.isEmpty ? null : caption,
              parentId: parentId,
            );
        if (code == null) {
          if (mounted) {
            _bodyCtrl.clear();
            _dismissReply(clearComposerPrefix: false);
          }
          return null;
        }
        if (code == 'empty') return l10n.commentEditEmpty;
        return l10n.commentSendFailed;
      },
    );
  }

  Future<void> _confirmDelete(EntityComment comment) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showModalBottomSheet<bool>(
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
                  title: Text(l10n.commentDeleteConfirm),
                  onPress: () => Navigator.pop(sheetContext, true),
                ),
                FTile(
                  title: Text(l10n.commentDeleteCancel),
                  onPress: () => Navigator.pop(sheetContext, false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    final code = await ref
        .read(entityCommentListControllerProvider(_key).notifier)
        .deleteComment(comment);
    if (!mounted) return;
    if (code == null) {
      showFToast(context: context, title: Text(l10n.commentDeleted));
    } else {
      await showAppErrorSheet(context, message: l10n.commentDeleteFailed);
    }
  }

  Future<void> _edit(EntityComment comment) async {
    final l10n = AppLocalizations.of(context);
    final saved = await showThreadTextEditSheet(
      context,
      title: l10n.commentEditTitle,
      initialBody: comment.body,
      saveLabel: l10n.commentEditSave,
      onSave: (body) async {
        if (body.isEmpty) return l10n.commentEditEmpty;
        final code = await ref
            .read(entityCommentListControllerProvider(_key).notifier)
            .updateComment(comment, body);
        if (code == null) return null;
        if (code == 'empty') return l10n.commentEditEmpty;
        return l10n.commentSendFailed;
      },
    );
    if (!mounted || saved == null) return;
    showFToast(context: context, title: Text(l10n.commentEditSuccess));
  }

  Future<void> _showEditHistory(EntityComment comment) async {
    final l10n = AppLocalizations.of(context);
    try {
      final hist = await ref
          .read(entityCommentListControllerProvider(_key).notifier)
          .getEditHistory(comment);
      if (!mounted) return;
      await showThreadTextEditHistorySheet(
        context,
        title: l10n.commentEditHistoryTitle,
        history: ThreadTextEditHistory(
          currentBody: hist.currentBody,
          currentUpdatedAt: hist.updatedAt?.toIso8601String(),
          revisions: [
            for (final r in hist.revisions)
              ThreadTextEditRevision(
                body: r.body,
                createdAt: r.createdAt.toIso8601String(),
              ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      await showAppErrorSheet(
        context,
        message: l10n.commentEditHistoryFailed,
      );
    }
  }

  Widget _buildSingleCommentRow(
    BuildContext context, {
    required EntityComment comment,
    required String rootParentId,
    required String? myUserId,
    required bool isAuth,
  }) {
    final l10n = AppLocalizations.of(context);
    final published = comment.isPublished &&
        !comment.isTakenDown &&
        !comment.isDeletedByAuthor;
    final canManage =
        myUserId != null && myUserId == comment.userId && published;
    final bodyText = comment.isTakenDown
        ? l10n.commentTakenDownModerator
        : comment.isDeletedByAuthor
            ? l10n.commentDeletedByAuthor
            : comment.body;

    final List<JinyeLemmaLink> links;
    if (widget.target == EntityCommentTarget.jinye) {
      final detail = ref.watch(jinyeDetailProvider(widget.entityId)).value;
      links = (detail?.lemmaLinks ?? const <JinyeLemmaLink>[])
          .where((l) => l.commentId == comment.id)
          .toList();
    } else {
      links = comment.lemmaLinks;
    }

    final anchor = anchorForEntityCommentTarget(widget.target);
    final voteTarget = VoteTarget(
      type: widget.target.voteTargetType,
      id: comment.id,
    );
    final voteAsync = ref.watch(voteControllerProvider(voteTarget));

    return ThreadMessageRow(
      username: comment.username,
      displayName: comment.displayName,
      avatarUrl: comment.avatarUrl,
      isVerifier: comment.isVerifier,
      body: bodyText,
      bodyWidget: !published || bodyText.trim().isEmpty
          ? null
          : ThreadLemmaBody(
              body: comment.body,
              links: links,
              onMentionTap: (mentionedUsername) =>
                  UserProfileRouter.open(context, mentionedUsername),
              onWordTap: (span, link) async {
                if (anchor != null) {
                  await handleUgcCommentLemmaWordTap(
                    context,
                    ref,
                    sheetContextId: widget.entityId,
                    anchor: anchor,
                    hostId: widget.entityId,
                    commentId: comment.id,
                    span: span,
                    link: link,
                    isAuth: isAuth,
                    onLinked: () => ref.invalidate(
                      entityCommentListControllerProvider(_key),
                    ),
                  );
                } else {
                  final result = await showJinyeWordMeaningSheet(
                    context,
                    jinyeId: widget.entityId,
                    span: span,
                    link: link,
                    isAuth: isAuth,
                    commentId: comment.id,
                    onLinked: () =>
                        ref.invalidate(jinyeDetailProvider(widget.entityId)),
                  );
                  if (context.mounted) {
                    handleJinyeWordMeaningSheetResult(context, result);
                  }
                }
              },
            ),
      dateLabel: formatRelativeCompact(comment.createdAt),
      metaParts: [
        if (comment.isTakenDown) l10n.commentTakenDownModerator,
        if (comment.isDeletedByAuthor) l10n.commentDeletedByAuthor,
      ],
      isRedacted: !published,
      isEdited: comment.isEdited && published,
      editedLabel: l10n.commentEdited,
      onShowEditHistory:
          comment.isEdited && published ? () => _showEditHistory(comment) : null,
      onReply: published
          ? () => _startReply(target: comment, rootParentId: rootParentId)
          : null,
      onEdit: canManage ? () => _edit(comment) : null,
      onDelete: canManage ? () => _confirmDelete(comment) : null,
      onUsernameTap: isLinkablePublicUsername(comment.username)
          ? () => UserProfileRouter.open(
                context,
                comment.username!,
                displayName: comment.displayName,
              )
          : null,
      onMentionTap: (mentionedUsername) =>
          UserProfileRouter.open(context, mentionedUsername),
      media: _commentMedia(comment),
      footer: !published
          ? null
          : voteAsync.when(
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
                      title: Text(l10n.commentLoginPrompt),
                    );
                    _promptLogin();
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

  Widget _buildThreadTile(
    BuildContext context, {
    required EntityComment comment,
    required String? myUserId,
    required bool isAuth,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSingleCommentRow(
          context,
          comment: comment,
          rootParentId: comment.id,
          myUserId: myUserId,
          isAuth: isAuth,
        ),
        if (comment.replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final reply in comment.replies)
                  _buildSingleCommentRow(
                    context,
                    comment: reply,
                    // 1 tingkat: balas ke balasan tetap menempel ke root comment.
                    rootParentId: comment.id,
                    myUserId: myUserId,
                    isAuth: isAuth,
                  ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final copy = entityCommentCopy(l10n, widget.target);
    final async = ref.watch(entityCommentListControllerProvider(_key));
    final listState = async.value;
    final auth = ref.watch(authStatusProvider).value;
    final myUserId = auth?.userId;
    final isAuth = auth?.isAuth ?? false;
    final totalCount = listState?.totalLoadedCount ?? 0;

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
                  '${copy.title(totalCount)} ($totalCount)',
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
          child: async.when(
            loading: () => const Center(child: FCircularProgress()),
            error: (_, _) => Center(child: Text(l10n.commentLoadFailed)),
            data: (state) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        copy.empty,
                        textAlign: TextAlign.center,
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    )
                  else ...[
                    ...() {
                      _syncSeenIds(
                        state.items,
                        isLoadingMore: state.isLoadingMore,
                      );
                      return state.items.map(
                        (comment) => SlideFadeIn(
                          key: ValueKey('entity-comment-${comment.id}'),
                          animate: _justAddedIds.contains(comment.id),
                          child: _buildThreadTile(
                            context,
                            comment: comment,
                            myUserId: myUserId,
                            isAuth: isAuth,
                          ),
                        ),
                      );
                    }(),
                  ],
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
                                    entityCommentListControllerProvider(_key)
                                        .notifier,
                                  )
                                  .loadMore(),
                          prefix: state.isLoadingMore
                              ? const FCircularProgress(size: .sm)
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
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: !isAuth
                ? ThreadLoginPrompt(
                    message: l10n.commentLoginComposerPrompt,
                    onLogin: _promptLogin,
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MentionSuggestOverlay(
                        onSelect: (username) =>
                            insertIntoComposer(_bodyCtrl, username),
                      ),
                      if (_replyParentId != null) ...[
                        ThreadReplyBanner(
                          title: _replyChipHandle != null
                              ? l10n.threadReplyingTo(_replyChipHandle!)
                              : l10n.threadReply,
                          subtitle: _replyDraft?.quotePreview,
                          onDismiss: _dismissReply,
                        ),
                        const Gap(6),
                      ],
                      ThreadComposer(
                        controller: _bodyCtrl,
                        focusNode: _composerFocus,
                        isSubmitting: (listState?.isSubmitting ?? false) ||
                            _uploadingImage,
                        onSubmit: _submit,
                        onRecordAudio: _recordAudioComment,
                        onPickImage: _pickCommentPhoto,
                        onPickSticker: _pickCommentSticker,
                        attachmentPreview: _buildAttachmentPreview(context),
                        hint: copy.hint,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
