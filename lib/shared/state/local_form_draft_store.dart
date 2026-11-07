/// Draft form di memori proses. Satu salinan per form, tanpa timer dan
/// tanpa tulis disk. Back tidak menghapusnya; submit yang menghapus.
///
/// App yang di-kill kehilangan draft ini.
class LocalFormDraftStore {
  LocalFormDraftStore._();

  static final instance = LocalFormDraftStore._();

  final Map<String, Object> _box = {};

  T? peek<T extends Object>(String key) {
    final value = _box[key];
    return value is T ? value : null;
  }

  void put(String key, Object value) => _box[key] = value;

  void remove(String key) => _box.remove(key);

  void clearAll() => _box.clear();
}

/// Snapshot sekali saat halaman ditutup. Mengetik tidak menyentuh store.
mixin LocalDraftKeeper<T extends Object> {
  String get draftKey;

  T captureDraft();

  void restoreDraft(T draft);

  bool get draftHasContent;

  /// Sidik jari isi. Dibaca saat buka (baseline) dan sekali saat tutup.
  String get draftToken;

  bool _draftCommitted = false;
  bool _draftRestored = false;
  String? _baselineToken;

  void loadLocalDraft() {
    final existing = LocalFormDraftStore.instance.peek<T>(draftKey);
    if (existing == null) {
      _baselineToken = draftToken;
      return;
    }
    restoreDraft(existing);
    _draftRestored = true;
  }

  /// Setelah prefill server. Edit yang belum dilakukan user tidak disimpan.
  void sealDraftBaseline() {
    if (_draftRestored || _draftCommitted) return;
    _baselineToken = draftToken;
  }

  void commitLocalDraft() {
    _draftCommitted = true;
    LocalFormDraftStore.instance.remove(draftKey);
  }

  void flushLocalDraft() {
    if (_draftCommitted ||
        (!_draftRestored && draftToken == _baselineToken) ||
        !draftHasContent) {
      LocalFormDraftStore.instance.remove(draftKey);
      return;
    }
    LocalFormDraftStore.instance.put(draftKey, captureDraft());
  }
}
