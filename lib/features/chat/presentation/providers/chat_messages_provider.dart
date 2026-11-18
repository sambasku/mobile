import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/chat_providers.dart';
import '../../data/chat_realtime.dart';
import '../../domain/chat_models.dart';

class ChatMessagesState {
  const ChatMessagesState({
    this.items = const [],
    this.hasMoreOlder = false,
    this.isLoadingOlder = false,
    this.errorMessage,
    this.errorCode,
  });

  final List<ChatMessage> items;
  final bool hasMoreOlder;
  final bool isLoadingOlder;
  final String? errorMessage;
  final String? errorCode;

  ChatMessagesState copyWith({
    List<ChatMessage>? items,
    bool? hasMoreOlder,
    bool? isLoadingOlder,
    String? errorMessage,
    String? errorCode,
    bool clearError = false,
  }) {
    return ChatMessagesState(
      items: items ?? this.items,
      hasMoreOlder: hasMoreOlder ?? this.hasMoreOlder,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
    );
  }
}

final chatMessagesProvider =
    AsyncNotifierProvider.autoDispose<
      ChatMessagesController,
      ChatMessagesState
    >(ChatMessagesController.new);

class ChatMessagesController extends AsyncNotifier<ChatMessagesState> {
  static const _pageSize = 50;
  var _localSeq = 0;

  @override
  Future<ChatMessagesState> build() async {
    final page = await ref
        .watch(chatRepositoryProvider)
        .listMessages(limit: _pageSize);
    final value = page.match((failure) => throw failure, (v) => v);

    final realtime = ref.watch(chatRealtimeProvider);
    if (realtime != null) {
      realtime.start(_onRealtime);
      ref.onDispose(() {
        realtime.stop();
      });
    }

    return ChatMessagesState(items: value.items, hasMoreOlder: value.hasMore);
  }

  void _onRealtime(ChatRealtimeEvent event) {
    if (!ref.mounted) return;
    switch (event.type) {
      case ChatRealtimeEventType.upsert:
        applyRealtimeUpsert(event.message);
      case ChatRealtimeEventType.delete:
        _removeById(event.message.id);
    }
  }

  /// Merge INSERT/UPDATE dari Supabase Realtime ke list lokal.
  void applyRealtimeUpsert(ChatMessage message) {
    final current = state.value;
    if (current == null) return;

    final idx = current.items.indexWhere((m) => m.id == message.id);
    if (idx >= 0) {
      final next = [...current.items];
      next[idx] = message;
      state = AsyncData(current.copyWith(items: next));
      return;
    }

    final withoutPending = current.items.where((m) {
      if (!m.pending) return true;
      if (m.userId != message.userId) return true;
      if (m.kind != message.kind) return true;
      return switch (m.kind) {
        ChatMessageKind.text => m.body != message.body,
        ChatMessageKind.sticker => m.stickerId != message.stickerId,
        // VN: biarkan REST replace local-*; realtime bisa datang belakangan.
        ChatMessageKind.voiceNote => true,
      };
    }).toList();

    state = AsyncData(
      current.copyWith(items: [...withoutPending, message]),
    );
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    final page = await ref
        .read(chatRepositoryProvider)
        .listMessages(limit: _pageSize);
    if (!ref.mounted) return;
    page.match(
      (failure) {
        state = AsyncData(
          (state.value ?? const ChatMessagesState()).copyWith(
            errorMessage: failure.message,
            errorCode: failure.errorCode,
          ),
        );
      },
      (value) {
        state = AsyncData(
          ChatMessagesState(items: value.items, hasMoreOlder: value.hasMore),
        );
      },
    );
  }

  /// Ambil pesan lebih baru dari yang paling bawah (resume / soft poll).
  /// Return jumlah item baru yang ditambahkan.
  Future<int> fetchNewer() async {
    if (!ref.mounted) return 0;
    final current = state.value;
    if (current == null || current.items.isEmpty) {
      await refresh();
      return 0;
    }
    final newest = current.items.last;
    if (newest.id.startsWith('local-')) return 0;

    final page = await ref
        .read(chatRepositoryProvider)
        .listMessages(
          limit: _pageSize,
          afterCreatedAt: newest.createdAt,
          afterId: newest.id,
        );
    if (!ref.mounted) return 0;

    return page.match(
      (failure) {
        state = AsyncData(
          current.copyWith(
            errorMessage: failure.message,
            errorCode: failure.errorCode,
          ),
        );
        return 0;
      },
      (value) {
        if (value.items.isEmpty) return 0;
        final existing = {for (final m in current.items) m.id};
        final added = value.items
            .where((m) => !existing.contains(m.id))
            .toList();
        if (added.isEmpty) return 0;
        state = AsyncData(
          current.copyWith(items: [...current.items, ...added]),
        );
        return added.length;
      },
    );
  }

  Future<void> loadOlder() async {
    if (!ref.mounted) return;
    final current = state.value;
    if (current == null ||
        !current.hasMoreOlder ||
        current.isLoadingOlder ||
        current.items.isEmpty) {
      return;
    }
    final oldest = current.items.firstWhere(
      (m) => !m.id.startsWith('local-'),
      orElse: () => current.items.first,
    );
    if (oldest.id.startsWith('local-')) return;

    state = AsyncData(current.copyWith(isLoadingOlder: true));
    final page = await ref
        .read(chatRepositoryProvider)
        .listMessages(
          limit: _pageSize,
          beforeCreatedAt: oldest.createdAt,
          beforeId: oldest.id,
        );
    if (!ref.mounted) return;

    page.match(
      (failure) {
        state = AsyncData(
          current.copyWith(
            isLoadingOlder: false,
            errorMessage: failure.message,
            errorCode: failure.errorCode,
          ),
        );
      },
      (value) {
        final existing = {for (final m in current.items) m.id};
        final older = value.items
            .where((m) => !existing.contains(m.id))
            .toList();
        state = AsyncData(
          current.copyWith(
            items: [...older, ...current.items],
            hasMoreOlder: value.hasMore,
            isLoadingOlder: false,
          ),
        );
      },
    );
  }

  Future<ChatFailure?> sendText({
    required String body,
    String? replyToId,
    String? replySnippet,
    String? replyUsername,
  }) async {
    if (!ref.mounted) return null;
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;

    final auth = ref.read(authStatusProvider).value;
    final localId = _nextLocalId();
    final optimistic = ChatMessage(
      id: localId,
      channel: 'public',
      userId: auth?.userId ?? '',
      username: auth?.username,
      displayName: auth?.displayName,
      avatarUrl: auth?.avatarUrl,
      kind: ChatMessageKind.text,
      body: trimmed,
      replyToId: replyToId,
      replySnippet: replySnippet,
      replyUsername: replyUsername,
      createdAt: DateTime.now().toUtc().toIso8601String(),
      pending: true,
    );
    _appendOptimistic(optimistic);

    final result = await ref
        .read(chatRepositoryProvider)
        .sendText(body: trimmed, replyToId: replyToId);
    if (!ref.mounted) return null;

    return result.match(
      (failure) {
        _removeById(localId);
        return failure;
      },
      (message) {
        _replaceLocal(localId, message);
        return null;
      },
    );
  }

  Future<ChatFailure?> sendSticker({
    required String stickerId,
    String? replyToId,
    String? replySnippet,
    String? replyUsername,
  }) async {
    if (!ref.mounted) return null;
    final auth = ref.read(authStatusProvider).value;
    final localId = _nextLocalId();
    final optimistic = ChatMessage(
      id: localId,
      channel: 'public',
      userId: auth?.userId ?? '',
      username: auth?.username,
      displayName: auth?.displayName,
      avatarUrl: auth?.avatarUrl,
      kind: ChatMessageKind.sticker,
      stickerId: stickerId,
      replyToId: replyToId,
      replySnippet: replySnippet,
      replyUsername: replyUsername,
      createdAt: DateTime.now().toUtc().toIso8601String(),
      pending: true,
    );
    _appendOptimistic(optimistic);

    final result = await ref
        .read(chatRepositoryProvider)
        .sendSticker(stickerId: stickerId, replyToId: replyToId);
    if (!ref.mounted) return null;

    return result.match(
      (failure) {
        _removeById(localId);
        return failure;
      },
      (message) {
        _replaceLocal(localId, message);
        return null;
      },
    );
  }

  Future<ChatFailure?> sendVoice({
    required File audioFile,
    required int durationMs,
    String? replyToId,
    String? replySnippet,
    String? replyUsername,
  }) async {
    if (!ref.mounted) return null;
    final auth = ref.read(authStatusProvider).value;
    final localId = _nextLocalId();
    final optimistic = ChatMessage(
      id: localId,
      channel: 'public',
      userId: auth?.userId ?? '',
      username: auth?.username,
      displayName: auth?.displayName,
      avatarUrl: auth?.avatarUrl,
      kind: ChatMessageKind.voiceNote,
      durationMs: durationMs,
      replyToId: replyToId,
      replySnippet: replySnippet,
      replyUsername: replyUsername,
      createdAt: DateTime.now().toUtc().toIso8601String(),
      pending: true,
    );
    _appendOptimistic(optimistic);

    final result = await ref
        .read(chatRepositoryProvider)
        .sendVoice(
          audioFile: audioFile,
          durationMs: durationMs,
          replyToId: replyToId,
        );
    if (!ref.mounted) return null;

    try {
      if (await audioFile.exists()) await audioFile.delete();
    } catch (_) {}

    return result.match(
      (failure) {
        _removeById(localId);
        return failure;
      },
      (message) {
        _replaceLocal(localId, message);
        return null;
      },
    );
  }

  Future<ChatFailure?> deleteMessage(String id) async {
    if (!ref.mounted) return null;
    final result = await ref.read(chatRepositoryProvider).deleteMessage(id);
    if (!ref.mounted) return null;

    return result.match((failure) => failure, (message) {
      final current = state.value;
      if (current == null) return null;
      final next = current.items
          .map((m) => m.id == message.id ? message : m)
          .toList();
      state = AsyncData(current.copyWith(items: next));
      return null;
    });
  }

  void clearError() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(clearError: true));
  }

  String _nextLocalId() {
    _localSeq += 1;
    return 'local-$_localSeq-${DateTime.now().microsecondsSinceEpoch}';
  }

  void _appendOptimistic(ChatMessage message) {
    final current = state.value ?? const ChatMessagesState();
    state = AsyncData(current.copyWith(items: [...current.items, message]));
  }

  void _replaceLocal(String localId, ChatMessage message) {
    final current = state.value;
    if (current == null) return;
    final next = current.items
        .map((m) => m.id == localId ? message : m)
        .toList();
    // Dedup jika server id sudah ada.
    final seen = <String>{};
    final deduped = <ChatMessage>[];
    for (final m in next) {
      if (seen.contains(m.id)) continue;
      seen.add(m.id);
      deduped.add(m);
    }
    state = AsyncData(current.copyWith(items: deduped));
  }

  void _removeById(String id) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(items: current.items.where((m) => m.id != id).toList()),
    );
  }
}
