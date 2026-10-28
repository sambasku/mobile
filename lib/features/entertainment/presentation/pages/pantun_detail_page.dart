import 'package:material_ui/material_ui.dart' show RefreshIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../data/pantun_api.dart';
import '../../domain/pantun_models.dart';
import '../providers/pantun_providers.dart';
import '../widgets/pantun_card.dart';
import '../widgets/pantun_delete_sheet.dart';
import '../widgets/pantun_edit_reply_sheet.dart';
import '../widgets/pantun_report_sheet.dart';

/// Detail pantun pembuka + thread balasan, disusun seperti Ruang Diskusi:
/// header konteks di atas, balasan menjorok sebagai baris thread.
///
/// [highlightReplyId] diisi dari deep-link hasil pencarian
/// (`/entertainment/pantun/:id?reply=:replyId`): halaman auto-scroll ke
/// balasan itu dan menyorotnya sebentar.
class PantunDetailPage extends HookConsumerWidget {
  const PantunDetailPage({super.key, required this.id, this.highlightReplyId});

  final String id;
  final String? highlightReplyId;

  Future<void> _openReply(BuildContext context, WidgetRef ref) async {
    final auth = await ref.read(authStatusProvider.future);
    if (!auth.isAuth) {
      if (context.mounted) {
        await showAppErrorSheet(
          context,
          message: AppLocalizations.of(context).pantunReplyLoginRequired,
        );
      }
      return;
    }
    if (!context.mounted) return;
    final created = await context.push<Object?>(
      '/entertainment/pantun/create?parent=$id',
    );
    if (created != null) ref.invalidate(pantunDetailProvider(id));
  }

  Future<void> _editReply(
    BuildContext context,
    WidgetRef ref,
    Pantun reply,
  ) async {
    final l10n = AppLocalizations.of(context);
    final saved = await showPantunReplyEditSheet(
      context,
      initialLines: reply.lines,
      onSave: (lines, scheme) async {
        try {
          final updated = await ref.read(pantunApiProvider).updateReply(
                replyId: reply.id,
                lines: lines,
                rhymeScheme: scheme,
              );
          ref.read(pantunDetailProvider(id).notifier).replaceReply(updated);
          return null;
        } on PantunFailure catch (e) {
          return e.message;
        }
      },
    );
    if (!context.mounted || saved == null) return;
    showFToast(
      context: context,
      title: Text(l10n.pantunReplyEditSuccess),
      variant: FToastVariant.primary,
    );
  }

  Future<void> _showReplyEditHistory(
    BuildContext context,
    WidgetRef ref,
    Pantun reply,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final history = await ref
          .read(pantunApiProvider)
          .replyEditHistory(reply.id);
      if (!context.mounted) return;
      await showPantunReplyEditHistorySheet(
        context,
        title: l10n.pantunReplyEditHistoryTitle,
        history: PantunReplyEditHistory(
          currentLines: history.currentLines,
          currentRhymeScheme: history.currentRhymeScheme,
          revisions: [
            for (final r in history.revisions)
              PantunReplyEditRevision(
                lines: r.lines,
                rhymeScheme: r.rhymeScheme,
                createdAt: r.createdAt,
              ),
          ],
        ),
      );
    } on PantunFailure catch (e) {
      if (context.mounted) {
        await showAppErrorSheet(context, message: e.message);
      }
    }
  }

  Future<void> _deleteReply(
    BuildContext context,
    WidgetRef ref,
    Pantun reply,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showPantunDeleteSheet(
      context,
      title: l10n.pantunDeleteReplyConfirm,
      subtitle: l10n.pantunDeleteReplyConfirmBody,
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(pantunApiProvider).deleteReply(reply.id);
      ref.invalidate(pantunDetailProvider(id));
      if (context.mounted) {
        showFToast(
          context: context,
          title: Text(l10n.pantunReplyDeletedToast),
          variant: FToastVariant.primary,
        );
      }
    } on PantunFailure catch (e) {
      if (context.mounted) {
        await showAppErrorSheet(context, message: e.message);
      }
    }
  }

  /// Hapus pantun pembuka milik sendiri: pop dulu (feed di-invalidate).
  Future<void> _deletePantun(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showPantunDeleteSheet(
      context,
      title: l10n.pantunDeleteConfirmTitle,
      subtitle: l10n.pantunDeleteConfirmBody,
    );
    if (!confirmed || !context.mounted) return;
    final error = await ref
        .read(pantunDetailProvider(id).notifier)
        .deletePantun();
    if (!context.mounted) return;
    if (error == null) {
      ref.invalidate(pantunFeedProvider);
      showFToast(
        context: context,
        title: Text(l10n.pantunDeletedToast),
        variant: FToastVariant.primary,
      );
      context.pop();
      return;
    }
    await showAppErrorSheet(context, message: error);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(pantunDetailProvider(id));
    final auth = ref.watch(authStatusProvider).value;
    final myUserId = auth?.userId;

    // Key per balasan: dipakai Scrollable.ensureVisible untuk deep-link.
    final replyKeys = useRef<Map<String, GlobalObjectKey>>({});
    final scrolledTo = useRef<String?>(null);

    useEffect(() {
      final target = highlightReplyId;
      if (target == null || !async.hasValue) return null;
      // Sekali saja per target; rebuild vote tidak boleh menarik scroll user.
      if (scrolledTo.value == target) return null;
      final replyContext = replyKeys.value[target]?.currentContext;
      if (replyContext == null) return null;
      scrolledTo.value = target;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!replyContext.mounted) return;
        Scrollable.ensureVisible(
          replyContext,
          alignment: 0.25,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      });
      return null;
    }, [async.hasValue, highlightReplyId]);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.pantunTitle),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      footer: FButton(
        onPress: () => _openReply(context, ref),
        child: Text(l10n.pantunReply),
      ),
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(pantunDetailProvider(id)),
        child: async.when(
          loading: () => const Center(child: FCircularProgress(size: .sm)),
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const Gap(64),
              Text(
                e is PantunFailure ? e.message : l10n.pantunLoadFailed,
                textAlign: TextAlign.center,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
          data: (detail) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
            children: [
              // Konteks: pantun pembuka, gaya ThreadMessageRow.
              PantunCard(
                pantun: detail.pantun,
                onUsernameTap: isLinkablePublicUsername(detail.pantun.username)
                    ? () => UserProfileRouter.open(
                        context,
                        detail.pantun.username!,
                      )
                    : null,
                onVoteToggle: (pantun, value) => ref
                    .read(pantunDetailProvider(id).notifier)
                    .toggleVote(pantun, value),
                footer: detail.pantun.userId == myUserId
                    ? PantunActionRow.delete(
                        label: l10n.pantunDelete,
                        onDelete: () => _deletePantun(context, ref),
                      )
                    : PantunActionRow.report(
                        onReport: () => reportPantunFromUi(
                          context,
                          ref,
                          targetType: 'pantun',
                          targetId: detail.pantun.id,
                        ),
                      ),
              ),
              const Gap(14),
              Text(
                detail.replies.isEmpty
                    ? l10n.pantunReplies
                    : l10n.pantunRepliesCount(detail.replies.length),
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(8),
              if (detail.replies.isEmpty)
                Text(
                  l10n.pantunNoReplies,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                )
              else
                for (final reply in detail.replies)
                  KeyedSubtree(
                    key: replyKeys.value.putIfAbsent(
                      reply.id,
                      () => GlobalObjectKey('pantun_reply_${reply.id}'),
                    ),
                    child: Padding(
                      // Menjorok seperti balasan thread diskusi: satu level
                      // saja (balas pantun tidak bertingkat).
                      padding: const EdgeInsets.only(left: 12),
                      child: PantunCard(
                        pantun: reply,
                        isEdited: reply.isEdited,
                        editedLabel: l10n.commentEdited,
                        onShowEditHistory: reply.isEdited
                            ? () => _showReplyEditHistory(context, ref, reply)
                            : null,
                        highlighted: reply.id == highlightReplyId,
                        onUsernameTap: isLinkablePublicUsername(reply.username)
                            ? () => UserProfileRouter.open(
                                context,
                                reply.username!,
                              )
                            : null,
                        onVoteToggle: reply.status == 'published'
                            ? (pantun, value) => ref
                                  .read(pantunDetailProvider(id).notifier)
                                  .toggleVote(pantun, value)
                            : null,
                        footer: reply.userId == myUserId &&
                                reply.status == 'published'
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PantunActionRow.edit(
                                    label: l10n.pantunReplyEdit,
                                    onEdit: () =>
                                        _editReply(context, ref, reply),
                                  ),
                                  PantunActionRow.delete(
                                    label: l10n.pantunDelete,
                                    onDelete: () =>
                                        _deleteReply(context, ref, reply),
                                  ),
                                ],
                              )
                            : PantunActionRow.report(
                                onReport: () => reportPantunFromUi(
                                  context,
                                  ref,
                                  targetType: 'pantun_reply',
                                  targetId: reply.id,
                                ),
                              ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
