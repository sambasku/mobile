import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/thread_message.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../../vote/presentation/widgets/vote_buttons.dart';
import '../../domain/translation_help_models.dart';
import '../providers/translation_help_list_providers.dart';

/// Detail bantuan + thread balasan.
class TranslationHelpDetailPage extends ConsumerStatefulWidget {
  const TranslationHelpDetailPage({super.key, required this.id});

  final String id;

  @override
  ConsumerState<TranslationHelpDetailPage> createState() =>
      _TranslationHelpDetailPageState();
}

class _TranslationHelpDetailPageState
    extends ConsumerState<TranslationHelpDetailPage> {
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
        .read(translationHelpDetailProvider(widget.id).notifier)
        .toggleHelpVote(value);
    if (!mounted || failure == null) return;
    showFToast(
      context: context,
      title: Text(failure.message),
      variant: FToastVariant.destructive,
    );
  }

  Future<void> _toggleVote(TranslationHelpReply reply, int value) async {
    if (!_isAuth()) {
      _promptLogin(message: 'Masuk dulu untuk memberi vote');
      return;
    }
    final failure = await ref
        .read(translationHelpDetailProvider(widget.id).notifier)
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
        .read(translationHelpDetailProvider(widget.id).notifier)
        .createReply(_replyCtrl.text);
    if (!mounted) return;
    if (failure == null) {
      _replyCtrl.clear();
      showFToast(
        context: context,
        title: const Text('Balasan terkirim'),
        variant: FToastVariant.primary,
      );
    } else {
      showFToast(
        context: context,
        title: Text(failure.message),
        variant: FToastVariant.destructive,
      );
    }
  }

  Future<void> _deleteReply(TranslationHelpReply reply) async {
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
        .read(translationHelpDetailProvider(widget.id).notifier)
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
    final async = ref.watch(translationHelpDetailProvider(widget.id));

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
                  error is TranslationHelpFailure
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
                      ref.invalidate(translationHelpDetailProvider(widget.id)),
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
                    ref.invalidate(translationHelpDetailProvider(widget.id));
                    await ref.read(
                      translationHelpDetailProvider(widget.id).future,
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
                      if (item.imageDisplayUrls.isNotEmpty) ...[
                        const Gap(12),
                        _ImageRow(urls: item.imageDisplayUrls),
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
                            body: !reply.isPublished
                                ? (reply.status == 'taken_down'
                                      ? 'Balasan dihapus moderator'
                                      : 'Balasan dihapus penulis')
                                : (reply.body ?? ''),
                            dateLabel: formatDateTimeIso(reply.createdAt),
                            metaParts: [
                              if (reply.isVerifier) 'Verifikator',
                              if (reply.isPinned) 'Disematkan',
                            ],
                            isRedacted: !reply.isPublished,
                            highlighted: reply.isPinned && reply.isPublished,
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

  final TranslationHelpItem item;

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

class _ImageRow extends StatelessWidget {
  const _ImageRow({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, _) => const Gap(8),
        itemBuilder: (context, i) {
          final src = urls[i];
          final display = displayImageUrl(src, width: 400) ?? src;
          return GestureDetector(
            onTap: () => showImagePreview(
              context,
              urls: [
                for (final u in urls) displayImageUrl(u, width: 1200) ?? u,
              ],
              initialIndex: i,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 96,
                height: 96,
                child: CachedNetworkImageWithFallback(
                  imageUrl: display,
                  fallbackUrl: src,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
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
          Bone(width: 96, height: 96),
          Gap(20),
          Bone.text(words: 2),
          Gap(8),
          Bone.multiText(lines: 2),
        ],
      ),
    );
  }
}
