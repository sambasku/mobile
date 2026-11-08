import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/datasources/about_api_datasource.dart';

part 'about_api_providers.g.dart';

@riverpod
AboutApiDatasource aboutApiDatasource(Ref ref) =>
    AboutApiDatasource(ref.watch(dioProvider));

@riverpod
Future<List<AboutTeamMember>?> aboutTeam(Ref ref) async {
  try {
    return await ref.watch(aboutApiDatasourceProvider).fetchTeam();
  } catch (_) {
    return null;
  }
}

@riverpod
Future<List<AboutSponsorship>?> aboutSponsorships(Ref ref) async {
  try {
    return await ref.watch(aboutApiDatasourceProvider).fetchSponsorships();
  } catch (_) {
    return null;
  }
}

@riverpod
Future<List<AboutVerifier>?> aboutVerifiers(Ref ref) async {
  try {
    return await ref.watch(aboutApiDatasourceProvider).fetchVerifiers();
  } catch (_) {
    return null;
  }
}

class AboutContributorsState {
  const AboutContributorsState({
    required this.items,
    required this.total,
    this.nextCursor,
    this.hasMore = false,
    this.loadingMore = false,
  });

  final List<AboutContributorName> items;
  final int total;
  final String? nextCursor;
  final bool hasMore;
  final bool loadingMore;

  AboutContributorsState copyWith({
    List<AboutContributorName>? items,
    int? total,
    String? nextCursor,
    bool? hasMore,
    bool? loadingMore,
    bool clearCursor = false,
  }) {
    return AboutContributorsState(
      items: items ?? this.items,
      total: total ?? this.total,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

@riverpod
class AboutContributors extends _$AboutContributors {
  @override
  Future<AboutContributorsState?> build() async {
    try {
      final page = await ref
          .watch(aboutApiDatasourceProvider)
          .fetchContributors();
      if (!ref.mounted) return null;
      return AboutContributorsState(
        items: page.items,
        total: page.total,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;
    if (current.nextCursor == null) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final page = await ref
          .read(aboutApiDatasourceProvider)
          .fetchContributors(cursor: current.nextCursor);
      if (!ref.mounted) return;
      final seen = {for (final i in current.items) i.username};
      final fresh = page.items.where((i) => seen.add(i.username)).toList();
      state = AsyncData(
        AboutContributorsState(
          items: [...current.items, ...fresh],
          total: page.total,
          nextCursor: page.nextCursor,
          hasMore: page.hasMore && fresh.isNotEmpty,
          loadingMore: false,
        ),
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = AsyncData(current.copyWith(loadingMore: false));
    }
  }
}
