import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/community_api.dart';
import '../../domain/community_org.dart';

part 'community_providers.g.dart';

@riverpod
CommunityApi communityApi(Ref ref) => CommunityApi(ref.watch(dioProvider));

@riverpod
Future<CommunityOrgPage> communityOrgList(
  Ref ref,
  String categoryId,
  String query,
) {
  return ref
      .watch(communityApiProvider)
      .list(
        category: categoryId == CommunityCategory.semua.id ? null : categoryId,
        q: query,
      );
}

@riverpod
Future<CommunityOrg?> communityOrgDetail(Ref ref, String slug) {
  return ref.watch(communityApiProvider).detail(slug);
}

@riverpod
Future<List<CommunityOrg>> communityFeatured(Ref ref) {
  return ref.watch(communityApiProvider).featured();
}

@Riverpod(keepAlive: true)
class CommunityMineController extends _$CommunityMineController {
  @override
  Future<List<CommunityProposal>> build() async {
    final auth = ref.watch(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) return const [];
    return ref.watch(communityApiProvider).mine();
  }

  Future<CommunityProposal> submit({
    required String name,
    required String description,
    String? logoUrl,
  }) async {
    final proposal = await ref
        .read(communityApiProvider)
        .submit(name: name, description: description, logoUrl: logoUrl);
    ref.invalidateSelf();
    return proposal;
  }

  Future<void> cancel(String id) async {
    await ref.read(communityApiProvider).cancel(id);
    ref.invalidateSelf();
  }
}

@riverpod
Future<String> uploadCommunityLogo(Ref ref, File file) {
  return ref.watch(communityApiProvider).uploadLogo(file);
}
