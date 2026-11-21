import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/chat_providers.dart';

/// Jumlah klien yang sedang buka layar Chat (Supabase Presence).
final chatPresenceCountProvider =
    NotifierProvider<ChatPresenceController, int>(ChatPresenceController.new);

class ChatPresenceController extends Notifier<int> {
  @override
  int build() => 0;

  void enter({
    required String presenceKey,
    required String name,
    String? userId,
  }) {
    final rt = ref.read(chatRealtimeProvider);
    if (rt == null) {
      _setCount(0);
      return;
    }
    rt.startPresence(
      presenceKey: presenceKey,
      meta: {
        'name': name,
        if (userId != null && userId.isNotEmpty) 'user_id': userId,
      },
      onCount: _setCount,
    );
  }

  Future<void> leave() async {
    final rt = ref.read(chatRealtimeProvider);
    await rt?.stopPresence();
    if (!ref.mounted) return;
    _setCount(0);
  }

  void _setCount(int count) {
    if (!ref.mounted) return;
    void apply() {
      if (!ref.mounted) return;
      state = count;
    }

    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      apply();
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) => apply());
    }
  }
}
