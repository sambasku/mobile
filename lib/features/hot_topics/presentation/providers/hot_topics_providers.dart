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
  final timer = Future<void>.delayed(const Duration(seconds: 90));
  timer.whenComplete(link.close);
  ref.onDispose(() {});
  return ref.watch(hotTopicsRepositoryProvider).fetch();
});
