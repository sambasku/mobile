import 'package:material_ui/material_ui.dart'
    show RefreshIndicator, Material, InkWell, Colors, showModalBottomSheet;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../data/pantun_api.dart';
import '../../domain/pantun_models.dart';
import '../providers/pantun_providers.dart';
import '../widgets/pantun_card.dart';

/// Detail pantun pembuka + thread balasan, disusun seperti Ruang Diskusi:
/// header konteks di atas, balasan menjorok sebagai baris thread.
///
/// [highlightReplyId] diisi dari deep-link hasil pencarian
/// (`/entertainment/pantun/:id?reply=:replyId`): halaman auto-scroll ke
/// balasan itu dan menyorotnya sebentar.
class PantunDetailPage extends HookConsumerWidget {
  const PantunDetailPage({
    super.key,
    required this.id,
    this.highlightReplyId,
  });

  final String id;
  final String? highlightReplyId;

  Future<void> _openReply(BuildContext context, WidgetRef ref) async {
    final auth = await ref.read(authStatusProvider.future);
    if (!auth.isAuth) {
      if (context.mounted) {
        await showAppErrorSheet(
          context,
          message: 'Login dulu ya sebelum membalas pantun.',
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

  Future<void> _deleteReply(
    BuildContext context,
    WidgetRef ref,
    Pantun reply,
  ) async {
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
                  title: const Text('Hapus balasan?'),
                  subtitle: const Text('Balasan akan dihapus dari thread pantun.'),
                ),
                FTile(
                  title: const SizedBox.shrink(),
                  suffix: FButton(
                    variant: FButtonVariant.destructive,
                    onPress: () => Navigator.of(sheetContext).pop(true),
                    child: const Text('Hapus'),
                  ),
                ),
                FTile(
                  title: const SizedBox.shrink(),
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
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(pantunApiProvider).deleteReply(reply.id);
      ref.invalidate(pantunDetailProvider(id));
      if (context.mounted) {
        showFToast(
          context: context,
          title: const Text('Balasan dihapus'),
          variant: FToastVariant.primary,
        );
      }
    } on PantunFailure catch (e) {
      if (context.mounted) {
        await showAppErrorSheet(context, message: e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
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
        title: const Text('Pantun'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      footer: FButton(
        onPress: () => _openReply(context, ref),
        child: const Text('Balas pantun'),
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
                e is PantunFailure
                    ? e.message
                    : 'Gagal memuat pantun. Coba lagi ya.',
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
              ),
              const Gap(14),
              Text(
                detail.replies.isEmpty
                    ? 'Balasan'
                    : 'Balasan · ${detail.replies.length}',
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(8),
              if (detail.replies.isEmpty)
                Text(
                  'Belum ada balasan. Balas dulu, yuk.',
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
                        highlighted: reply.id == highlightReplyId,
                        onUsernameTap:
                            isLinkablePublicUsername(reply.username)
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
                        footer: reply.userId == myUserId
                            ? _ReplyDeleteRow(
                                onDelete: () =>
                                    _deleteReply(context, ref, reply),
                              )
                            : null,
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

/// Aksi hapus milik penulis balasan, sejajar dengan footer thread diskusi.
class _ReplyDeleteRow extends StatelessWidget {
  const _ReplyDeleteRow({required this.onDelete});

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        button: true,
        label: 'Hapus balasan',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: onDelete,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FLucideIcons.trash,
                    size: 14,
                    color: theme.colors.mutedForeground,
                  ),
                  const Gap(4),
                  Text(
                    'Hapus',
                    style: theme.typography.body.sm.copyWith(
                      fontSize: 11,
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
