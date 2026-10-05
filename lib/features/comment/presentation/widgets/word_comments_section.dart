import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/widgets/record_thread_audio_sheet.dart';
import '../../../../shared/widgets/thread_audio_player.dart';
import '../../../../shared/widgets/thread_message.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../../vote/presentation/widgets/vote_buttons.dart';
import '../../domain/entities/word_comment.dart';
import '../../domain/failures/comment_failure.dart';
import '../providers/comment_providers.dart';
import '../providers/mention_suggest_providers.dart';
import '../widgets/mention_suggest_overlay.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../../core/utils/format_datetime.dart';

/// Buka thread komentar tanpa memanjangkan entri kata.
Future<void> showWordCommentsSheet(BuildContext context, String wordId) {
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
          child: WordCommentsSection(wordId: wordId),
        ),
      );
    },
  );
}

/// Bar lengket di bawah detail kata. Jumlah mengikuti halaman yang sudah dimuat.
class WordCommentEntryBar extends ConsumerWidget {
  const WordCommentEntryBar({super.key, required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final async = ref.watch(commentListControllerProvider(wordId));
    final count = async.value?.items.length ?? 0;

    // FScaffold Forui tidak menyediakan ancestor Material - bungkus sendiri
    // agar InkWell (splash) tidak throw "No Material widget found".
    return Material(
      color: theme.colors.background,
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: () => showWordCommentsSheet(context, wordId),
          child: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.colors.border)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Icon(FLucideIcons.messageSquare, size: 18, color: theme.colors.foreground),
                const Gap(8),
                Text(
                  '$count Komentar',
                  style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600),
                ),
                const Gap(8),
                Icon(FLucideIcons.chevronUp, size: 16, color: theme.colors.mutedForeground),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// (09-api-comment.md).
/// baris/composer: [ThreadMessageRow] [ThreadComposer]
class WordCommentsSection extends ConsumerStatefulWidget {
  const WordCommentsSection({super.key, required this.wordId});

  final String wordId;

  @override
  ConsumerState<WordCommentsSection> createState() => _WordCommentsSectionState();
}

class _WordCommentsSectionState extends ConsumerState<WordCommentsSection> {
  final _bodyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bodyCtrl.addListener(_onBodyChanged);
  }

  @override
  void dispose() {
    _bodyCtrl.removeListener(_onBodyChanged);
    _bodyCtrl.dispose();
    super.dispose();
  }

  void _onBodyChanged() {
    ref.read(mentionSuggestControllerProvider.notifier).onTextChanged(
      _bodyCtrl.text,
      _bodyCtrl.selection.baseOffset,
    );
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
      title: const Text('Masuk dulu untuk berkomentar'),
      variant: FToastVariant.primary,
    );
    context.push('/login');
  }

  Future<void> _submitText() async {
    if (!_isAuth()) {
      _promptLogin();
      return;
    }
    final failure = await ref
        .read(commentListControllerProvider(widget.wordId).notifier)
        .create(_bodyCtrl.text);
    if (!mounted) return;
    if (failure == null) {
      _bodyCtrl.clear();
      showFToast(
        context: context,
        title: const Text('Komentar terkirim'),
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

  Future<void> _recordAudioComment() async {
    if (!_isAuth()) {
      _promptLogin();
      return;
    }
    final caption = _bodyCtrl.text.trim();
    await showRecordThreadAudioSheet(
      context,
      title: 'Rekam komentar suara',
      subtitle: 'Maksimal 60 detik. Caption teks bisa ditambahkan di kolom sebelum merekam.',
      submitLabel: 'Kirim rekaman',
      onSubmit: ({required audioFile, required durationMs}) async {
        final failure = await ref
            .read(commentListControllerProvider(widget.wordId).notifier)
            .createAudio(
              audioFile: audioFile,
              durationMs: durationMs,
              body: caption.isEmpty ? null : caption,
            );
        if (failure == null) {
          if (mounted) _bodyCtrl.clear();
          return null;
        }
        return failure.message;
      },
    );
  }

  Future<void> _toggleVote(WordComment comment, int value) async {
    if (!_isAuth()) {
      _promptLogin();
      return;
    }
    final failure = await ref
        .read(commentListControllerProvider(widget.wordId).notifier)
        .toggleVote(comment, value);
    if (!mounted || failure == null) return;
    showFToast(
      context: context,
      title: Text(failure.message),
      variant: FToastVariant.destructive,
    );
  }

  Future<void> _deleteComment(WordComment comment) async {
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
                  title: const Text('Hapus komentar?'),
                  subtitle: const Text('Komentar akan ditandai sebagai dihapus oleh penulis.'),
                ),
                FTile(
                  title: const Text(''),
                  suffix: FButton(
                    variant: FButtonVariant.destructive,
                    onPress: () => Navigator.of(sheetContext).pop(true),
                    child: const Text('Hapus'),
                  ),
                ),
                FTile(
                  title: const Text(''),
                  suffix: FButton(
                    onPress: () => Navigator.of(sheetContext).pop(false),
                    child: const Text('Batal'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    final failure = await ref
        .read(commentListControllerProvider(widget.wordId).notifier)
        .delete(comment);
    if (!mounted) return;
    showFToast(
      context: context,
      title: Text(failure == null ? 'Komentar dihapus' : failure.message),
      variant: failure == null ? FToastVariant.primary : FToastVariant.destructive,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final auth = ref.watch(authStatusProvider).value;
    final async = ref.watch(commentListControllerProvider(widget.wordId));
    final listState = async.value;
    final count = listState?.items.length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Drag handle terpisah (bukan dalam container tinggi tetap - IconButton
        // butuh min 48px, paksa container 36px overflow).
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
                  'Komentar ($count)',
                  style: theme.typography.md.copyWith(fontWeight: FontWeight.w600),
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
              error: (error, _) => _CommentsError(
                message: error is CommentFailure ? error.message : 'Gagal memuat komentar',
                onRetry: () => ref.invalidate(commentListControllerProvider(widget.wordId)),
              ),
              data: (state) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.items.isEmpty)
                    Text(
                      'Belum ada komentar.',
                      style: theme.typography.sm.copyWith(color: theme.colors.mutedForeground),
                    )
                  else
                    ...state.items.map((c) {
                      final canDelete =
                          auth != null &&
                          c.isPublished &&
                          c.isOwner(auth.userId);
                      return ThreadMessageRow(
                        username: c.username,
                        displayName: c.displayName,
                        avatarUrl: c.avatarUrl,
                        isVerifier: c.isVerifier,
                        body: c.displayBody,
                        dateLabel: formatRelativeCompact(
                          DateTime.tryParse(c.createdAt ?? ''),
                        ),
                        metaParts: [
                          if (c.isTakenDown) 'dihapus moderator',
                          if (c.isDeletedByAuthor) 'dihapus penulis',
                        ],
                        isRedacted: !c.isPublished,
                        onDelete: canDelete ? () => _deleteComment(c) : null,
                        onUsernameTap: isLinkablePublicUsername(c.username)
                            ? () => UserProfileRouter.open(context, c.username!)
                            : null,
                        onMentionTap: (mentionedUsername) =>
                            UserProfileRouter.open(context, mentionedUsername),
                        media: c.isPublished && c.hasAudio
                            ? ThreadAudioPlayer(
                                url: c.audioUrl!,
                                durationMs: c.audioDurationMs,
                              )
                            : null,
                        footer: c.isPublished
                            ? VoteButtons(
                                upvotes: c.upvotes,
                                downvotes: c.downvotes,
                                myVote: c.myVote,
                                onVote: (value) => _toggleVote(c, value),
                                compact: true,
                              )
                            : null,
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
                                  .read(commentListControllerProvider(widget.wordId).notifier)
                                  .loadMore(),
                          prefix: state.isLoadingMore ? const FCircularProgress() : null,
                          child: Text(state.isLoadingMore ? 'Memuat...' : 'Muat lainnya'),
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
                  message: 'Masuk untuk menulis komentar',
                  onLogin: _promptLogin,
                )
              : ThreadComposer(
                  controller: _bodyCtrl,
                  isSubmitting: listState?.isSubmitting ?? false,
                  onSubmit: _submitText,
                  onRecordAudio: _recordAudioComment,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < 2; i++)
          ThreadMessageRow(
            username: 'username',
            displayName: 'Nama Pengguna',
            avatarUrl: null,
            isVerifier: false,
            body: 'Cuplikan komentar contoh untuk skeleton.',
            dateLabel: 'baru saja',
            footer: const VoteButtonsSkeleton(compact: true),
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
      subtitle: const Text('Coba lagi untuk memuat komentar.'),
    );
  }
}