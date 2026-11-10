import 'package:dio/dio.dart';
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
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/public_account_name.dart';
import '../../../../shared/widgets/thread_audio_player.dart';
import '../../../../shared/widgets/thread_edit_sheets.dart';
import '../../../activity/domain/entities/feed_activity_item.dart';
import '../../../activity/presentation/widgets/activity_kind_avatar.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../../vote/domain/entities/vote_target.dart';
import '../../../vote/presentation/providers/vote_providers.dart';
import '../../../vote/presentation/widgets/vote_buttons.dart';
import '../../data/jinye_providers.dart';
import '../../domain/jinye_models.dart';
import '../../jinye_router.dart';
import '../utils/jinye_quota_message.dart';
import '../widgets/jinye_comments_section.dart';
import '../widgets/jinye_lemma_body.dart';
import '../widgets/jinye_link_lemma_sheet.dart';
import '../widgets/jinye_report_sheet.dart';
import '../widgets/jinye_translation_sheet.dart';
import '../widgets/jinye_word_meaning_sheet.dart';
import '../widgets/jinye_word_picker_sheet.dart';

/// Detail Jinye: media + vote OP; komentar lewat bottom sheet (pola lemma).
class JinyeDetailPage extends ConsumerWidget {
  const JinyeDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(jinyeDetailProvider(id));
    final theme = context.theme;
    final auth = ref.watch(authStatusProvider).value;
    final isAuth = auth?.isAuth ?? false;

    return StopThreadAudioOnLeave(
      child: FScaffold(
        header: FHeader.nested(
          title: Text(l10n.jinyeDetailTitle),
          prefixes: [
            FHeaderAction.back(
              onPress: () =>
                  context.canPop() ? context.pop() : context.go('/'),
            ),
          ],
          suffixes: [
              if (async.hasValue && isAuth)
              FHeaderAction(
                icon: const Icon(FLucideIcons.ellipsisVertical),
                onPress: () {
                  final item = async.requireValue;
                  final isVerifier = _isVerifierRole(auth?.role);
                  if (auth?.userId == item.userId) {
                    _showOwnerActions(
                      context,
                      ref,
                      item: item,
                      isVerifier: isVerifier,
                    );
                  } else {
                    _showVisitorActions(
                      context,
                      ref,
                      item: item,
                      isVerifier: isVerifier,
                    );
                  }
                },
              ),
          ],
        ),
        footer: JinyeCommentEntryBar(jinyeId: id),
        child: async.when(
          loading: () => Skeletonizer(
            enabled: true,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('xxxxxxxx', style: theme.typography.body.md),
                const Gap(8),
                Text('yyyyyyyyyyyyyyyy', style: theme.typography.body.sm),
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
            // Header sama gaya ActivityFeedTile: nama + waktu relatif + @handle.
            final actorLabel = displayPublicAccountLabel(
              displayName: item.displayName,
              username: item.username,
            );
            final canOpenProfile = isLinkablePublicUsername(item.username);
            final dateLabel = formatRelativeCompact(item.createdAt);
            final voteTarget = VoteTarget(type: 'jinye', id: item.id);
            final voteAsync = ref.watch(voteControllerProvider(voteTarget));

            return ListView(
              // Horizontal ketat; top sedikit lebih longgar supaya tidak menempel header.
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: canOpenProfile
                          ? () => UserProfileRouter.open(
                                context,
                                item.username!,
                              )
                          : null,
                      child: ActivityKindAvatar(
                        kind: FeedActivityKind.jinye,
                        imageUrl: item.avatarUrl,
                        name: actorLabel,
                        size: 40,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: PublicAccountName(
                                  label: actorLabel,
                                  isVerifier: item.isVerifier,
                                  onTap: canOpenProfile
                                      ? () => UserProfileRouter.open(
                                            context,
                                            item.username!,
                                          )
                                      : null,
                                  style: theme.typography.body.sm.copyWith(
                                    fontWeight: FontWeight.w700,
                                    height: 1.25,
                                    color: canOpenProfile
                                        ? theme.colors.primary
                                        : theme.colors.foreground,
                                  ),
                                ),
                              ),
                              if (dateLabel.isNotEmpty) ...[
                                const Gap(8),
                                Text(
                                  dateLabel,
                                  style: theme.typography.body.xs.copyWith(
                                    color: theme.colors.mutedForeground,
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (canOpenProfile)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => UserProfileRouter.open(
                                context,
                                item.username!,
                              ),
                              child: Text(
                                '@${item.username}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.typography.body.xs.copyWith(
                                  color: theme.colors.mutedForeground,
                                  fontWeight: FontWeight.w500,
                                  height: 1.25,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                if (item.isPlainRepost) ...[
                  Text(
                    l10n.jinyeRepostLabel,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  const Gap(8),
                  if (item.repostOfId != null)
                    _JinyeQuotedOriginalCard(originalId: item.repostOfId!),
                ] else if (item.isQuote) ...[
                  Text(item.quoteBody!, style: theme.typography.body.md),
                  const Gap(8),
                  if (item.repostOfId != null)
                    _JinyeQuotedOriginalCard(originalId: item.repostOfId!),
                ] else if (item.body.trim().isNotEmpty) ...[
                  JinyeLemmaBody(
                    body: item.body,
                    links: item.lemmaLinks,
                    style: theme.typography.body.md,
                    onLinkLongPress: (link) => _showLemmaLinkActions(
                      context,
                      ref,
                      item: item,
                      link: link,
                      isAuth: isAuth,
                      isOwner: isAuth && auth?.userId == item.userId,
                      isVerifier: _isVerifierRole(auth?.role),
                    ),
                    onWordTap: item.status == 'published'
                        ? (span, link) => _showWordMeaningFromUi(
                              context,
                              ref,
                              item: item,
                              span: span,
                              link: link,
                              isAuth: isAuth,
                            )
                        : null,
                  ),
                  if (item.isEdited) ...[
                    const Gap(4),
                    GestureDetector(
                      onTap: () => _showJinyeEditHistory(context, ref, item),
                      child: Text(
                        l10n.commentEdited,
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.mutedForeground,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                  ref.watch(jinyeTranslationsProvider(id)).when(
                        data: (rows) => _JinyeTranslationsBlock(
                          jinyeId: id,
                          rows: rows,
                          isVerifier: _isVerifierRole(auth?.role),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                ] else if (!item.hasAudio && !item.hasDisplayableImages)
                  Text('-', style: theme.typography.body.md),
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
                  _JinyePendingPhotosBanner(
                    label: l10n.jinyePhotosPendingReview,
                  ),
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
                    const Spacer(),
                    FButton(
                      size: .xs,
                      variant: FButtonVariant.ghost,
                      // Sama pantun/lemma: flag = aksi laporkan.
                      prefix: const Icon(FLucideIcons.flag, size: 14),
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
              ],
            );
          },
        ),
      ),
    );
  }
}

bool _isVerifierRole(String? role) =>
    role == 'admin' || role == 'root' || role == 'reviewer';


/// Tap kata di body → sheet makna (+ Hubungkan / Buka lemma).
Future<void> _showWordMeaningFromUi(
  BuildContext context,
  WidgetRef ref, {
  required JinyeItem item,
  required JinyeSpanSelection span,
  JinyeLemmaLink? link,
  required bool isAuth,
}) async {
  final result = await showJinyeWordMeaningSheet(
    context,
    jinyeId: item.id,
    span: span,
    link: link,
    isAuth: isAuth,
    onLinked: () => ref.invalidate(jinyeDetailProvider(item.id)),
  );
  if (!context.mounted || result == null) return;
  if (result == 'login') {
    context.push('/login');
    return;
  }
  const contributePrefix = 'contribute:';
  if (result.startsWith(contributePrefix)) {
    final lemma = Uri.decodeComponent(result.substring(contributePrefix.length));
    context.push(
      '/contribute?lemma=${Uri.encodeQueryComponent(lemma)}',
    );
    return;
  }
  context.push('/words/$result');
}

Future<void> _promoteExampleFromUi(
  BuildContext context,
  WidgetRef ref, {
  required JinyeItem item,
}) async {
  final l10n = AppLocalizations.of(context);
  final initial = item.lemmaLinks.isNotEmpty
      ? (item.lemmaLinks.first.lemma ?? '')
      : '';
  final word = await showJinyeWordPickerSheet(
    context,
    initialQuery: initial,
  );
  if (word == null || !context.mounted) return;

  var includeAudio = false;
  if (item.hasAudio) {
    final audioChoice = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) {
        final sheetL10n = AppLocalizations.of(ctx);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FTileGroup(
              children: [
                FTile(
                  title: Text(sheetL10n.jinyePromoteWithAudio),
                  onPress: () => Navigator.pop(ctx, true),
                ),
                FTile(
                  title: Text(sheetL10n.jinyePromoteTextOnly),
                  onPress: () => Navigator.pop(ctx, false),
                ),
                FTile(
                  title: Text(sheetL10n.commonCancel),
                  onPress: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ],
        );
      },
    );
    if (audioChoice == null || !context.mounted) return;
    includeAudio = audioChoice;
  }

  try {
    await ref.read(jinyeRepositoryProvider).promoteExample(
          jinyeId: item.id,
          wordId: word.id,
          includeAudio: includeAudio,
        );
    if (!context.mounted) return;
    showFToast(context: context, title: Text(l10n.jinyePromoteSuccess));
  } on DioException catch (e) {
    if (!context.mounted) return;
    final msg = e.response?.data is Map
        ? (e.response!.data as Map)['message']
        : null;
    await showAppErrorSheet(
      context,
      message: msg is String && msg.isNotEmpty
          ? msg
          : l10n.jinyePromoteFailed,
    );
  } catch (_) {
    if (!context.mounted) return;
    await showAppErrorSheet(context, message: l10n.jinyePromoteFailed);
  }
}

Future<void> _translateJinyeFromUi(
  BuildContext context,
  WidgetRef ref, {
  required JinyeItem item,
}) async {
  final l10n = AppLocalizations.of(context);
  final body = await showJinyeTranslationSheet(context);
  if (body == null || body.isEmpty || !context.mounted) return;
  try {
    await ref.read(jinyeRepositoryProvider).createTranslation(
          jinyeId: item.id,
          body: body,
        );
    ref.invalidate(jinyeTranslationsProvider(item.id));
    if (!context.mounted) return;
    showFToast(context: context, title: Text(l10n.jinyeTranslateSuccess));
  } on DioException catch (e) {
    if (!context.mounted) return;
    final msg = e.response?.data is Map
        ? (e.response!.data as Map)['message']
        : null;
    await showAppErrorSheet(
      context,
      message: msg is String && msg.isNotEmpty
          ? msg
          : l10n.jinyeTranslateFailed,
    );
  } catch (_) {
    if (!context.mounted) return;
    await showAppErrorSheet(context, message: l10n.jinyeTranslateFailed);
  }
}

Future<void> _showLemmaLinkActions(
  BuildContext context,
  WidgetRef ref, {
  required JinyeItem item,
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
          initialQuery: link.lemma ??
              (link.start < item.body.length && link.end <= item.body.length
                  ? item.body.substring(link.start, link.end)
                  : ''),
        );
        if (word == null || !context.mounted) return;
        await repo.proposeLemmaCorrection(
          jinyeId: item.id,
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
          jinyeId: item.id,
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
        await repo.deleteLemmaLink(jinyeId: item.id, linkId: link.id);
        if (context.mounted) {
          showFToast(
            context: context,
            title: Text(l10n.jinyeLemmaDeleteSuccess),
          );
        }
      default:
        return;
    }
    ref.invalidate(jinyeDetailProvider(item.id));
  } on DioException catch (e) {
    if (!context.mounted) return;
    final msg = e.response?.data is Map
        ? (e.response!.data as Map)['message']
        : null;
    final fallback = switch (action) {
      'correct' => l10n.jinyeLemmaCorrectionFailed,
      'approve' || 'reject' => l10n.jinyeLemmaResolveFailed,
      'delete' => l10n.jinyeLemmaDeleteFailed,
      _ => l10n.jinyeOwnerActionFailed,
    };
    await showAppErrorSheet(
      context,
      message: msg is String && msg.isNotEmpty ? msg : fallback,
    );
  } catch (_) {
    if (!context.mounted) return;
    await showAppErrorSheet(
      context,
      message: switch (action) {
        'correct' => l10n.jinyeLemmaCorrectionFailed,
        'approve' || 'reject' => l10n.jinyeLemmaResolveFailed,
        'delete' => l10n.jinyeLemmaDeleteFailed,
        _ => l10n.jinyeOwnerActionFailed,
      },
    );
  }
}

Future<void> _showOwnerActions(
  BuildContext context,
  WidgetRef ref, {
  required JinyeItem item,
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
              if (item.status == 'published') ...[
                if (!item.isPlainRepost)
                  FTile(
                    prefix: const Icon(FLucideIcons.pencil, size: 18),
                    title: Text(l10n.jinyeEditAction),
                    onPress: () => Navigator.pop(context, 'edit'),
                  ),
                if (item.isEdited)
                  FTile(
                    prefix: const Icon(FLucideIcons.history, size: 18),
                    title: Text(l10n.jinyeEditHistoryTitle),
                    onPress: () => Navigator.pop(context, 'history'),
                  ),
                FTile(
                  prefix: Icon(
                    item.isPinned ? FLucideIcons.pinOff : FLucideIcons.pin,
                    size: 18,
                  ),
                  title: Text(
                    item.isPinned
                        ? l10n.jinyeUnpinAction
                        : l10n.jinyePinAction,
                  ),
                  onPress: () => Navigator.pop(
                    context,
                    item.isPinned ? 'unpin' : 'pin',
                  ),
                ),
                FTile(
                  prefix: const Icon(FLucideIcons.archive, size: 18),
                  title: Text(l10n.jinyeArchiveAction),
                  onPress: () => Navigator.pop(context, 'archive'),
                ),
                if (item.body.trim().isNotEmpty || item.hasAudio)
                  FTile(
                    prefix: const Icon(FLucideIcons.bookOpen, size: 18),
                    title: Text(l10n.jinyePromoteExampleAction),
                    onPress: () => Navigator.pop(context, 'promote'),
                  ),
                // Terjemahan juga di menu pemilik (boleh usul sendiri).
                if (item.status == 'published' && item.body.trim().isNotEmpty)
                  FTile(
                    prefix: const Icon(FLucideIcons.languages, size: 18),
                    title: Text(l10n.jinyeTranslateAction),
                    onPress: () => Navigator.pop(context, 'translate'),
                  ),
              ],
              if (isVerifier)
                FTile(
                  prefix: const Icon(FLucideIcons.clipboardCheck, size: 18),
                  title: Text(l10n.jinyeTranslateReviewAction),
                  onPress: () => Navigator.pop(context, 'review_translations'),
                ),
              if (item.status == 'archived')
                FTile(
                  prefix: const Icon(FLucideIcons.archiveRestore, size: 18),
                  title: Text(l10n.jinyeUnarchiveAction),
                  onPress: () => Navigator.pop(context, 'unarchive'),
                ),
              FTile(
                prefix: const Icon(FLucideIcons.x, size: 18),
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

  if (action == 'promote') {
    await _promoteExampleFromUi(context, ref, item: item);
    return;
  }
  if (action == 'translate') {
    await _translateJinyeFromUi(context, ref, item: item);
    return;
  }
  if (action == 'review_translations') {
    context.push(JinyeRouter.translationReview.path);
    return;
  }
  if (action == 'edit') {
    await _editJinyeFromUi(context, ref, item: item);
    return;
  }
  if (action == 'history') {
    await _showJinyeEditHistory(context, ref, item);
    return;
  }

  final repo = ref.read(jinyeRepositoryProvider);
  try {
    switch (action) {
      case 'pin':
        await repo.pin(item.id);
        if (context.mounted) {
          showFToast(context: context, title: Text(l10n.jinyePinSuccess));
        }
      case 'unpin':
        await repo.unpin(item.id);
        if (context.mounted) {
          showFToast(context: context, title: Text(l10n.jinyeUnpinSuccess));
        }
      case 'archive':
        await repo.archive(item.id);
        if (context.mounted) {
          showFToast(context: context, title: Text(l10n.jinyeArchiveSuccess));
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        }
        return;
      case 'unarchive':
        await repo.unarchive(item.id);
        if (context.mounted) {
          showFToast(
            context: context,
            title: Text(l10n.jinyeUnarchiveSuccess),
          );
        }
      default:
        return;
    }
    ref.invalidate(jinyeDetailProvider(item.id));
    invalidateJinyeProfileSurfaces(ref, item.username);
  } on DioException catch (e) {
    if (!context.mounted) return;
    final msg = e.response?.data is Map
        ? (e.response!.data as Map)['message']
        : null;
    await showAppErrorSheet(
      context,
      message: msg is String && msg.isNotEmpty
          ? msg
          : l10n.jinyeOwnerActionFailed,
    );
  } catch (_) {
    if (!context.mounted) return;
    await showAppErrorSheet(context, message: l10n.jinyeOwnerActionFailed);
  }
}

Future<void> _showVisitorActions(
  BuildContext context,
  WidgetRef ref, {
  required JinyeItem item,
  required bool isVerifier,
}) async {
  final l10n = AppLocalizations.of(context);
  final canShare = item.status == 'published' && item.repostOfId == null;
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
              if (canShare) ...[
                FTile(
                  prefix: const Icon(FLucideIcons.repeat, size: 18),
                  title: Text(l10n.jinyeRepostAction),
                  onPress: () => Navigator.pop(context, 'repost'),
                ),
                FTile(
                  prefix: const Icon(FLucideIcons.quote, size: 18),
                  title: Text(l10n.jinyeQuoteAction),
                  onPress: () => Navigator.pop(context, 'quote'),
                ),
              ],
              // API: POST translations = login siapa saja (bukan owner-only).
              if (item.status == 'published' && item.body.trim().isNotEmpty)
                FTile(
                  prefix: const Icon(FLucideIcons.languages, size: 18),
                  title: Text(l10n.jinyeTranslateAction),
                  onPress: () => Navigator.pop(context, 'translate'),
                ),
              if (isVerifier)
                FTile(
                  prefix: const Icon(FLucideIcons.clipboardCheck, size: 18),
                  title: Text(l10n.jinyeTranslateReviewAction),
                  onPress: () =>
                      Navigator.pop(context, 'review_translations'),
                ),
              FTile(
                prefix: const Icon(FLucideIcons.x, size: 18),
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
  if (action == 'repost') {
    await _repostJinyeFromUi(context, ref, item: item);
    return;
  }
  if (action == 'quote') {
    await _quoteJinyeFromUi(context, ref, item: item);
    return;
  }
  if (action == 'translate') {
    await _translateJinyeFromUi(context, ref, item: item);
    return;
  }
  if (action == 'review_translations') {
    context.push(JinyeRouter.translationReview.path);
  }
}

Future<void> _editJinyeFromUi(
  BuildContext context,
  WidgetRef ref, {
  required JinyeItem item,
}) async {
  final l10n = AppLocalizations.of(context);
  final repo = ref.read(jinyeRepositoryProvider);
  final saved = await showThreadTextEditSheet(
    context,
    title: l10n.jinyeEditTitle,
    initialBody: item.body,
    saveLabel: l10n.jinyeEditSave,
    onSave: (body) async {
      try {
        await repo.updateBody(id: item.id, body: body);
        return null;
      } on DioException catch (e) {
        final msg = e.response?.data is Map
            ? (e.response!.data as Map)['message']
            : null;
        return msg is String && msg.isNotEmpty ? msg : l10n.jinyeEditFailed;
      } catch (_) {
        return l10n.jinyeEditFailed;
      }
    },
  );
  if (saved == null || !context.mounted) return;
  ref.invalidate(jinyeDetailProvider(item.id));
  showFToast(context: context, title: Text(l10n.jinyeEditSuccess));
}

Future<void> _showJinyeEditHistory(
  BuildContext context,
  WidgetRef ref,
  JinyeItem item,
) async {
  final l10n = AppLocalizations.of(context);
  try {
    final history =
        await ref.read(jinyeRepositoryProvider).editHistory(item.id);
    if (!context.mounted) return;
    await showThreadTextEditHistorySheet(
      context,
      title: l10n.jinyeEditHistoryTitle,
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
    if (!context.mounted) return;
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
    if (!context.mounted) return;
    await showAppErrorSheet(context, message: l10n.jinyeEditHistoryFailed);
  }
}

Future<void> _repostJinyeFromUi(
  BuildContext context,
  WidgetRef ref, {
  required JinyeItem item,
}) async {
  final l10n = AppLocalizations.of(context);
  try {
    await ref.read(jinyeRepositoryProvider).repost(item.id);
    if (!context.mounted) return;
    ref.invalidate(jinyeDetailProvider(item.id));
    final me = ref.read(authStatusProvider).value?.username;
    invalidateJinyeProfileSurfaces(ref, me);
    showFToast(context: context, title: Text(l10n.jinyeRepostSuccess));
  } on DioException catch (e) {
    if (!context.mounted) return;
    final msg = e.response?.data is Map
        ? (e.response!.data as Map)['message']
        : null;
    await showAppErrorSheet(
      context,
      message: msg is String && msg.isNotEmpty
          ? msg
          : l10n.jinyeRepostFailed,
    );
  } catch (_) {
    if (!context.mounted) return;
    await showAppErrorSheet(context, message: l10n.jinyeRepostFailed);
  }
}

Future<void> _quoteJinyeFromUi(
  BuildContext context,
  WidgetRef ref, {
  required JinyeItem item,
}) async {
  final l10n = AppLocalizations.of(context);
  final caption = await showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _JinyeQuoteSheet(original: item),
  );
  if (caption == null || !context.mounted) return;
  try {
    final created = await ref.read(jinyeRepositoryProvider).quote(
          id: item.id,
          quoteBody: caption,
        );
    if (!context.mounted) return;
    final me = ref.read(authStatusProvider).value?.username;
    invalidateJinyeProfileSurfaces(ref, me);
    showFToast(context: context, title: Text(l10n.jinyeQuoteSuccess));
    context.push('/jinye/${created.id}');
  } on DioException catch (e) {
    if (!context.mounted) return;
    final code = e.response?.data is Map
        ? (e.response!.data as Map)['error_code']
        : null;
    final msg = code == 'RATE_LIMITED'
        ? jinyeQuotaRateLimitedMessage(e, l10n)
        : (e.response?.data is Map
            ? (e.response!.data as Map)['message']
            : null);
    await showAppErrorSheet(
      context,
      message: msg is String && msg.isNotEmpty
          ? msg
          : l10n.jinyeQuoteFailed,
    );
  } catch (_) {
    if (!context.mounted) return;
    await showAppErrorSheet(context, message: l10n.jinyeQuoteFailed);
  }
}

class _JinyeQuoteSheet extends StatefulWidget {
  const _JinyeQuoteSheet({required this.original});

  final JinyeItem original;

  @override
  State<_JinyeQuoteSheet> createState() => _JinyeQuoteSheetState();
}

class _JinyeQuoteSheetState extends State<_JinyeQuoteSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final canSubmit = _ctrl.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.jinyeQuoteTitle,
              style: theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FTextField(
              control: FTextFieldControl.managed(
                controller: _ctrl,
                onChange: (_) => setState(() {}),
              ),
              hint: l10n.jinyeQuoteHint,
              maxLines: 4,
              maxLength: 500,
            ),
          ),
          const Gap(8),
          // Cuplikan Jinye yang dikutip - biar penulis tahu konteksnya.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _JinyeOriginalSnippet(item: widget.original),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: FButton(
                onPress: canSubmit
                    ? () => Navigator.pop(context, _ctrl.text.trim())
                    : null,
                child: Text(l10n.jinyeQuoteSubmit),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu ringkas Jinye asli (sheet quote + detail quote/repost).
class _JinyeOriginalSnippet extends StatelessWidget {
  const _JinyeOriginalSnippet({required this.item, this.onTap});

  final JinyeItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final actor = displayPublicAccountLabel(
      displayName: item.displayName,
      username: item.username,
    );
    final body = item.body.trim();
    final preview = body.isNotEmpty
        ? body
        : item.hasAudio
        ? l10n.jinyePreviewVoiceOnly
        : item.images.isNotEmpty
        ? l10n.jinyePreviewPhotoOnly
        : l10n.jinyePreviewEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.border),
          borderRadius: BorderRadius.circular(10),
          color: theme.colors.secondary.withValues(alpha: 0.35),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                actor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (item.username != null && item.username!.trim().isNotEmpty)
                Text(
                  '@${item.username}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              const Gap(6),
              Text(
                preview,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.body.sm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Muat Jinye asli lewat id (detail quote/repost).
class _JinyeQuotedOriginalCard extends ConsumerWidget {
  const _JinyeQuotedOriginalCard({required this.originalId});

  final String originalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final async = ref.watch(jinyeDetailProvider(originalId));

    return async.when(
      loading: () => DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: FCircularProgress(size: .sm),
        ),
      ),
      error: (_, _) => FButton(
        variant: FButtonVariant.outline,
        onPress: () => context.push('/jinye/$originalId'),
        child: Text(l10n.jinyeOpenOriginal),
      ),
      data: (original) => _JinyeOriginalSnippet(
        item: original,
        onTap: () => context.push('/jinye/$originalId'),
      ),
    );
  }
}

/// Keterangan foto pending: icon di kiri-atas (bukan center vertikal FAlert).
class _JinyePendingPhotosBanner extends StatelessWidget {
  const _JinyePendingPhotosBanner({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.secondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon top-left; inset kecil supaya sejajar baseline teks.
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                FLucideIcons.image,
                size: 16,
                color: theme.colors.mutedForeground,
              ),
            ),
            const Gap(10),
            Expanded(
              child: Text(
                label,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JinyeTranslationsBlock extends ConsumerStatefulWidget {
  const _JinyeTranslationsBlock({
    required this.jinyeId,
    required this.rows,
    required this.isVerifier,
  });

  final String jinyeId;
  final List<JinyeTranslation> rows;
  final bool isVerifier;

  @override
  ConsumerState<_JinyeTranslationsBlock> createState() =>
      _JinyeTranslationsBlockState();
}

class _JinyeTranslationsBlockState
    extends ConsumerState<_JinyeTranslationsBlock> {
  String? _busyId;

  Future<void> _resolve(JinyeTranslation row, String action) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busyId = row.id);
    try {
      await ref.read(jinyeRepositoryProvider).resolveTranslation(
            translationId: row.id,
            action: action,
          );
      if (!mounted) return;
      ref.invalidate(jinyeTranslationsProvider(widget.jinyeId));
      ref.invalidate(jinyeTranslationQueueProvider('pending'));
      showFToast(
        context: context,
        title: Text(
          action == 'approve'
              ? l10n.jinyeTranslateResolveApproved
              : l10n.jinyeTranslateResolveRejected,
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
            : l10n.jinyeTranslateResolveFailed,
      );
    } catch (_) {
      if (!mounted) return;
      await showAppErrorSheet(
        context,
        message: l10n.jinyeTranslateResolveFailed,
      );
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final accepted = widget.rows.where((t) => t.isAccepted).toList();
    final pending = widget.rows.where((t) => t.isPending).toList();

    if (accepted.isEmpty && !(widget.isVerifier && pending.isNotEmpty)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (accepted.isNotEmpty)
            Text(
              accepted.first.body,
              style: theme.typography.body.md.copyWith(
                color: theme.colors.mutedForeground,
                fontStyle: FontStyle.italic,
              ),
            ),
          if (widget.isVerifier && pending.isNotEmpty) ...[
            const Gap(8),
            Text(
              l10n.jinyeTranslatePendingSection,
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(4),
            for (final row in pending) ...[
              if (row.sourceBody.trim().isNotEmpty) ...[
                Text(
                  l10n.jinyeTranslateReviewSourceLabel,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                Text(row.sourceBody, style: theme.typography.body.md),
                const Gap(4),
              ],
              Text(
                l10n.jinyeTranslateReviewBodyLabel,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              Text(row.body, style: theme.typography.body.md),
              const Gap(6),
              Row(
                children: [
                  FButton(
                    onPress: _busyId != null
                        ? null
                        : () => _resolve(row, 'approve'),
                    prefix: _busyId == row.id
                        ? const FCircularProgress()
                        : null,
                    child: Text(l10n.jinyeTranslateApproveAction),
                  ),
                  const Gap(8),
                  FButton(
                    variant: FButtonVariant.outline,
                    onPress: _busyId != null
                        ? null
                        : () => _resolve(row, 'reject'),
                    child: Text(l10n.jinyeTranslateRejectAction),
                  ),
                ],
              ),
              const Gap(8),
            ],
          ],
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
