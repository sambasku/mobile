import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/models/external_link.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/utils/thread_reply_draft.dart';
import '../../../../shared/widgets/thread_edit_sheets.dart';
import '../../../../shared/widgets/thread_message.dart';
import '../../data/discussion_providers.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../../vote/presentation/widgets/vote_buttons.dart';
import '../../domain/discussion_models.dart';
import '../providers/discussion_list_providers.dart';
import '../widgets/discussion_image_thumb.dart';
import '../widgets/discussion_reply_audio_player.dart';
import '../widgets/record_discussion_reply_sheet.dart';
import '../../../comment/presentation/providers/mention_suggest_providers.dart';
import '../../../comment/presentation/widgets/mention_suggest_overlay.dart';
import '../../../../l10n/app_localizations.dart';

/// Detail diskusi + thread balasan.
class DiscussionDetailPage extends ConsumerStatefulWidget {
  const DiscussionDetailPage({super.key, required this.id});

  final String id;

  @override
  ConsumerState<DiscussionDetailPage> createState() =>
      _DiscussionDetailPageState();
}

class _DiscussionDetailPageState extends ConsumerState<DiscussionDetailPage> {
  late final TextEditingController _replyCtrl;
  final _composerFocus = FocusNode();
  ThreadReplyDraft? _replyDraft;
  String? _replyChipHandle;

  @override
  void initState() {
    super.initState();
    _replyCtrl = TextEditingController();
    _replyCtrl.addListener(_onReplyChanged);
  }

  @override
  void dispose() {
    _replyCtrl.removeListener(_onReplyChanged);
    _replyCtrl.dispose();
    _composerFocus.dispose();
    super.dispose();
  }

  void _startReply({
    required String? username,
    required String? body,
  }) {
    if (!_isAuth()) {
      _promptLogin();
      return;
    }
    final auth = ref.read(authStatusProvider).value;
    final draft = buildThreadReplyDraft(
      username: username,
      body: body,
      currentUsername: auth?.username,
    );
    final chipHandle =
        isLinkablePublicUsername(username) ? username : null;
    setState(() {
      _replyDraft = draft;
      _replyChipHandle = chipHandle;
    });
    _replyCtrl
      ..text = draft.text
      ..selection = TextSelection.collapsed(offset: draft.cursor);
    _composerFocus.requestFocus();
  }

  void _dismissReply({bool clearComposerPrefix = true}) {
    final draft = _replyDraft;
    if (draft != null && clearComposerPrefix) {
      final rest = stripLeadingReplyDraft(_replyCtrl.text, draft.prefix);
      _replyCtrl
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

  void _onReplyChanged() {
    ref
        .read(mentionSuggestControllerProvider.notifier)
        .onTextChanged(_replyCtrl.text, _replyCtrl.selection.baseOffset);
  }

  Widget _buildReplyMentionSuggest(BuildContext context) {
    return MentionSuggestOverlay(
      onSelect: (username) {
        insertIntoComposer(_replyCtrl, username);
      },
    );
  }

  bool _isAuth() => ref.read(authStatusProvider).value?.isAuth ?? false;

  void _promptLogin({String? message}) {
    final l10n = AppLocalizations.of(context);
    showFToast(
      context: context,
      title: Text(message ?? l10n.discussionLoginToReply),
      variant: FToastVariant.primary,
    );
    context.push('/login');
  }

  /// Media OP (link / foto / audio) - pola Column sama `_commentMedia`.
  Widget? _opMedia(DiscussionItem item) {
    final parts = <Widget>[];
    final link = item.linkUrl?.trim();
    if (link != null && link.isNotEmpty) {
      parts.add(
        Align(
          alignment: Alignment.centerLeft,
          child: FButton(
            variant: FButtonVariant.outline,
            onPress: () async {
              final uri = Uri.tryParse(link);
              if (uri == null) return;
              await launchExternalUrl(uri);
            },
            prefix: const Icon(FLucideIcons.externalLink, size: 14),
            child: Text(
              link,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    }
    if (item.images.isNotEmpty) {
      parts.add(_ImageRow(images: item.images));
    }
    if (item.hasAudio) {
      parts.add(
        DiscussionReplyAudioPlayer(
          url: item.audioUrl!,
          durationMs: item.audioDurationMs,
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

  Future<void> _toggleHelpVote(int value) async {
    if (!_isAuth()) {
      _promptLogin(
        message: AppLocalizations.of(context).discussionLoginToVote,
      );
      return;
    }
    final failure = await ref
        .read(discussionDetailProvider(widget.id).notifier)
        .toggleHelpVote(value);
    if (!mounted || failure == null) return;
    showFToast(
      context: context,
      title: Text(failure.message),
      variant: FToastVariant.destructive,
    );
  }

  Future<void> _toggleVote(DiscussionReply reply, int value) async {
    if (!_isAuth()) {
      _promptLogin(
        message: AppLocalizations.of(context).discussionLoginToVote,
      );
      return;
    }
    final failure = await ref
        .read(discussionDetailProvider(widget.id).notifier)
        .toggleVote(reply, value);
    if (!mounted || failure == null) return;
    showFToast(
      context: context,
      title: Text(failure.message),
      variant: FToastVariant.destructive,
    );
  }

  Future<void> _sendReply() async {
    if (!_isAuth()) {
      _promptLogin();
      return;
    }
    final failure = await ref
        .read(discussionDetailProvider(widget.id).notifier)
        .createReply(_replyCtrl.text);
    if (!mounted) return;
    if (failure == null) {
      _replyCtrl.clear();
      _dismissReply(clearComposerPrefix: false);
      showFToast(
        context: context,
        title: Text(AppLocalizations.of(context).discussionReplySent),
        variant: FToastVariant.primary,
      );
      return;
    }
    if (failure.errorCode == 'RATE_LIMITED') {
      showFToast(context: context, title: Text(failure.message));
      return;
    }
    await showAppErrorSheet(context, message: failure.message);
  }

  Future<void> _recordAudioReply() async {
    if (!_isAuth()) {
      _promptLogin();
      return;
    }
    final caption = _replyCtrl.text.trim();
    await showRecordDiscussionReplySheet(
      context,
      onSubmit: ({required audioFile, required durationMs}) async {
        final failure = await ref
            .read(discussionDetailProvider(widget.id).notifier)
            .createReplyAudio(
              audioFile: audioFile,
              durationMs: durationMs,
              body: caption.isEmpty ? null : caption,
            );
        if (failure == null) {
          if (mounted) {
            _replyCtrl.clear();
            _dismissReply(clearComposerPrefix: false);
          }
          return null;
        }
        return failure.message;
      },
    );
  }

  Future<void> _editReply(DiscussionReply reply) async {
    final l10n = AppLocalizations.of(context);
    final saved = await showThreadTextEditSheet(
      context,
      title: l10n.discussionReplyEditTitle,
      initialBody: reply.body?.trim() ?? '',
      saveLabel: l10n.discussionReplyEditSave,
      onSave: (body) async {
        if (body.isEmpty) return l10n.discussionReplyEditEmpty;
        final failure = await ref
            .read(discussionDetailProvider(widget.id).notifier)
            .updateReply(reply, body);
        return failure?.message;
      },
    );
    if (!mounted || saved == null) return;
    showFToast(
      context: context,
      title: Text(l10n.discussionReplyEditSuccess),
      variant: FToastVariant.primary,
    );
  }

  Future<void> _showReplyEditHistory(DiscussionReply reply) async {
    final l10n = AppLocalizations.of(context);
    final result = await ref
        .read(discussionRepositoryProvider)
        .replyEditHistory(reply.id);
    if (!mounted) return;
    result.match(
      (failure) => showAppErrorSheet(context, message: failure.message),
      (history) => showThreadTextEditHistorySheet(
        context,
        title: l10n.discussionReplyEditHistoryTitle,
        history: ThreadTextEditHistory(
          currentBody: history.currentBody,
          currentUpdatedAt: history.currentUpdatedAt,
          revisions: [
            for (final r in history.revisions)
              ThreadTextEditRevision(body: r.body, createdAt: r.createdAt),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteReply(DiscussionReply reply) async {
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
                  title: Text(l10n.discussionReplyDeleteTitle),
                  subtitle: Text(l10n.discussionReplyDeleteBody),
                ),
                FTile(
                  title: const Text(''),
                  suffix: FButton(
                    variant: FButtonVariant.destructive,
                    onPress: () => Navigator.of(sheetContext).pop(true),
                    child: Text(l10n.commonDelete),
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

    final failure = await ref
        .read(discussionDetailProvider(widget.id).notifier)
        .deleteReply(reply);
    if (!mounted) return;
    showFToast(
      context: context,
      title: Text(
          failure == null
              ? AppLocalizations.of(context).discussionReplyDeleted
              : failure.message,
        ),
      variant: failure == null
          ? FToastVariant.primary
          : FToastVariant.destructive,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final auth = ref.watch(authStatusProvider).value;
    final isAuth = auth?.isAuth ?? false;
    final async = ref.watch(discussionDetailProvider(widget.id));

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: async.maybeWhen(
          data: (state) => Text(
            state.item.body?.trim() ?? AppLocalizations.of(context).discussionHelpDetailTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          orElse: () => Text(AppLocalizations.of(context).discussionHelpDetailTitle),
        ),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: async.when(
        loading: () => const _DetailSkeleton(),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FLucideIcons.circleAlert,
                  size: 40,
                  color: theme.colors.mutedForeground,
                ),
                const Gap(10),
                Text(
                  error is DiscussionFailure
                      ? error.message
                      : AppLocalizations.of(context).discussionDetailLoadFailed,
                  textAlign: TextAlign.center,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                const Gap(16),
                FButton(
                  variant: FButtonVariant.outline,
                  onPress: () =>
                      ref.invalidate(discussionDetailProvider(widget.id)),
                  child: Text(AppLocalizations.of(context).discussionRetry),
                ),
              ],
            ),
          ),
        ),
        data: (state) {
          final item = state.item;
          final canReply = item.isPublished;
          final replies = item.orderedReplies;

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(discussionDetailProvider(widget.id));
                    await ref.read(discussionDetailProvider(widget.id).future);
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
                    children: [
                      // OP = pola ThreadMessageRow sama komentar/balasan (#207).
                      ThreadMessageRow(
                        username: item.username,
                        displayName: item.displayName,
                        avatarUrl: item.avatarUrl,
                        isVerifier: item.isVerifier,
                        body: item.body?.trim() ?? '',
                        dateLabel: formatRelativeCompact(
                          DateTime.tryParse(item.createdAt),
                        ),
                        metaParts: [
                          if (!item.isPublished)
                            item.statusLabelOf(l10n),
                        ],
                        media: _opMedia(item),
                        onUsernameTap: isLinkablePublicUsername(item.username)
                            ? () => UserProfileRouter.open(
                                context,
                                item.username!,
                              )
                            : null,
                        onMentionTap: (mentionedUsername) =>
                            UserProfileRouter.open(
                              context,
                              mentionedUsername,
                            ),
                        onReply: item.isPublished && canReply
                            ? () => _startReply(
                                  username: item.username,
                                  body: item.body,
                                )
                            : null,
                        footer: item.isPublished
                            ? Row(
                                children: [
                                  VoteButtons(
                                    upvotes: item.upvotes,
                                    downvotes: 0,
                                    myVote: item.myVote,
                                    onVote: _toggleHelpVote,
                                    compact: true,
                                    upvoteOnly: true,
                                  ),
                                  const Gap(10),
                                  Expanded(
                                    child: Text(
                                      l10n.discussionAlsoCurious,
                                      style: theme.typography.body.sm.copyWith(
                                        color: theme.colors.mutedForeground,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                      if (item.status == 'rejected' &&
                          (item.rejectionNote?.trim().isNotEmpty ?? false)) ...[
                        const Gap(12),
                        FAlert(
                          variant: FAlertVariant.destructive,
                          title: Text(item.rejectionNote!.trim()),
                        ),
                      ],
                      const Gap(16),
                      Text(
                        replies.isEmpty
                            ? l10n.discussionRepliesLabel
                            : l10n.discussionRepliesCount(replies.length),
                        style: theme.typography.body.sm.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(8),
                      if (!canReply)
                        Text(
                          item.status == 'pending_review'
                              ? l10n.discussionRepliesPendingLocked
                              : l10n.discussionRepliesUnavailable,
                          style: theme.typography.body.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        )
                      else if (replies.isEmpty)
                        Text(
                          l10n.discussionRepliesEmpty,
                          style: theme.typography.body.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        )
                      else
                        for (final reply in replies)
                          ThreadMessageRow(
                            username: reply.username,
                            displayName: reply.displayName,
                            avatarUrl: reply.avatarUrl,
                            isVerifier: reply.isVerifier,
                            body: !reply.isPublished
                                ? (reply.status == 'taken_down'
                                      ? l10n.discussionRepliesRemovedModerator
                                      : l10n.discussionRepliesRemovedAuthor)
                                : (reply.body?.trim() ?? ''),
                            dateLabel: formatRelativeAgo(
                              DateTime.tryParse(reply.createdAt),
                            ),
                            metaParts: [
                            if (reply.isPinned)
                              AppLocalizations.of(context).discussionPinned,
                          ],
                            isRedacted: !reply.isPublished,
                            highlighted: reply.isPinned && reply.isPublished,
                            media: reply.isPublished && reply.hasAudio
                                ? DiscussionReplyAudioPlayer(
                                    url: reply.audioUrl!,
                                    durationMs: reply.audioDurationMs,
                                  )
                                : null,
                            isEdited: reply.isEdited,
                            editedLabel: l10n.commentEdited,
                            onShowEditHistory: reply.isEdited
                                ? () => _showReplyEditHistory(reply)
                                : null,
                            onEdit: reply.isPublished &&
                                    reply.isOwner(auth?.userId)
                                ? () => _editReply(reply)
                                : null,
                            onDelete: reply.isPublished &&
                                    reply.isOwner(auth?.userId)
                                ? () => _deleteReply(reply)
                                : null,
                            onUsernameTap:
                                isLinkablePublicUsername(reply.username)
                                ? () => UserProfileRouter.open(
                                    context,
                                    reply.username!,
                                  )
                                : null,
                            onMentionTap: (mentionedUsername) =>
                                UserProfileRouter.open(
                                  context,
                                  mentionedUsername,
                                ),
                            onReply: reply.isPublished && canReply
                                ? () => _startReply(
                                      username: reply.username,
                                      body: reply.body,
                                    )
                                : null,
                            footer: reply.isPublished
                                ? Row(
                                    children: [
                                      VoteButtons(
                                        upvotes: reply.upvotes,
                                        downvotes: reply.downvotes,
                                        myVote: reply.myVote,
                                        onVote: (value) =>
                                            _toggleVote(reply, value),
                                        compact: true,
                                      ),
                                      const Gap(10),
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(context).discussionHelpfulQuestion,
                                          style: theme.typography.body.sm
                                              .copyWith(
                                                color: theme
                                                    .colors
                                                    .mutedForeground,
                                                fontSize: 11,
                                              ),
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                    ],
                  ),
                ),
              ),
              if (canReply)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
                    child: !isAuth
                        ? ThreadLoginPrompt(
                            message: l10n.discussionReplyLoginCta,
                            onLogin: _promptLogin,
                          )
                        : ThreadComposer(
                            controller: _replyCtrl,
                            focusNode: _composerFocus,
                            isSubmitting: state.isSubmittingReply,
                            onSubmit: _sendReply,
                            onRecordAudio: _recordAudioReply,
                            hint: l10n.discussionReplyHint,
                            replyBanner: _replyDraft == null
                                ? null
                                : ThreadReplyBanner(
                                    title: _replyChipHandle != null
                                        ? l10n.threadReplyingTo(
                                            _replyChipHandle!,
                                          )
                                        : l10n.threadReply,
                                    subtitle: _replyDraft!.quotePreview,
                                    onDismiss: _dismissReply,
                                  ),
                            suggestBuilder: _buildReplyMentionSuggest,
                          ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ImageRow extends StatefulWidget {
  const _ImageRow({required this.images});

  final List<DiscussionImage> images;

  @override
  State<_ImageRow> createState() => _ImageRowState();
}

class _ImageRowState extends State<_ImageRow> {
  static const _maxPages = 10;

  var _violenceRevealed = false;
  var _page = 0;

  List<DiscussionImage> get _pages =>
      widget.images.take(_maxPages).toList(growable: false);

  List<String> get _previewUrls => [
    for (final u in _pages)
      if (u.displaySource != null)
        displayImageUrl(u.displaySource!, width: 1200) ?? u.displaySource!,
  ];

  void _openPreview(int index) {
    final pages = _pages;
    if (index < 0 || index >= pages.length) return;
    final img = pages[index];
    if (img.hasViolenceWarning && !_violenceRevealed) {
      setState(() => _violenceRevealed = true);
      return;
    }
    final urls = _previewUrls;
    if (urls.isEmpty) return;
    showImagePreview(
      context,
      urls: urls,
      initialIndex: index.clamp(0, urls.length - 1),
    );
  }

  Widget _photoPage(DiscussionImage img, int index) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openPreview(index),
      child: SizedBox.expand(
        child: DiscussionImageThumb(
          image: img,
          revealed: _violenceRevealed,
          fit: BoxFit.cover,
          onRequestReveal: () => setState(() => _violenceRevealed = true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final pages = _pages;
    if (pages.isEmpty) return const SizedBox.shrink();

    final multi = pages.length > 1;
    final screenW = MediaQuery.sizeOf(context).width;

    // Bleed ke lebar layar (keluar dari padding FScaffold childPad).
    return LayoutBuilder(
      builder: (context, constraints) {
        final bleed = ((screenW - constraints.maxWidth) / 2).clamp(0.0, 48.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Transform.translate(
              offset: Offset(-bleed, 0),
              child: SizedBox(
                width: screenW,
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: ClipRect(
                    child: multi
                        ? PageView.builder(
                            itemCount: pages.length,
                            onPageChanged: (i) => setState(() => _page = i),
                            itemBuilder: (context, i) =>
                                _photoPage(pages[i], i),
                          )
                        : _photoPage(pages.first, 0),
                  ),
                ),
              ),
            ),
            const Gap(8),
            Text(
              multi
                  ? AppLocalizations.of(
                      context,
                    ).discussionPhotoTapHintMany
                  : AppLocalizations.of(context).discussionPhotoTapHintOne,
              textAlign: TextAlign.center,
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
                height: 1.3,
              ),
            ),
            if (multi) ...[
              const Gap(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < pages.length; i++)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _page
                            ? theme.colors.primary
                            : theme.colors.mutedForeground.withValues(
                                alpha: 0.35,
                              ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: const [
          Bone.text(words: 3),
          Gap(12),
          Bone.multiText(lines: 3),
          Gap(12),
          AspectRatio(aspectRatio: 4 / 3, child: Bone()),
          Gap(8),
          Bone.text(words: 4),
          Gap(20),
          Bone.text(words: 2),
          Gap(8),
          Bone.multiText(lines: 2),
        ],
      ),
    );
  }
}
