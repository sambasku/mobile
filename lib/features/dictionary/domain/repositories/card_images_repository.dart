import '../entities/card_images.dart';

/// Akses config card dinamis dari CDN (repo `data` via jsDelivr).
///
/// Return null berarti config tidak tersedia (offline, JSON rusak,
/// fetch gagal) — caller pakai asset bundled.
abstract interface class CardImagesRepository {
  /// Config card siap render. Soft-fail: error apa pun → null.
  Future<CardImagesConfig?> getCardImages({bool forceRefresh = false});
}
