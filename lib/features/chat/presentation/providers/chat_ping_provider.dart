import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/chat_providers.dart';
import '../../data/chat_realtime.dart';
import '../../domain/chat_models.dart';
import '../chat_ping_sfx.dart';
import 'chat_messages_provider.dart';

class ChatPingUiState {
  const ChatPingUiState({
    this.availableAt,
    this.cooldownSeconds = 300,
    this.remaining = Duration.zero,
    this.sending = false,
    this.errorMessage,
    this.errorCode,
  });

  final String? availableAt;
  final int cooldownSeconds;
  final Duration remaining;
  final bool sending;
  final String? errorMessage;
  final String? errorCode;

  bool get isReady => remaining <= Duration.zero && !sending;

  ChatPingUiState copyWith({
    String? availableAt,
    int? cooldownSeconds,
    Duration? remaining,
    bool? sending,
    String? errorMessage,
    String? errorCode,
    bool clearError = false,
    bool clearAvailableAt = false,
  }) {
    return ChatPingUiState(
      availableAt: clearAvailableAt ? null : (availableAt ?? this.availableAt),
      cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
      remaining: remaining ?? this.remaining,
      sending: sending ?? this.sending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
    );
  }
}

final chatPingProvider =
    NotifierProvider<ChatPingController, ChatPingUiState>(ChatPingController.new);

/// Keep-alive: dengar ping realtime di seluruh app (bel).
final chatPingBellProvider = Provider<void>((ref) {
  final rt = ref.watch(chatRealtimeProvider);
  if (rt == null) return;

  void onEvent(ChatRealtimeEvent event) {
    if (event.type != ChatRealtimeEventType.upsert) return;
    if (!isChatPingMessage(event.message)) return;
    final auth = ref.read(authStatusProvider).asData?.value;
    final myId = auth?.userId;
    // Bel untuk orang lain; pengirim sudah dapat feedback kirim.
    if (myId != null && myId == event.message.userId) return;
    unawaited(ChatPingSfx.play());
    ref.read(chatPingProvider.notifier).applyRemotePing(event.message);
  }

  rt.addMessageListener(onEvent);
  ref.onDispose(() {
    rt.removeMessageListener(onEvent);
  });
});

class ChatPingController extends Notifier<ChatPingUiState> {
  Timer? _ticker;

  @override
  ChatPingUiState build() {
    ref.onDispose(() {
      _ticker?.cancel();
    });
    Future.microtask(refresh);
    return const ChatPingUiState();
  }

  Future<void> refresh() async {
    final result = await ref.read(chatRepositoryProvider).getPingStatus();
    result.match((failure) {
      // Senyap - tombol tetap siap; server yang final.
    }, (status) {
      _applyStatus(status);
    });
  }

  void applyRemotePing(ChatMessage message) {
    final created = DateTime.tryParse(message.createdAt)?.toUtc();
    if (created == null) return;
    final available = created.add(const Duration(seconds: 300));
    _applyStatus(
      ChatPingStatus(
        availableAt: available.toIso8601String(),
        cooldownSeconds: 300,
        lastPingAt: created.toIso8601String(),
      ),
    );
  }

  void _applyStatus(ChatPingStatus status) {
    state = state.copyWith(
      availableAt: status.availableAt,
      cooldownSeconds: status.cooldownSeconds,
      remaining: status.remaining,
      clearAvailableAt: status.availableAt == null,
      clearError: true,
    );
    _restartTicker();
  }

  void _restartTicker() {
    _ticker?.cancel();
    if (state.availableAt == null || state.remaining <= Duration.zero) {
      return;
    }
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      // hitung ulang dari availableAt
      final at = state.availableAt == null
          ? null
          : DateTime.tryParse(state.availableAt!);
      if (at == null) {
        _ticker?.cancel();
        state = state.copyWith(remaining: Duration.zero, clearAvailableAt: true);
        return;
      }
      final diff = at.toUtc().difference(DateTime.now().toUtc());
      if (diff.isNegative || diff == Duration.zero) {
        _ticker?.cancel();
        state = state.copyWith(remaining: Duration.zero, clearAvailableAt: true);
        return;
      }
      state = state.copyWith(remaining: diff);
    });
  }

  Future<bool> send() async {
    if (!state.isReady) return false;
    state = state.copyWith(sending: true, clearError: true);
    final result = await ref.read(chatRepositoryProvider).sendPing();
    return result.match((failure) {
      state = state.copyWith(
        sending: false,
        errorMessage: failure.message,
        errorCode: failure.errorCode,
      );
      return false;
    }, (ok) {
      _applyStatus(ok.status);
      state = state.copyWith(sending: false);
      // Append ke timeline bila chat page hidup.
      final msgs = ref.read(chatMessagesProvider);
      if (msgs.hasValue) {
        ref.read(chatMessagesProvider.notifier).applyRealtimeUpsert(ok.message);
      }
      return true;
    });
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
