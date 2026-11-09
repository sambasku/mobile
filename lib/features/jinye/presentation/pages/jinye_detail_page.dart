import 'package:dio/dio.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/providers/thread_audio_player_provider.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/thread_audio_player.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../vote/domain/entities/vote_target.dart';
import '../../../vote/presentation/providers/vote_providers.dart';
import '../../../vote/presentation/widgets/vote_buttons.dart';
import '../../data/jinye_providers.dart';
import '../../domain/jinye_models.dart';
import '../widgets/jinye_report_sheet.dart';

/// Detail Jinye Phase 2: media + vote OP + komen/reply 1 level.
class JinyeDetailPage extends HookConsumerWidget {
  const JinyeDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(jinyeDetailProvider(id));
    final commentsAsync = ref.watch(jinyeCommentsProvider(id));
    final theme = context.theme;
    final auth = ref.watch(authStatusProvider).value;
    final isAuth = auth?.isAuth ?? false;

    final body = useTextEditingController();
    useListenable(body);
    final replyTo = useState<JinyeComment?>(null);
    final submitting = useState(false);

    Future<void> submitComment() async {
      if (!isAuth) {
        showFToast(context: context, title: Text(l10n.jinyeLoginFirst));
        context.push('/login');
        return;
      }
      final trimmed = body.text.trim();
      if (trimmed.isEmpty || submitting.value) return;
      submitting.value = true;
      try {
        await ref.read(jinyeRepositoryProvider).createComment(
              jinyeId: id,
              body: trimmed,
              parentId: replyTo.value?.id,
            );
        body.clear();
        replyTo.value = null;
        ref.invalidate(jinyeCommentsProvider(id));
        ref.invalidate(jinyeDetailProvider(id));
        if (!context.mounted) return;
        showFToast(context: context, title: Text(l10n.jinyeCommentSent));
      } on DioException catch (e) {
        if (!context.mounted) return;
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
        if (!context.mounted) return;
        await showAppErrorSheet(context, message: l10n.jinyeCommentFailed);
      } finally {
        submitting.value = false;
      }
    }

    return StopThreadAudioOnLeave(
      child: FScaffold(
        header: FHeader.nested(
          title: Text(l10n.jinyeDetailTitle),
          prefixes: [
            FHeaderAction.back(onPress: () => context.pop()),
          ],
        ),
        footer: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (replyTo.value != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.jinyeReplyingTo(
                            replyTo.value!.displayName?.trim().isNotEmpty ==
                                    true
                                ? replyTo.value!.displayName!
                                : (replyTo.value!.username ?? '-'),
                          ),
                          style: theme.typography.body.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      FButton(
                        variant: FButtonVariant.ghost,
                        onPress: () => replyTo.value = null,
                        child: Text(l10n.commonCancel),
                      ),
                    ],
                  ),
                  const Gap(4),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: FTextField(
                        control: FTextFieldControl.managed(controller: body),
                        enabled: !submitting.value && isAuth,
                        hint: l10n.jinyeCommentHint,
                        maxLines: 3,
                        minLines: 1,
                        maxLength: 500,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                      ),
                    ),
                    const Gap(8),
                    FButton(
                      onPress: submitting.value ||
                              body.text.trim().isEmpty ||
                              !isAuth
                          ? (isAuth ? null : () {
                              showFToast(
                                context: context,
                                title: Text(l10n.jinyeLoginFirst),
                              );
                              context.push('/login');
                            })
                          : submitComment,
                      prefix: submitting.value
                          ? const FCircularProgress()
                          : const Icon(FLucideIcons.send, size: 16),
                      child: Text(
                        submitting.value
                            ? l10n.jinyeCommentSending
                            : l10n.jinyeCommentSend,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        child: async.when(
          loading: () => Skeletonizer(
            enabled: true,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('xxxxxxxx', style: theme.typography.body.lg),
                const Gap(8),
                Text('yyyyyyyyyyyyyyyy', style: theme.typography.body.md),
              ],
            ),
          ),
          error: (_, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.jinyeDetailLoadFailed),
                  const Gap(12),
                  FButton(
                    onPress: () => ref.invalidate(jinyeDetailProvider(id)),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            ),
          ),
          data: (item) {
            final name = item.displayName?.trim().isNotEmpty == true
                ? item.displayName!
                : (item.username ?? '-');
            final voteTarget = VoteTarget(type: 'jinye', id: item.id);
            final voteAsync = ref.watch(voteControllerProvider(voteTarget));

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Row(
                  children: [
                    UserAvatar(
                      name: name,
                      imageUrl: item.avatarUrl,
                      size: 40,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: theme.typography.body.md.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            formatDateTimeIso(item.createdAt.toIso8601String()),
                            style: theme.typography.body.sm.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(16),
                if (item.body.trim().isNotEmpty)
                  Text(item.body, style: theme.typography.body.lg)
                else if (!item.hasAudio && !item.hasDisplayableImages)
                  Text('-', style: theme.typography.body.lg),
                if (item.hasAudio) ...[
                  const Gap(12),
                  ThreadAudioPlayer(
                    url: item.audio!.url,
                    audioId: 'jinye:${item.id}',
                    durationMs: item.audio!.durationMs,
                  ),
                ],
                if (item.hasDisplayableImages) ...[
                  const Gap(12),
                  _JinyeImageRow(images: item.images),
                ] else if (item.images.isNotEmpty) ...[
                  const Gap(12),
                  FAlert(title: Text(l10n.jinyePhotosPendingReview)),
                ],
                const Gap(12),
                Row(
                  children: [
                    voteAsync.when(
                      loading: () => const VoteButtonsSkeleton(compact: true),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (view) => VoteButtons(
                        upvotes: view.upvotes,
                        downvotes: 0,
                        myVote: view.myVote,
                        upvoteOnly: true,
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
                              .read(
                                voteControllerProvider(voteTarget).notifier,
                              )
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
                    const Gap(8),
                    FButton(
                      variant: FButtonVariant.ghost,
                      onPress: () => reportJinyeFromUi(
                        context,
                        ref,
                        targetType: 'jinye',
                        targetId: item.id,
                      ),
                      child: Text(l10n.reportJinyeAction),
                    ),
                  ],
                ),
                const Gap(20),
                Text(
                  l10n.jinyeCommentsTitle,
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                commentsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: FCircularProgress()),
                  ),
                  error: (_, _) => FAlert(
                    title: Text(l10n.jinyeCommentsLoadFailed),
                  ),
                  data: (comments) {
                    if (comments.isEmpty) {
                      return FAlert(title: Text(l10n.jinyeDiscussionEmpty));
                    }
                    return Column(
                      children: [
                        for (final c in comments) ...[
                          _CommentTile(
                            comment: c,
                            onReply: () => replyTo.value = c,
                          ),
                          const Gap(8),
                        ],
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CommentTile extends ConsumerWidget {
  const _CommentTile({required this.comment, required this.onReply});

  final JinyeComment comment;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final name = comment.displayName?.trim().isNotEmpty == true
        ? comment.displayName!
        : (comment.username ?? '-');
    final voteTarget = VoteTarget(type: 'jinye_comment', id: comment.id);
    final voteAsync = ref.watch(voteControllerProvider(voteTarget));
    final auth = ref.watch(authStatusProvider).value;
    final isAuth = auth?.isAuth ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(name: name, imageUrl: comment.avatarUrl, size: 28),
              const Gap(8),
              Expanded(
                child: Text(
                  name,
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                formatDateTimeIso(comment.createdAt.toIso8601String()),
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
          if (comment.body.trim().isNotEmpty) ...[
            const Gap(8),
            Text(comment.body, style: theme.typography.body.md),
          ],
          if (comment.images.any((i) => i.displaySource != null)) ...[
            const Gap(8),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: comment.images
                    .where((i) => i.displaySource != null)
                    .length,
                separatorBuilder: (_, _) => const Gap(6),
                itemBuilder: (context, index) {
                  final imgs = comment.images
                      .where((i) => i.displaySource != null)
                      .toList();
                  final src = imgs[index].displaySource!;
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
          ] else if (comment.images.isNotEmpty) ...[
            const Gap(6),
            Text(
              l10n.jinyePhotosPendingReview,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
          const Gap(8),
          Row(
            children: [
              voteAsync.when(
                loading: () => const SizedBox.shrink(),
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
              const Gap(8),
              FButton(
                variant: FButtonVariant.ghost,
                onPress: onReply,
                child: Text(l10n.jinyeSheetReply),
              ),
              const Gap(4),
              FButton(
                variant: FButtonVariant.ghost,
                onPress: () => reportJinyeFromUi(
                  context,
                  ref,
                  targetType: 'jinye_comment',
                  targetId: comment.id,
                ),
                child: Text(l10n.reportJinyeAction),
              ),
            ],
          ),
          if (comment.replies.isNotEmpty) ...[
            const Gap(8),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                children: [
                  for (final r in comment.replies) ...[
                    _ReplyTile(comment: r),
                    const Gap(6),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReplyTile extends ConsumerWidget {
  const _ReplyTile({required this.comment});

  final JinyeComment comment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final name = comment.displayName?.trim().isNotEmpty == true
        ? comment.displayName!
        : (comment.username ?? '-');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (comment.body.trim().isNotEmpty) ...[
            const Gap(4),
            Text(comment.body, style: theme.typography.body.sm),
          ],
          const Gap(4),
          Align(
            alignment: Alignment.centerLeft,
            child: FButton(
              variant: FButtonVariant.ghost,
              onPress: () => reportJinyeFromUi(
                context,
                ref,
                targetType: 'jinye_comment',
                targetId: comment.id,
              ),
              child: Text(l10n.reportJinyeAction),
            ),
          ),
        ],
      ),
    );
  }
}

class _JinyeImageRow extends StatefulWidget {
  const _JinyeImageRow({required this.images});

  final List<JinyeImage> images;

  @override
  State<_JinyeImageRow> createState() => _JinyeImageRowState();
}

class _JinyeImageRowState extends State<_JinyeImageRow> {
  var _page = 0;

  List<JinyeImage> get _pages => widget.images
      .where((i) => i.displaySource != null)
      .take(4)
      .toList(growable: false);

  List<String> get _previewUrls => [
        for (final u in _pages)
          displayImageUrl(u.displaySource!, width: 1200) ?? u.displaySource!,
      ];

  void _openPreview(int index) {
    final urls = _previewUrls;
    if (urls.isEmpty) return;
    showImagePreview(
      context,
      urls: urls,
      initialIndex: index.clamp(0, urls.length - 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final pages = _pages;
    if (pages.isEmpty) return const SizedBox.shrink();
    final multi = pages.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: multi
                ? PageView.builder(
                    itemCount: pages.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, index) {
                      final src = pages[index].displaySource!;
                      final url = displayImageUrl(src, width: 900) ?? src;
                      return GestureDetector(
                        onTap: () => _openPreview(index),
                        child: CachedNetworkImageWithFallback(
                          imageUrl: url,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  )
                : GestureDetector(
                    onTap: () => _openPreview(0),
                    child: CachedNetworkImageWithFallback(
                      imageUrl: displayImageUrl(
                            pages.first.displaySource!,
                            width: 900,
                          ) ??
                          pages.first.displaySource!,
                      fit: BoxFit.cover,
                    ),
                  ),
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
                        : theme.colors.mutedForeground.withValues(alpha: 0.4),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
