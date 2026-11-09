import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/network/network_providers.dart';
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
final latestJinyeByUsernameProvider =
    FutureProvider.autoDispose.family<JinyeItem?, String>((ref, username) async {
  final repo = ref.watch(jinyeRepositoryProvider);
  final page = await repo.listPublished(limit: 1, username: username);
  return page.items.isEmpty ? null : page.items.first;
});

final jinyeDetailProvider =
    FutureProvider.autoDispose.family<JinyeItem, String>((ref, id) async {
  return ref.watch(jinyeRepositoryProvider).getDetail(id);
});

final jinyeCommentsProvider =
    FutureProvider.autoDispose.family<List<JinyeComment>, String>((ref, id) async {
  return ref.watch(jinyeRepositoryProvider).listComments(id);
});
