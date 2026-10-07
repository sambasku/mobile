import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/repositories/review_search_miss_repository_impl.dart';
import '../../domain/entities/review_search_miss.dart';

final reviewSearchMissRepositoryProvider = Provider(
  (ref) => ReviewSearchMissRepositoryImpl(ref.watch(dioProvider)),
);

/// Panel verifikator (#88): miss belum terjawab, sort terbaru.
/// Termasuk yang belum tayang — panel ini justru gerbang tayangnya.
final reviewSearchMissProvider =
    FutureProvider.autoDispose<List<ReviewSearchMiss>>((ref) async {
  final result = await ref
      .watch(reviewSearchMissRepositoryProvider)
      .list(fulfilled: false, limit: 50);
  return result.match(
    (failure) => throw failure,
    (page) => page.items,
  );
});
