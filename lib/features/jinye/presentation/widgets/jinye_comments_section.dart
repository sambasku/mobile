import 'package:dio/dio.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/utils/thread_reply_draft.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
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

/// Buka thread komentar Jinye (pola sama [showWordCommentsSheet]).
Future<void> showJinyeCommentsSheet(BuildContext context, String jinyeId) {
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

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_isAuth()) {
      _promptLogin();
      return;
    }
    final trimmed = _bodyCtrl.text.trim();
    if (trimmed.isEmpty || _submitting) return;
    setState(() => _submitting = true);
    try {
      await ref.read(jinyeRepositoryProvider).createComment(
            jinyeId: widget.jinyeId,
            body: trimmed,
            parentId: _replyParentId,
          );
      _bodyCtrl.clear();
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
                return Column(
                  children: [
                    for (final c in items)
                      _JinyeCommentTile(
                        comment: c,
                        onReply: (target) => _startReply(
                          target: target,
                          parentId: c.id,
                        ),
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
  const _JinyeCommentTile({required this.comment, required this.onReply});

  final JinyeComment comment;
  final ValueChanged<JinyeComment> onReply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _JinyeThreadComment(
          comment: comment,
          onReply: () => onReply(comment),
        ),
        if (comment.replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Column(
              children: [
                for (final r in comment.replies)
                  _JinyeThreadComment(
                    comment: r,
                    // 1 tingkat: balas nested tetap ke root comment.
                    onReply: () => onReply(r),
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
    this.onReply,
  });

  final JinyeComment comment;
  final VoidCallback? onReply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final voteTarget = VoteTarget(type: 'jinye_comment', id: comment.id);
    final voteAsync = ref.watch(voteControllerProvider(voteTarget));
    final auth = ref.watch(authStatusProvider).value;
    final isAuth = auth?.isAuth ?? false;

    return ThreadMessageRow(
      username: comment.username,
      displayName: comment.displayName,
      avatarUrl: comment.avatarUrl,
      body: comment.body.trim(),
      dateLabel: formatRelativeCompact(comment.createdAt),
      media: _jinyeCommentMedia(context, comment),
      onUsernameTap: isLinkablePublicUsername(comment.username)
          ? () => UserProfileRouter.open(context, comment.username!)
          : null,
      onMentionTap: (mentionedUsername) =>
          UserProfileRouter.open(context, mentionedUsername),
      onReply: onReply,
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

Widget? _jinyeCommentMedia(BuildContext context, JinyeComment comment) {
  final l10n = AppLocalizations.of(context);
  final theme = context.theme;
  final displayable =
      comment.images.where((i) => i.displaySource != null).toList();
  if (displayable.isEmpty) {
    if (comment.images.isEmpty) return null;
    return Text(
      l10n.jinyePhotosPendingReview,
      style: theme.typography.body.sm.copyWith(
        color: theme.colors.mutedForeground,
      ),
    );
  }
  return SizedBox(
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
  );
}
