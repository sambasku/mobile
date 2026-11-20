import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/widgets/record_thread_audio_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/chat_models.dart';
import '../providers/chat_messages_provider.dart';
import '../providers/chat_presence_provider.dart';
import '../providers/chat_typing_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_composer.dart';
import '../widgets/chat_new_messages_chip.dart';
import '../widgets/chat_ping_action.dart';
import '../widgets/chat_privacy_warning.dart';
import '../widgets/chat_sticker_sheet.dart';
import '../widgets/chat_system_line.dart';
import '../widgets/discussion_hub_segment.dart';
import '../../../voice/presentation/widgets/voice_room_strip.dart';

/// Stream chat publik (satu channel). Dipakai dari tab hub Diskusi.
///
/// [embeddedInHub] = true: hanya isi body (chrome di [DiscussionHubShell]).
class ChatPage extends HookConsumerWidget {
  const ChatPage({
    super.key,
    this.embeddedInHub = false,
    this.embeddedInSheet = false,
    this.onSelectRoomsTab,
  });

  /// Bila true, tanpa FScaffold/header/segment (shell hub yang punya).
  final bool embeddedInHub;

  /// Bottom sheet dari VoiceRoomMiniBar - body chat tanpa strip voice.
  final bool embeddedInSheet;

  /// Dipakai hanya jika [embeddedInHub] false (standalone).
  final VoidCallback? onSelectRoomsTab;

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
    final bubbleKeys = useRef<Map<String, GlobalKey>>({});
    final highlightId = useState<String?>(null);
    final highlightTimer = useRef<Timer?>(null);
    // Prefiks `@username ` yang disisip saat balas (pola komentar).
    final replyMentionPrefix = useRef<String?>(null);

    useEffect(
      () =>
          () => highlightTimer.value?.cancel(),
      const [],
    );

    void stripReplyMention() {
      final prefix = replyMentionPrefix.value;
      replyMentionPrefix.value = null;
      if (prefix == null) return;
      final text = textController.text;
      if (!text.startsWith(prefix)) return;
      final rest = text.substring(prefix.length);
      textController.value = TextEditingValue(
        text: rest,
        selection: TextSelection.collapsed(offset: rest.length),
      );
    }

    void startReply(ChatMessage message) {
      if (message.kind == ChatMessageKind.system) return;
      stripReplyMention();
      replyTarget.value = message;
      final me = auth?.username;
      final username = message.username;
      if (!isLinkablePublicUsername(username)) return;
      if (me != null && username!.toLowerCase() == me.toLowerCase()) return;
      final mention = '@$username ';
      replyMentionPrefix.value = mention;
      final current = textController.text;
      if (current.startsWith(mention)) {
        textController.selection = TextSelection.collapsed(
          offset: mention.length,
        );
        return;
      }
      textController.value = TextEditingValue(
        text: '$mention$current',
        selection: TextSelection.collapsed(offset: mention.length),
      );
    }

    void clearReply() {
      stripReplyMention();
      replyTarget.value = null;
    }

    GlobalKey keyFor(String id) =>
        bubbleKeys.value.putIfAbsent(id, GlobalKey.new);

    Future<void> jumpToMessage(String id) async {
      final items = ref.read(chatMessagesProvider).asData?.value.items;
      if (items == null || !context.mounted) return;
      final index = items.indexWhere((m) => m.id == id);
      if (index < 0) {
        showFToast(context: context, title: Text(l10n.chatReplyTargetMissing));
        return;
      }

      void mark() {
        highlightId.value = id;
        highlightTimer.value?.cancel();
        highlightTimer.value = Timer(const Duration(milliseconds: 1400), () {
          if (highlightId.value == id) highlightId.value = null;
        });
      }

      Future<bool> reveal() async {
        final target = keyFor(id).currentContext;
        if (target == null || !target.mounted) return false;
        await Scrollable.ensureVisible(
          target,
          alignment: 0.35,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
        if (!context.mounted) return true;
        mark();
        return true;
      }

      if (await reveal()) return;
      if (!scroll.hasClients) return;

      // Item belum kebangun. Geser satu viewport per frame sampai key-nya ada.
      for (var attempt = 0; attempt < 24; attempt++) {
        if (!context.mounted || !scroll.hasClients) return;
        final visible = <int>[];
        for (var i = 0; i < items.length; i++) {
          final built = keyFor(items[i].id).currentContext;
          if (built != null && built.mounted) visible.add(i);
        }
        if (visible.isEmpty) break;
        final pos = scroll.position;
        if (!pos.hasContentDimensions) break;
        // reverse:true → pesan lama di pixels lebih besar (visual atas).
        final towardOlder = index < visible.first;
        final delta = pos.viewportDimension * 0.85;
        final next =
            (towardOlder ? pos.pixels + delta : pos.pixels - delta).clamp(
              pos.minScrollExtent,
              pos.maxScrollExtent,
            );
        if ((next - pos.pixels).abs() < 1) break;
        scroll.jumpTo(next);
        await SchedulerBinding.instance.endOfFrame;
        if (await reveal()) return;
      }
      if (!context.mounted) return;
      showFToast(context: context, title: Text(l10n.chatReplyTargetMissing));
    }

    void promptLogin() {
      showFToast(context: context, title: Text(l10n.chatLoginToSend));
      context.push('/login');
    }

    Future<void> scrollToBottom({bool animate = true}) async {
      if (!scroll.hasClients) return;
      final position = scroll.position;
      // Geometry sliver belum siap → jump memicu crash semantics
      // (viewport.dart visitChildrenForSemantics geometry!).
      if (!position.hasContentDimensions) return;
      // reverse:true → bawah chat = offset 0.
      const target = 0.0;
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
      // reverse:true → dekat bawah = pixels kecil.
      final atBottom = pos.pixels <= _nearBottomPx;
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
      // Capture notifier: jangan pakai WidgetRef di cleanup (unmounted).
      final presence = ref.read(chatPresenceCountProvider.notifier);
      presence.enter(
        presenceKey: presenceKey,
        name: name,
        userId: auth?.userId,
      );
      return () {
        // Jangan ubah provider di tengah dispose/build shell.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(presence.leave());
        });
      };
    }, [presenceKey]);

    useEffect(() {
      final typing = ref.read(chatTypingProvider.notifier);
      typing.startListening(selfUserId: myUserId);
      return () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(typing.stopListening());
        });
      };
    }, [myUserId]);

    useEffect(() {
      void onText() {
        if (!isAuth || myUserId == null) return;
        final auth = ref.read(authStatusProvider).value;
        final name = (auth?.displayName?.trim().isNotEmpty == true)
            ? auth!.displayName!.trim()
            : (auth?.username?.trim().isNotEmpty == true)
            ? auth!.username!.trim()
            : l10n.chatPresenceGuestName;
        ref
            .read(chatTypingProvider.notifier)
            .onLocalTextChanged(
              userId: myUserId,
              name: name,
              text: textController.text,
            );
      }

      textController.addListener(onText);
      return () => textController.removeListener(onText);
    }, [isAuth, myUserId, textController]);

    useEffect(() {
      void listener() => updateNearBottom();
      scroll.addListener(listener);
      return () => scroll.removeListener(listener);
    }, [scroll]);

    // reverse:true sudah menempel di pesan terbaru (offset 0) - tanpa
    // jumpTo berulang yang terasa "tiba-tiba scroll" saat masuk.
    useEffect(() {
      final items = async.asData?.value.items;
      if (didInitialScroll.value) return null;
      if (items == null || items.isEmpty) return null;
      didInitialScroll.value = true;
      nearBottom.value = true;
      pinnedBottom.value = true;
      newCount.value = 0;
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
      replyMentionPrefix.value = null;
      replyTarget.value = null;
      if (myUserId != null) {
        final auth = ref.read(authStatusProvider).value;
        final name = (auth?.displayName?.trim().isNotEmpty == true)
            ? auth!.displayName!.trim()
            : (auth?.username?.trim().isNotEmpty == true)
            ? auth!.username!.trim()
            : l10n.chatPresenceGuestName;
        unawaited(
          ref
              .read(chatTypingProvider.notifier)
              .stopLocalTyping(userId: myUserId, name: name),
        );
      }
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
                          ChatMessageKind.system =>
                            l10n.chatReplySnippetSystem,
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
      stripReplyMention();
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
                          ChatMessageKind.system =>
                            l10n.chatReplySnippetSystem,
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
      stripReplyMention();
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
                          ChatMessageKind.system =>
                            l10n.chatReplySnippetSystem,
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

    final presenceCount = ref.watch(chatPresenceCountProvider);
    final chatChromeTitle = presenceCount > 0
        ? l10n.discussionTabChatWithCount(presenceCount)
        : l10n.discussionTabChat;

    final body = Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Column(
        children: [
          if (embeddedInSheet)
            _ChatSheetHeader(
              title: chatChromeTitle,
              closeLabel: l10n.commonClose,
              onClose: () => Navigator.of(context).pop(),
            ),
          if (!embeddedInHub && !embeddedInSheet)
            DiscussionHubSegment(
              index: 1,
              onChanged: (i) {
                if (i == 0) onSelectRoomsTab?.call();
              },
            ),
          // Warning publik paling atas, lalu voice room.
          // Horizontal: di hub ikut childPad scaffold (sejajar tab);
          // di sheet pakai 12 sama header sheet. Jangan +12 lagi di hub.
          Padding(
            // Hub: 4 = sama FTabs.padding default (.all(4)) supaya sejajar track tab.
            // Sheet: 12 = sama padding header sheet.
            padding: EdgeInsets.fromLTRB(
              embeddedInSheet ? 12 : 4,
              8,
              embeddedInSheet ? 12 : 4,
              4,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ChatPrivacyWarning(),
                if (!embeddedInSheet) const VoiceRoomStrip(),
              ],
            ),
          ),
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
                                style: context.theme.typography.body.md
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                              const Gap(6),
                              Text(
                                l10n.chatEmptyBody,
                                textAlign: TextAlign.center,
                                style: context.theme.typography.body.sm
                                    .copyWith(
                                      color:
                                          context.theme.colors.mutedForeground,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }

                      // reverse:true = pesan baru di bawah tanpa jump awal.
                      // Pull-to-refresh dihilangkan: reverse membuat gesture
                      // di sisi composer; histori lama lewat scroll ke atas.
                      return NotificationListener<ScrollNotification>(
                        onNotification: (n) {
                          final metrics = n.metrics;
                          final nearOldest =
                              metrics.maxScrollExtent - metrics.pixels <= 80;
                          if (nearOldest &&
                              state.hasMoreOlder &&
                              !state.isLoadingOlder) {
                            ref
                                .read(chatMessagesProvider.notifier)
                                .loadOlder();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          controller: scroll,
                          reverse: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          // reverse membalik padding: top → sisi composer.
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
                          itemCount:
                              state.items.length +
                              (state.isLoadingOlder ? 1 : 0),
                          itemBuilder: (context, index) {
                            final items = state.items;
                            // index 0 = terbaru (bawah). Spinner lama di ujung.
                            if (state.isLoadingOlder &&
                                index == items.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: FCircularProgress(size: .sm),
                                ),
                              );
                            }
                            final itemIndex = items.length - 1 - index;
                            final message = items[itemIndex];
                            final prev = itemIndex > 0
                                ? items[itemIndex - 1]
                                : null;
                            final next = itemIndex < items.length - 1
                                ? items[itemIndex + 1]
                                : null;
                            final mine =
                                myUserId != null &&
                                myUserId.isNotEmpty &&
                                message.userId == myUserId;
                            if (message.kind == ChatMessageKind.system) {
                              final sameMinuteAsNext =
                                  next != null &&
                                  next.kind == ChatMessageKind.system &&
                                  _sameLocalMinute(
                                    message.createdAt,
                                    next.createdAt,
                                  );
                              return ChatSystemLine(
                                key: keyFor(message.id),
                                message: message,
                                showTime: !sameMinuteAsNext,
                              );
                            }
                            final sameAuthorAsPrev =
                                prev != null &&
                                prev.kind != ChatMessageKind.system &&
                                prev.userId == message.userId;
                            final sameAuthorAsNext =
                                next != null &&
                                next.kind != ChatMessageKind.system &&
                                next.userId == message.userId;
                            final sameMinuteAsNext =
                                next != null &&
                                next.kind != ChatMessageKind.system &&
                                _sameLocalMinute(
                                  message.createdAt,
                                  next.createdAt,
                                );
                            // Jam hanya di akhir run: orang sama + menit sama.
                            final showTime =
                                message.pending ||
                                !(sameAuthorAsNext && sameMinuteAsNext);
                            final showName = !mine && !sameAuthorAsPrev;
                            final clustered =
                                sameAuthorAsPrev ||
                                (sameAuthorAsNext && sameMinuteAsNext);
                            return ChatBubble(
                              key: keyFor(message.id),
                              message: message,
                              mine: mine,
                              showName: showName,
                              showTime: showTime,
                              clustered: clustered,
                              highlighted: highlightId.value == message.id,
                              onReply: () => startReply(message),
                              onJumpToReply: message.replyToId == null
                                  ? null
                                  : () => jumpToMessage(message.replyToId!),
                              onDelete: mine && !message.isDeleted
                                  ? () => confirmDelete(message)
                                  : null,
                            );
                          },
                        ),
                      );
                    },
                  ),
                  if (!nearBottom.value && newCount.value == 0)
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: ChatScrollToBottomButton(
                        onPress: () => scrollToBottom(),
                      ),
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
              onClearReply: clearReply,
              onJumpToReply: () {
                final id = replyTarget.value?.id;
                if (id != null) jumpToMessage(id);
              },
              onSendText: sendText,
              onOpenStickers: sendSticker,
              onRecordVoice: recordVoice,
              onLoginPrompt: promptLogin,
            ),
          ],
        ),
      );

    if (embeddedInHub || embeddedInSheet) {
      return body;
    }

    return FScaffold(
      childPad: true,
      resizeToAvoidBottomInset: false,
      header: FHeader.nested(
        title: Text(chatChromeTitle),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        suffixes: const [ChatPingAction()],
      ),
      child: body,
    );
  }
}


class _ChatSheetHeader extends StatelessWidget {
  const _ChatSheetHeader({
    required this.title,
    required this.closeLabel,
    required this.onClose,
  });

  final String title;
  final String closeLabel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const ChatPingAction(),
          Semantics(
            button: true,
            label: closeLabel,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClose,
              child: SizedBox(
                width: 36,
                height: 36,
                child: Icon(
                  FLucideIcons.x,
                  size: 18,
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          ),
        ],
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
