import 'package:material_ui/material_ui.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/record_thread_audio_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/chat_models.dart';
import '../providers/chat_messages_provider.dart';
import '../providers/chat_presence_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_composer.dart';
import '../widgets/chat_new_messages_chip.dart';
import '../widgets/chat_presence_badge.dart';
import '../widgets/chat_sticker_sheet.dart';
import '../widgets/discussion_hub_segment.dart';
import '../../../voice/presentation/widgets/voice_room_strip.dart';

/// Stream chat publik (satu channel). Dipakai dari tab hub Diskusi.
class ChatPage extends HookConsumerWidget {
  const ChatPage({super.key, required this.onSelectRoomsTab});

  final VoidCallback onSelectRoomsTab;

  static const _nearBottomPx = 80.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(chatMessagesProvider);
    final auth = ref.watch(authStatusProvider).value;
    final isAuth = auth?.isAuth ?? false;
    final myUserId = auth?.userId;

    final scroll = useScrollController();
    final textController = useTextEditingController();
    final replyTarget = useState<ChatMessage?>(null);
    final sending = useState(false);
    final nearBottom = useState(true);
    final newCount = useState(0);
    final pinnedBottom = useRef(true);
    final didInitialScroll = useRef(false);

    void promptLogin() {
      showFToast(context: context, title: Text(l10n.chatLoginToSend));
      context.push('/login');
    }

    Future<void> scrollToBottom({bool animate = true}) async {
      if (!scroll.hasClients) return;
      final target = scroll.position.maxScrollExtent;
      if (animate) {
        await scroll.animateTo(
          target,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      } else {
        scroll.jumpTo(target);
      }
      nearBottom.value = true;
      pinnedBottom.value = true;
      newCount.value = 0;
    }

    void updateNearBottom() {
      if (!scroll.hasClients) return;
      final pos = scroll.position;
      final atBottom = pos.maxScrollExtent - pos.pixels <= _nearBottomPx;
      nearBottom.value = atBottom;
      pinnedBottom.value = atBottom;
      if (atBottom) newCount.value = 0;
    }

    final presenceKey = useMemoized(() {
      final id = myUserId?.trim();
      if (id != null && id.isNotEmpty) return id;
      return 'guest-${DateTime.now().microsecondsSinceEpoch}';
    }, [myUserId]);

    useEffect(() {
      final auth = ref.read(authStatusProvider).value;
      final name = (auth?.displayName?.trim().isNotEmpty == true)
          ? auth!.displayName!.trim()
          : (auth?.username?.trim().isNotEmpty == true)
              ? auth!.username!.trim()
              : l10n.chatPresenceGuestName;
      ref.read(chatPresenceCountProvider.notifier).enter(
            presenceKey: presenceKey,
            name: name,
            userId: auth?.userId,
          );
      return () {
        ref.read(chatPresenceCountProvider.notifier).leave();
      };
    }, [presenceKey]);

    useEffect(() {
      void listener() => updateNearBottom();
      scroll.addListener(listener);
      return () => scroll.removeListener(listener);
    }, [scroll]);

    // Loncat ke bawah sekali saat histori pertama siap.
    useEffect(() {
      final items = async.asData?.value.items;
      if (didInitialScroll.value) return null;
      if (items == null || items.isEmpty) return null;
      didInitialScroll.value = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        scrollToBottom(animate: false);
      });
      return null;
    }, [async.asData?.value.items.length]);

    useEffect(() {
      void onResume(AppLifecycleState state) {
        if (state == AppLifecycleState.resumed) {
          ref.read(chatMessagesProvider.notifier).fetchNewer().then((added) {
            if (!context.mounted || added <= 0) return;
            if (pinnedBottom.value) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                scrollToBottom(animate: false);
              });
            } else {
              newCount.value += added;
            }
          });
        }
      }

      final observer = _LifecycleObserver(onResume);
      WidgetsBinding.instance.addObserver(observer);
      return () => WidgetsBinding.instance.removeObserver(observer);
    }, const []);

    ref.listen(chatMessagesProvider.select((s) => s.value?.errorMessage), (
      _,
      msg,
    ) {
      if (msg == null || !context.mounted) return;
      final code = ref.read(chatMessagesProvider).value?.errorCode;
      if (code == 'RATE_LIMITED') {
        showFToast(context: context, title: Text(msg));
        ref.read(chatMessagesProvider.notifier).clearError();
        return;
      }
      showAppErrorSheet(context, message: msg).whenComplete(() {
        if (context.mounted) {
          ref.read(chatMessagesProvider.notifier).clearError();
        }
      });
    });

    // Auto-scroll saat item bertambah dan kita di dekat bawah / kiriman sendiri.
    ref.listen(chatMessagesProvider.select((s) => s.value?.items.length ?? 0), (
      prev,
      next,
    ) {
      if (prev == null || next <= prev) return;
      final delta = next - prev;
      if (pinnedBottom.value) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          scrollToBottom(animate: true);
        });
      } else if (!sending.value) {
        newCount.value += delta;
      }
    });

    Future<void> confirmDelete(ChatMessage message) async {
      final ok = await showModalBottomSheet<bool>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (sheetContext) {
          final sheetL10n = AppLocalizations.of(sheetContext);
          return Padding(
            padding: MediaQuery.of(sheetContext).viewInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FTileGroup(
                  children: [
                    FTile(
                      title: Text(sheetL10n.chatDeleteConfirmTitle),
                      subtitle: Text(sheetL10n.chatDeleteConfirmBody),
                    ),
                    FTile(
                      title: const SizedBox.shrink(),
                      suffix: FButton(
                        variant: FButtonVariant.destructive,
                        onPress: () => Navigator.pop(sheetContext, true),
                        child: Text(sheetL10n.chatDeleteAction),
                      ),
                    ),
                    FTile(
                      title: const SizedBox.shrink(),
                      suffix: FButton(
                        onPress: () => Navigator.pop(sheetContext, false),
                        child: Text(sheetL10n.commonCancel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
      if (ok != true || !context.mounted) return;
      final failure = await ref
          .read(chatMessagesProvider.notifier)
          .deleteMessage(message.id);
      if (failure != null && context.mounted) {
        await showAppErrorSheet(context, message: failure.message);
      }
    }

    Future<void> sendText() async {
      if (!isAuth) {
        promptLogin();
        return;
      }
      final body = textController.text;
      if (body.trim().isEmpty || sending.value) return;
      sending.value = true;
      pinnedBottom.value = true;
      final reply = replyTarget.value;
      textController.clear();
      replyTarget.value = null;
      final failure = await ref
          .read(chatMessagesProvider.notifier)
          .sendText(
            body: body,
            replyToId: reply?.id,
            replySnippet: reply == null
                ? null
                : (reply.isDeleted
                      ? l10n.chatTombstone
                      : switch (reply.kind) {
                          ChatMessageKind.sticker =>
                            l10n.chatReplySnippetSticker,
                          ChatMessageKind.voiceNote =>
                            l10n.chatReplySnippetVoice,
                          ChatMessageKind.text => reply.body,
                        }),
            replyUsername: reply?.username,
          );
      sending.value = false;
      if (!context.mounted) return;
      if (failure != null) {
        await showAppErrorSheet(context, message: failure.message);
        return;
      }
      await scrollToBottom();
    }

    Future<void> sendSticker() async {
      if (!isAuth) {
        promptLogin();
        return;
      }
      final stickerId = await showChatStickerSheet(context);
      if (stickerId == null || !context.mounted) return;
      sending.value = true;
      pinnedBottom.value = true;
      final reply = replyTarget.value;
      replyTarget.value = null;
      final failure = await ref
          .read(chatMessagesProvider.notifier)
          .sendSticker(
            stickerId: stickerId,
            replyToId: reply?.id,
            replySnippet: reply == null
                ? null
                : (reply.isDeleted
                      ? l10n.chatTombstone
                      : switch (reply.kind) {
                          ChatMessageKind.sticker =>
                            l10n.chatReplySnippetSticker,
                          ChatMessageKind.voiceNote =>
                            l10n.chatReplySnippetVoice,
                          ChatMessageKind.text => reply.body,
                        }),
            replyUsername: reply?.username,
          );
      sending.value = false;
      if (!context.mounted) return;
      if (failure != null) {
        await showAppErrorSheet(context, message: failure.message);
        return;
      }
      await scrollToBottom();
    }

    Future<void> recordVoice() async {
      if (!isAuth) {
        promptLogin();
        return;
      }
      final recorded = await showRecordThreadAudioSheet(
        context,
        title: l10n.chatRecordSheetTitle,
        subtitle: l10n.chatRecordSheetSubtitle,
        submitLabel: l10n.chatRecordSheetSubmit,
        minSeconds: 1,
        maxSeconds: 60,
      );
      if (recorded == null || !context.mounted) return;
      sending.value = true;
      pinnedBottom.value = true;
      final reply = replyTarget.value;
      replyTarget.value = null;
      final failure = await ref
          .read(chatMessagesProvider.notifier)
          .sendVoice(
            audioFile: recorded.file,
            durationMs: recorded.durationMs,
            replyToId: reply?.id,
            replySnippet: reply == null
                ? null
                : (reply.isDeleted
                      ? l10n.chatTombstone
                      : switch (reply.kind) {
                          ChatMessageKind.sticker =>
                            l10n.chatReplySnippetSticker,
                          ChatMessageKind.voiceNote =>
                            l10n.chatReplySnippetVoice,
                          ChatMessageKind.text => reply.body,
                        }),
            replyUsername: reply?.username,
          );
      sending.value = false;
      if (!context.mounted) return;
      if (failure != null) {
        await showAppErrorSheet(context, message: failure.message);
        return;
      }
      await scrollToBottom();
    }

    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    // Keyboard: padding manual di Column (list + composer naik bareng).
    // resizeToAvoidBottomInset false - Forui footer/body quirk memotong list
    // tanpa menggeser konten chat.
    useEffect(() {
      if (keyboardInset <= 0) return null;
      if (!pinnedBottom.value) return null;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        scrollToBottom(animate: false);
      });
      return null;
    }, [keyboardInset]);

    return FScaffold(
      childPad: true,
      resizeToAvoidBottomInset: false,
      header: FHeader.nested(
        title: Text(l10n.discussionHubTitle),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: Column(
          children: [
            DiscussionHubSegment(
              index: 1,
              onChanged: (i) {
                if (i == 0) onSelectRoomsTab();
              },
            ),
            const ChatPresenceBadge(),
            const VoiceRoomStrip(),
            Expanded(
              child: Stack(
                children: [
                async.when(
                  loading: () =>
                      const Center(child: FCircularProgress(size: .md)),
                  error: (error, _) => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    children: [
                      Icon(
                        FLucideIcons.circleAlert,
                        size: 40,
                        color: context.theme.colors.mutedForeground,
                      ),
                      const Gap(10),
                      Text(
                        error is ChatFailure
                            ? error.message
                            : l10n.chatLoadFailed,
                        textAlign: TextAlign.center,
                        style: context.theme.typography.body.sm.copyWith(
                          color: context.theme.colors.mutedForeground,
                        ),
                      ),
                      const Gap(16),
                      FButton(
                        variant: FButtonVariant.outline,
                        onPress: () => ref.invalidate(chatMessagesProvider),
                        child: Text(l10n.chatRetry),
                      ),
                    ],
                  ),
                  data: (state) {
                    if (state.items.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () =>
                            ref.read(chatMessagesProvider.notifier).refresh(),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          children: [
                            Icon(
                              FLucideIcons.messageCircle,
                              size: 40,
                              color: context.theme.colors.mutedForeground,
                            ),
                            const Gap(10),
                            Text(
                              l10n.chatEmpty,
                              textAlign: TextAlign.center,
                              style: context.theme.typography.body.md.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Gap(6),
                            Text(
                              l10n.chatEmptyBody,
                              textAlign: TextAlign.center,
                              style: context.theme.typography.body.sm.copyWith(
                                color: context.theme.colors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(chatMessagesProvider.notifier).refresh();
                        if (context.mounted) {
                          await scrollToBottom(animate: false);
                        }
                      },
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (n) {
                          if (n.metrics.pixels <= 80 &&
                              state.hasMoreOlder &&
                              !state.isLoadingOlder) {
                            ref.read(chatMessagesProvider.notifier).loadOlder();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          controller: scroll,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
                          itemCount:
                              state.items.length +
                              (state.isLoadingOlder ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (state.isLoadingOlder && index == 0) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: FCircularProgress(size: .sm),
                                ),
                              );
                            }
                            final itemIndex = state.isLoadingOlder
                                ? index - 1
                                : index;
                            final items = state.items;
                            final message = items[itemIndex];
                            final prev =
                                itemIndex > 0 ? items[itemIndex - 1] : null;
                            final next = itemIndex < items.length - 1
                                ? items[itemIndex + 1]
                                : null;
                            final mine =
                                myUserId != null &&
                                myUserId.isNotEmpty &&
                                message.userId == myUserId;
                            final sameAuthorAsPrev =
                                prev != null &&
                                prev.userId == message.userId;
                            final sameAuthorAsNext =
                                next != null &&
                                next.userId == message.userId;
                            final sameMinuteAsNext =
                                next != null &&
                                _sameLocalMinute(
                                  message.createdAt,
                                  next.createdAt,
                                );
                            // Jam hanya di akhir run: orang sama + menit sama.
                            final showTime = message.pending ||
                                !(sameAuthorAsNext && sameMinuteAsNext);
                            final showName = !mine && !sameAuthorAsPrev;
                            final clustered =
                                sameAuthorAsPrev ||
                                (sameAuthorAsNext && sameMinuteAsNext);
                            return ChatBubble(
                              message: message,
                              mine: mine,
                              showName: showName,
                              showTime: showTime,
                              clustered: clustered,
                              onReply: () => replyTarget.value = message,
                              onDelete: mine && !message.isDeleted
                                  ? () => confirmDelete(message)
                                  : null,
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                if (newCount.value > 0)
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: ChatNewMessagesChip(
                      count: newCount.value,
                      onPress: () => scrollToBottom(),
                    ),
                  ),
              ],
            ),
          ),
            ChatComposer(
              controller: textController,
              enabled: isAuth,
              sending: sending.value,
              replyTarget: replyTarget.value,
              onClearReply: () => replyTarget.value = null,
              onSendText: sendText,
              onOpenStickers: sendSticker,
              onRecordVoice: recordVoice,
              onLoginPrompt: promptLogin,
            ),
          ],
        ),
      ),
    );
  }
}

bool _sameLocalMinute(String isoA, String isoB) {
  final a = DateTime.tryParse(isoA)?.toLocal();
  final b = DateTime.tryParse(isoB)?.toLocal();
  if (a == null || b == null) return false;
  return a.year == b.year &&
      a.month == b.month &&
      a.day == b.day &&
      a.hour == b.hour &&
      a.minute == b.minute;
}

class _LifecycleObserver with WidgetsBindingObserver {
  _LifecycleObserver(this.onState);

  final void Function(AppLifecycleState state) onState;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => onState(state);
}
