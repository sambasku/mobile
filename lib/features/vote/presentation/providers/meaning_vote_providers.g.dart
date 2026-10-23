// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meaning_vote_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Vote makna untuk kata yang sedang dibuka (satu slot, bukan per kata).
///
/// Id makna dikirim dari halaman detail (sudah ada di memory) - controller
/// tidak perlu fetch detail kata sendiri, jadi 1 kata = 2 request saja.

@ProviderFor(MeaningVotesController)
final meaningVotesControllerProvider = MeaningVotesControllerProvider._();

/// Vote makna untuk kata yang sedang dibuka (satu slot, bukan per kata).
///
/// Id makna dikirim dari halaman detail (sudah ada di memory) - controller
/// tidak perlu fetch detail kata sendiri, jadi 1 kata = 2 request saja.
final class MeaningVotesControllerProvider
    extends $NotifierProvider<MeaningVotesController, MeaningVotesState> {
  /// Vote makna untuk kata yang sedang dibuka (satu slot, bukan per kata).
  ///
  /// Id makna dikirim dari halaman detail (sudah ada di memory) - controller
  /// tidak perlu fetch detail kata sendiri, jadi 1 kata = 2 request saja.
  MeaningVotesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'meaningVotesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$meaningVotesControllerHash();

  @$internal
  @override
  MeaningVotesController create() => MeaningVotesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MeaningVotesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MeaningVotesState>(value),
    );
  }
}

String _$meaningVotesControllerHash() =>
    r'f8b7acc5de9498f55c56d8ab2ed45849fa7d78b0';

/// Vote makna untuk kata yang sedang dibuka (satu slot, bukan per kata).
///
/// Id makna dikirim dari halaman detail (sudah ada di memory) - controller
/// tidak perlu fetch detail kata sendiri, jadi 1 kata = 2 request saja.

abstract class _$MeaningVotesController extends $Notifier<MeaningVotesState> {
  MeaningVotesState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MeaningVotesState, MeaningVotesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MeaningVotesState, MeaningVotesState>,
              MeaningVotesState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
