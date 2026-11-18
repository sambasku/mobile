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
      state = 0;
      return;
    }
    rt.startPresence(
      presenceKey: presenceKey,
      meta: {
        'name': name,
        if (userId != null && userId.isNotEmpty) 'user_id': userId,
      },
      onCount: (count) {
        if (!ref.mounted) return;
        state = count;
      },
    );
  }

  Future<void> leave() async {
    final rt = ref.read(chatRealtimeProvider);
    await rt?.stopPresence();
    if (!ref.mounted) return;
    state = 0;
  }
}
