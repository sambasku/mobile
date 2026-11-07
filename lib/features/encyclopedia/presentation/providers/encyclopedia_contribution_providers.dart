import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/encyclopedia_providers.dart';
import '../../domain/encyclopedia.entity.dart';

final myEncyclopediaContributionsProvider = FutureProvider.autoDispose<
  List<MyContributionItem>
>((ref) async {
  final repo = ref.watch(encyclopediaRepositoryProvider);
  final resp = await repo.getMyContributions({'limit': 50});
  return resp.data?.items ?? [];
});
