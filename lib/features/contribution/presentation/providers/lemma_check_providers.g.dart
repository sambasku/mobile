// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lemma_check_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Cek ketersediaan lemma lewat GET /words/lemma/{lemma} (issue #170).
/// Non-blocking: hasil hanya untuk label, tidak memblokir submit.

@ProviderFor(LemmaCheckNotifier)
final lemmaCheckProvider = LemmaCheckNotifierProvider._();

/// Cek ketersediaan lemma lewat GET /words/lemma/{lemma} (issue #170).
/// Non-blocking: hasil hanya untuk label, tidak memblokir submit.
final class LemmaCheckNotifierProvider
    extends $NotifierProvider<LemmaCheckNotifier, LemmaCheckState> {
  /// Cek ketersediaan lemma lewat GET /words/lemma/{lemma} (issue #170).
  /// Non-blocking: hasil hanya untuk label, tidak memblokir submit.
  LemmaCheckNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lemmaCheckProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lemmaCheckNotifierHash();

  @$internal
  @override
  LemmaCheckNotifier create() => LemmaCheckNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LemmaCheckState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LemmaCheckState>(value),
    );
  }
}

String _$lemmaCheckNotifierHash() =>
    r'72a370dcb8ce7ae2055327f3a21218d5661e48d3';

/// Cek ketersediaan lemma lewat GET /words/lemma/{lemma} (issue #170).
/// Non-blocking: hasil hanya untuk label, tidak memblokir submit.

abstract class _$LemmaCheckNotifier extends $Notifier<LemmaCheckState> {
  LemmaCheckState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LemmaCheckState, LemmaCheckState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LemmaCheckState, LemmaCheckState>,
              LemmaCheckState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
