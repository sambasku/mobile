// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mention_suggest_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Autocomplete mention @username: debounce 300ms, hanya query >= 2 char.
/// Gagal fetch = diam (suggestion disembunyikan), bukan error block.
/// Race condition: cancel request sebelumnya via AbortController.

@ProviderFor(MentionSuggestController)
final mentionSuggestControllerProvider = MentionSuggestControllerProvider._();

/// Autocomplete mention @username: debounce 300ms, hanya query >= 2 char.
/// Gagal fetch = diam (suggestion disembunyikan), bukan error block.
/// Race condition: cancel request sebelumnya via AbortController.
final class MentionSuggestControllerProvider
    extends $NotifierProvider<MentionSuggestController, MentionSuggestState> {
  /// Autocomplete mention @username: debounce 300ms, hanya query >= 2 char.
  /// Gagal fetch = diam (suggestion disembunyikan), bukan error block.
  /// Race condition: cancel request sebelumnya via AbortController.
  MentionSuggestControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mentionSuggestControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mentionSuggestControllerHash();

  @$internal
  @override
  MentionSuggestController create() => MentionSuggestController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MentionSuggestState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MentionSuggestState>(value),
    );
  }
}

String _$mentionSuggestControllerHash() =>
    r'04c7a5804eea780b34b6bf46221d9ac019df4a0a';

/// Autocomplete mention @username: debounce 300ms, hanya query >= 2 char.
/// Gagal fetch = diam (suggestion disembunyikan), bukan error block.
/// Race condition: cancel request sebelumnya via AbortController.

abstract class _$MentionSuggestController
    extends $Notifier<MentionSuggestState> {
  MentionSuggestState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MentionSuggestState, MentionSuggestState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MentionSuggestState, MentionSuggestState>,
              MentionSuggestState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
