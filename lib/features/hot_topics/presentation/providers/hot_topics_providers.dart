import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/hot_topics_repository.dart';
import '../../domain/hot_topics.dart';

final hotTopicsRepositoryProvider = Provider<HotTopicsRepository>((ref) {
  return HotTopicsRepository(ref.watch(dioProvider));
});

/// TTL soft 90 dtk: invalidate dari pull-to-refresh Home tetap paksa refresh.
final hotTopicsProvider = FutureProvider.autoDispose<HotTopicsBundle>((
  ref,
) async {
  final link = ref.keepAlive();
  // Timer (bukan Future.delayed) supaya bisa di-cancel saat provider dispose -
  // kalau tidak, flutter_test gagal dengan "Timer is still pending".
  final timer = Timer(const Duration(seconds: 90), link.close);
  ref.onDispose(timer.cancel);
  return ref.watch(hotTopicsRepositoryProvider).fetch();
});
