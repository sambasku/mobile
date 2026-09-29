// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bulk_submit_word_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BulkSubmitWordNotifier)
final bulkSubmitWordProvider = BulkSubmitWordNotifierProvider._();

final class BulkSubmitWordNotifierProvider
    extends $NotifierProvider<BulkSubmitWordNotifier, BulkSubmitWordState> {
  BulkSubmitWordNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bulkSubmitWordProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bulkSubmitWordNotifierHash();

  @$internal
  @override
  BulkSubmitWordNotifier create() => BulkSubmitWordNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BulkSubmitWordState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BulkSubmitWordState>(value),
    );
  }
}

String _$bulkSubmitWordNotifierHash() =>
    r'bfef2b38beef57fa6bb004569a61b91a590f1d70';

abstract class _$BulkSubmitWordNotifier extends $Notifier<BulkSubmitWordState> {
  BulkSubmitWordState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BulkSubmitWordState, BulkSubmitWordState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BulkSubmitWordState, BulkSubmitWordState>,
              BulkSubmitWordState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
