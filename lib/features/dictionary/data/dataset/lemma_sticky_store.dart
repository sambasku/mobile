import 'lemma_dataset_constants.dart';

/// Sticky "pakai lokal dulu" setelah infra-fail API.
class LemmaStickyStore {
  DateTime? _until;

  bool get isActive {
    final until = _until;
    if (until == null) return false;
    if (DateTime.now().isAfter(until)) {
      _until = null;
      return false;
    }
    return true;
  }

  void activate([Duration duration = LemmaDatasetConstants.stickyDuration]) {
    _until = DateTime.now().add(duration);
  }

  void clear() {
    _until = null;
  }
}
