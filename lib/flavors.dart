// Flavor aplikasi
enum Flavor { staging, production }

class F {
  F._();

  /// Bukan `late final`: tes flavor (staging lalu production) harus
  /// bisa ganti nilai di isolate yang sama. `main()` tetap assign sekali.
  static late Flavor appFlavor;

  static String get name => appFlavor.name;

  static bool get isStaging => appFlavor == Flavor.staging;

  /// Sembunyikan ribbon versi dan floating devtool, flavor tetap staging.
  /// `flutter run --flavor staging --dart-define=SCREENSHOT_MODE=true`
  static const hideDevChrome = bool.fromEnvironment('SCREENSHOT_MODE');

  /// Label "BETA" di samping wordmark header. Matikan saat rilis stabil.
  static const isBeta = true;

  static String get title => isStaging ? 'SambasKu' : 'SambasKu';

  /// Path aset logo in-app + sumber ikon launcher (pola jnn_mobile).
  static String get logoAsset =>
      isStaging ? 'assets/icons/logo.staging.png' : 'assets/icons/logo.png';
}
