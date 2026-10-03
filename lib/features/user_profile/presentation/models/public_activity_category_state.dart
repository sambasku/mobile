import '../../domain/entities/public_profile.dart';

class PublicActivityCategoryState {
  const PublicActivityCategoryState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  final List<PublicActivityItem> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
}