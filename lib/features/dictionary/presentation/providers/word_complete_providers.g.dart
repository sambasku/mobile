// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_complete_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// State pemilih kata untuk entri "Lengkapi kata" di Area Verifikator.
///
/// Auto-dispose: state ikut hilang saat halaman ditutup, jadi kembali ke
/// hub tidak menyisakan query/hasil yang basi.

@ProviderFor(WordCompleteNotifier)
final wordCompleteProvider = WordCompleteNotifierProvider._();

/// State pemilih kata untuk entri "Lengkapi kata" di Area Verifikator.
///
/// Auto-dispose: state ikut hilang saat halaman ditutup, jadi kembali ke
/// hub tidak menyisakan query/hasil yang basi.
final class WordCompleteNotifierProvider
    extends $NotifierProvider<WordCompleteNotifier, WordCompleteState> {
  /// State pemilih kata untuk entri "Lengkapi kata" di Area Verifikator.
  ///
  /// Auto-dispose: state ikut hilang saat halaman ditutup, jadi kembali ke
  /// hub tidak menyisakan query/hasil yang basi.
  WordCompleteNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wordCompleteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wordCompleteNotifierHash();

  @$internal
  @override
  WordCompleteNotifier create() => WordCompleteNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WordCompleteState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WordCompleteState>(value),
    );
  }
}

String _$wordCompleteNotifierHash() =>
    r'753026bee4b03a1cc8a81b1daddaaac5242bae8d';

/// State pemilih kata untuk entri "Lengkapi kata" di Area Verifikator.
///
/// Auto-dispose: state ikut hilang saat halaman ditutup, jadi kembali ke
/// hub tidak menyisakan query/hasil yang basi.

abstract class _$WordCompleteNotifier extends $Notifier<WordCompleteState> {
  WordCompleteState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WordCompleteState, WordCompleteState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WordCompleteState, WordCompleteState>,
              WordCompleteState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
