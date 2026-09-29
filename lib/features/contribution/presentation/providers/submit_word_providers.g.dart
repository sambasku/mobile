// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_word_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SubmitWordNotifier)
final submitWordProvider = SubmitWordNotifierProvider._();

final class SubmitWordNotifierProvider
    extends $NotifierProvider<SubmitWordNotifier, SubmitWordState> {
  SubmitWordNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'submitWordProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$submitWordNotifierHash();

  @$internal
  @override
  SubmitWordNotifier create() => SubmitWordNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SubmitWordState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SubmitWordState>(value),
    );
  }
}

String _$submitWordNotifierHash() =>
    r'062903c65bc950d3d79e3b044311d47010f1ef3e';

abstract class _$SubmitWordNotifier extends $Notifier<SubmitWordState> {
  SubmitWordState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SubmitWordState, SubmitWordState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SubmitWordState, SubmitWordState>,
              SubmitWordState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
