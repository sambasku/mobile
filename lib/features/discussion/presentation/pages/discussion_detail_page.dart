import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/widgets/thread_message.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../../vote/presentation/widgets/vote_buttons.dart';
import '../../domain/discussion_models.dart';
import '../providers/discussion_list_providers.dart';
import '../widgets/discussion_image_thumb.dart';
import '../widgets/discussion_reply_audio_player.dart';
import '../widgets/record_discussion_reply_sheet.dart';

/// Detail diskusi + thread balasan.
class DiscussionDetailPage extends ConsumerStatefulWidget {
  const DiscussionDetailPage({super.key, required this.id});

  final String id;

  @override
  ConsumerState<DiscussionDetailPage> createState() =>
      _DiscussionDetailPageState();
}

class _DiscussionDetailPageState
    extends ConsumerState<DiscussionDetailPage> {
  late final TextEditingController _replyCtrl;

  @override
  void initState() {
    super.initState();
    _replyCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  bool _isAuth() => ref.read(authStatusProvider).value?.isAuth ?? false;

  void _promptLogin({String message = 'Masuk dulu untuk membalas'}) {
    showFToast(
      context: context,
      title: Text(message),
      variant: FToastVariant.primary,
    );
    context.push('/login');
  }

  Future<void> _toggleHelpVote(int value) async {
    if (!_isAuth()) {
      _promptLogin(message: 'Masuk dulu untuk memberi vote');
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
      _promptLogin(message: 'Masuk dulu untuk memberi vote');
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
      showFToast(
        context: context,
        title: const Text('Balasan terkirim'),
        variant: FToastVariant.primary,
      );
      return;
    }
    if (failure.errorCode == 'RATE_LIMITED') {
      showFToast(
        context: context,
        title: Text(failure.message),
      );
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
          if (mounted) _replyCtrl.clear();
          return null;
        }
        return failure.message;
      },
    );
  }

  Future<void> _deleteReply(DiscussionReply reply) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus balasan?'),
        content: const Text('Balasan akan dihapus dari thread.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FButton(
            variant: FButtonVariant.destructive,
            onPress: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final failure = await ref
        .read(discussionDetailProvider(widget.id).notifier)
        .deleteReply(reply);
    if (!mounted) return;
    showFToast(
      context: context,
      title: Text(failure == null ? 'Balasan dihapus' : failure.message),
      variant: failure == null
          ? FToastVariant.primary
          : FToastVariant.destructive,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final auth = ref.watch(authStatusProvider).value;
    final isAuth = auth?.isAuth ?? false;
    final async = ref.watch(discussionDetailProvider(widget.id));

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Detail Bantuan'),
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
                      : 'Gagal memuat detail',
                  textAlign: TextAlign.center,
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                const Gap(16),
                FButton(
                  variant: FButtonVariant.outline,
                  onPress: () =>
                      ref.invalidate(discussionDetailProvider(widget.id)),
                  child: const Text('Coba lagi'),
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
                    await ref.read(
                      discussionDetailProvider(widget.id).future,
                    );
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
                    children: [
                      _HelpHeader(item: item),
                      if (item.body?.trim().isNotEmpty == true) ...[
                        const Gap(10),
                        Text(item.body!.trim(), style: theme.typography.sm),
                      ],
                      if (item.linkUrl?.trim().isNotEmpty == true) ...[
                        const Gap(10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FButton(
                            variant: FButtonVariant.outline,
                            onPress: () async {
                              final uri = Uri.tryParse(item.linkUrl!.trim());
                              if (uri == null) return;
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            prefix: const Icon(FLucideIcons.externalLink, size: 14),
                            child: Text(
                              item.linkUrl!.trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      if (item.images.isNotEmpty) ...[
                        const Gap(12),
                        _ImageRow(images: item.images),
                      ],
                      if (item.hasAudio) ...[
                        const Gap(12),
                        DiscussionReplyAudioPlayer(
                          url: item.audioUrl!,
                          durationMs: item.audioDurationMs,
                        ),
                      ],
                      if (item.isPublished) ...[
                        const Gap(12),
                        Row(
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
                                'Saya juga ingin tahu',
                                style: theme.typography.sm.copyWith(
                                  color: theme.colors.mutedForeground,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
                            ? 'Balasan'
                            : 'Balasan · ${replies.length}',
                        style: theme.typography.sm.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(8),
                      if (!canReply)
                        Text(
                          item.status == 'pending_review'
                              ? 'Balasan dibuka setelah permintaan ditayangkan.'
                              : 'Thread balasan tidak tersedia untuk status ini.',
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        )
                      else if (replies.isEmpty)
                        Text(
                          'Belum ada balasan. Jadilah yang pertama membantu.',
                          style: theme.typography.sm.copyWith(
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
                                      ? 'Balasan dihapus moderator'
                                      : 'Balasan dihapus penulis')
                                : (reply.body?.trim() ?? ''),
                            dateLabel: formatRelativeAgo(
                              DateTime.tryParse(reply.createdAt),
                            ),
                            metaParts: [
                              if (reply.isPinned) 'Disematkan',
                            ],
                            isRedacted: !reply.isPublished,
                            highlighted: reply.isPinned && reply.isPublished,
                            media: reply.isPublished && reply.hasAudio
                                ? DiscussionReplyAudioPlayer(
                                    url: reply.audioUrl!,
                                    durationMs: reply.audioDurationMs,
                                  )
                                : null,
                            onDelete:
                                reply.isPublished &&
                                    reply.isOwner(auth?.userId)
                                ? () => _deleteReply(reply)
                                : null,
                            onUsernameTap: isLinkablePublicUsername(
                              reply.username,
                            )
                                ? () => UserProfileRouter.open(
                                    context,
                                    reply.username!,
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
                                          'Jawaban membantu?',
                                          style: theme.typography.sm.copyWith(
                                            color: theme.colors.mutedForeground,
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
                            message: 'Masuk untuk membalas',
                            onLogin: _promptLogin,
                          )
                        : ThreadComposer(
                            controller: _replyCtrl,
                            isSubmitting: state.isSubmittingReply,
                            onSubmit: _sendReply,
                            onRecordAudio: _recordAudioReply,
                            hint: 'Tulis balasan…',
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

class _HelpHeader extends StatelessWidget {
  const _HelpHeader({required this.item});

  final DiscussionItem item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final when = formatDateTimeIso(item.createdAt);
    final username = displayPublicAccountLabel(
      displayName: item.displayName,
      username: item.username,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                username,
                style: theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FBadge(
              variant: item.isPublished
                  ? FBadgeVariant.primary
                  : FBadgeVariant.secondary,
              child: Text(item.statusLabel),
            ),
          ],
        ),
        if (when.isNotEmpty) ...[
          const Gap(4),
          Text(
            when,
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
              fontSize: 11,
            ),
          ),
        ],
      ],
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
        final bleed =
            ((screenW - constraints.maxWidth) / 2).clamp(0.0, 48.0);
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
                  ? 'Ketuk foto untuk melihat ukuran penuh · geser untuk foto lain'
                  : 'Ketuk foto untuk melihat ukuran penuh',
              textAlign: TextAlign.center,
              style: theme.typography.xs.copyWith(
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
                            : theme.colors.mutedForeground
                                .withValues(alpha: 0.35),
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
