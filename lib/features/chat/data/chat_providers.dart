import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../domain/chat_models.dart';
import 'chat_realtime.dart';
import 'chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(ref.watch(dioProvider)),
);

/// Null jika env Supabase kosong / gagal buat client.
final chatRealtimeProvider = Provider<ChatRealtime?>((ref) {
  final rt = ChatRealtime.tryCreate();
  if (rt != null) {
    ref.onDispose(() {
      rt.dispose();
    });
  }
  return rt;
});

final chatCapabilitiesProvider = FutureProvider.autoDispose<ChatCapabilities?>((
  ref,
) async {
  final result = await ref.watch(chatRepositoryProvider).getCapabilities();
  return result.match((_) => null, (caps) => caps);
});

