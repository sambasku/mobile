import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/cache/cache_providers.dart';
import '../../../../core/network/network_providers.dart';
import '../../data/datasources/card_images_remote_datasource.dart';
import '../../data/repositories/card_images_repository_impl.dart';
import '../../domain/entities/card_images.dart';
import '../../domain/repositories/card_images_repository.dart';

part 'card_images_providers.g.dart';

@riverpod
CardImagesRemoteDatasource cardImagesRemoteDatasource(Ref ref) =>
    CardImagesRemoteDatasource(ref.watch(dioProvider));

@riverpod
CardImagesRepository cardImagesRepository(Ref ref) => CardImagesRepositoryImpl(
      ref.watch(cardImagesRemoteDatasourceProvider),
      ref.watch(dioProvider),
      ref.watch(cachedJsonClientProvider),
    );

/// Config card dari CDN. Null = offline/JSON rusak → pakai asset bundled.
/// referenceStatic: fresh 24 jam + SWR, update terlihat ≤24 jam.
@riverpod
Future<CardImagesConfig?> cardImages(Ref ref) =>
    ref.watch(cardImagesRepositoryProvider).getCardImages();
