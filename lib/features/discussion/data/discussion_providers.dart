import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_providers.dart';
import '../../../core/network/network_providers.dart';
import 'discussion_image_upload_service.dart';
import 'discussion_repository.dart';

final discussionRepositoryProvider = Provider<DiscussionRepository>(
  (ref) => DiscussionRepository(
    ref.watch(dioProvider),
    cache: ref.watch(cachedJsonClientProvider),
  ),
);

final discussionImageUploadServiceProvider =
    Provider<DiscussionImageUploadService>(
      (ref) => DiscussionImageUploadService(
        ref.watch(discussionRepositoryProvider),
      ),
    );
