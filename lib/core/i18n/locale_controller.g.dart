// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Bahasa UI aktif. Persist di [LocalePrefs] (`sk_locale` +
/// `sk_locale_chosen`), seed [LocalePrefs.locale] dibaca sebelum runApp
/// supaya frame pertama tidak flash bahasa default.

@ProviderFor(LocaleController)
final localeControllerProvider = LocaleControllerProvider._();

/// Bahasa UI aktif. Persist di [LocalePrefs] (`sk_locale` +
/// `sk_locale_chosen`), seed [LocalePrefs.locale] dibaca sebelum runApp
/// supaya frame pertama tidak flash bahasa default.
final class LocaleControllerProvider
    extends $NotifierProvider<LocaleController, AppLocale> {
  /// Bahasa UI aktif. Persist di [LocalePrefs] (`sk_locale` +
  /// `sk_locale_chosen`), seed [LocalePrefs.locale] dibaca sebelum runApp
  /// supaya frame pertama tidak flash bahasa default.
  LocaleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeControllerHash();

  @$internal
  @override
  LocaleController create() => LocaleController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLocale value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLocale>(value),
    );
  }
}

String _$localeControllerHash() => r'4cfc7f7dbdd412e516a0a6b354ed01b1705b3a98';

/// Bahasa UI aktif. Persist di [LocalePrefs] (`sk_locale` +
/// `sk_locale_chosen`), seed [LocalePrefs.locale] dibaca sebelum runApp
/// supaya frame pertama tidak flash bahasa default.

abstract class _$LocaleController extends $Notifier<AppLocale> {
  AppLocale build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppLocale, AppLocale>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppLocale, AppLocale>,
              AppLocale,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
