import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../activity/data/activity_feed_repository.dart';
import '../../activity/presentation/providers/activity_feed_providers.dart';
import '../../user_profile/presentation/providers/user_profile_providers.dart';
import '../domain/jinye_models.dart';
import 'jinye_image_upload_service.dart';
import 'jinye_repository.dart';

final jinyeRepositoryProvider = Provider<JinyeRepository>(
  (ref) => JinyeRepository(ref.watch(dioProvider)),
);

final jinyeImageUploadServiceProvider = Provider<JinyeImageUploadService>(
  (ref) => JinyeImageUploadService(ref.watch(jinyeRepositoryProvider)),
);

/// Jinye published terbaru milik [username] (null = belum ada / gagal).
/// Key family selalu lowercase - samakan dengan route profil publik.
final latestJinyeByUsernameProvider =
    FutureProvider.autoDispose.family<JinyeItem?, String>((ref, username) async {
  final handle = username.trim().toLowerCase();
  if (handle.isEmpty) return null;
  final repo = ref.watch(jinyeRepositoryProvider);
  final page = await repo.listPublished(limit: 1, username: handle);
  return page.items.isEmpty ? null : page.items.first;
});

/// Setelah create/quote/repost/arsip: bubble + timeline profil + feed beranda.
void invalidateJinyeProfileSurfaces(WidgetRef ref, String? username) {
  final u = username?.trim().toLowerCase();
  if (u == null || u.isEmpty) return;
  ref.invalidate(latestJinyeByUsernameProvider(u));
  ref.invalidate(publicActivityProvider(u));
  ref.invalidate(publicActivityByKindProvider(u, 'jinye'));
  ref.invalidate(activityFeedProvider(FeedCategory.all));
}

final jinyeDetailProvider =
    FutureProvider.autoDispose.family<JinyeItem, String>((ref, id) async {
  return ref.watch(jinyeRepositoryProvider).getDetail(id);
});

final jinyeCommentsProvider =
    FutureProvider.autoDispose.family<List<JinyeComment>, String>((ref, id) async {
  return ref.watch(jinyeRepositoryProvider).listComments(id);
});

final jinyeTranslationsProvider =
    FutureProvider.autoDispose.family<List<JinyeTranslation>, String>((
  ref,
  id,
) async {
  return ref.watch(jinyeRepositoryProvider).listTranslations(id);
});

/// Antrian usulan terjemahan Jinye (status: pending|accepted|rejected).
final jinyeTranslationQueueProvider = FutureProvider.autoDispose
    .family<List<JinyeTranslation>, String>((ref, status) async {
  return ref.watch(jinyeRepositoryProvider).listTranslationQueue(
        status: status,
      );
});

/// Jinye published yang menaut [wordId] (section detail lemma).
final jinyeByWordProvider =
    FutureProvider.autoDispose.family<List<JinyeItem>, String>((
  ref,
  wordId,
) async {
  final page = await ref.watch(jinyeRepositoryProvider).listPublished(
        limit: 5,
        wordId: wordId,
      );
  return page.items;
});
