import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/public_profile.dart';
import '../../domain/providers/user_profile_domain_providers.dart';
import '../models/public_activity_category_state.dart';

part 'user_profile_providers.g.dart';

/// Load profil publik; error object = [UserProfileFailure] (termasuk 404).
@riverpod
Future<PublicProfile> publicProfile(Ref ref, String username) async {
  final result = await ref.watch(getPublicProfileUseCaseProvider)(username);
  return result.match((failure) => throw failure, (profile) => profile);
}

/// Load aktivitas publik (mode merge - tanpa filter kind, max 20, tanpa cursor).
@riverpod
Future<List<PublicActivityItem>> publicActivity(Ref ref, String username) async {
  final result = await ref.watch(getPublicActivityUseCaseProvider)(username);
  return result.match((failure) => throw failure, (items) => items.items);
}

/// Provider family per kategori (kind: contribution|comment|verification|vote).
/// Pagination manual via parameter `cursor` - dipakai di bottom sheet.
@riverpod
Future<PublicActivityCategoryState> publicActivityByKind(
  Ref ref,
  String username,
  String kind, {
  String? cursor,
}) async {
  const limit = 20;
  final result = await ref.watch(getPublicActivityUseCaseProvider)(
    username,
    kind: kind,
    limit: limit,
    cursor: cursor,
  );
  return result.match(
    (failure) => throw failure,
    (page) => PublicActivityCategoryState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.nextCursor != null,
    ),
  );
}