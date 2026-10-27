/// Kill switch / feature flag compile-time (dart-define).
///
/// Contoh aktifkan multi-bahasa setelah ARB `id_SBS` siap review penutur:
/// `flutter run --dart-define=MULTI_LANGUAGE_ENABLED=true`
class FeatureFlags {
  FeatureFlags._();

  /// Picker bahasa (onboarding + settings) + locale non-`id`.
  /// Default **off**: `id_SBS` belum siap; app tetap Bahasa Indonesia.
  static const multiLanguageEnabled = bool.fromEnvironment(
    'MULTI_LANGUAGE_ENABLED',
    defaultValue: false,
  );
}
