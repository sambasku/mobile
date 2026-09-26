// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_deck_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Antrean deck nilai kata (login). keepAlive + watch auth.

@ProviderFor(VoteDeckController)
final voteDeckControllerProvider = VoteDeckControllerProvider._();

/// Antrean deck nilai kata (login). keepAlive + watch auth.
final class VoteDeckControllerProvider
    extends $AsyncNotifierProvider<VoteDeckController, VoteDeckState> {
  /// Antrean deck nilai kata (login). keepAlive + watch auth.
  VoteDeckControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voteDeckControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voteDeckControllerHash();

  @$internal
  @override
  VoteDeckController create() => VoteDeckController();
}

String _$voteDeckControllerHash() =>
    r'dfee62af23e8fb420040e510bda7245c4302d3b0';

/// Antrean deck nilai kata (login). keepAlive + watch auth.

abstract class _$VoteDeckController extends $AsyncNotifier<VoteDeckState> {
  FutureOr<VoteDeckState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<VoteDeckState>, VoteDeckState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<VoteDeckState>, VoteDeckState>,
              AsyncValue<VoteDeckState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Sample kartu untuk tamu (read-only) dari GET /words/latest.

@ProviderFor(voteDeckGuestSamples)
final voteDeckGuestSamplesProvider = VoteDeckGuestSamplesProvider._();

/// Sample kartu untuk tamu (read-only) dari GET /words/latest.

final class VoteDeckGuestSamplesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WordSummary>>,
          List<WordSummary>,
          FutureOr<List<WordSummary>>
        >
    with
        $FutureModifier<List<WordSummary>>,
        $FutureProvider<List<WordSummary>> {
  /// Sample kartu untuk tamu (read-only) dari GET /words/latest.
  VoteDeckGuestSamplesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voteDeckGuestSamplesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voteDeckGuestSamplesHash();

  @$internal
  @override
  $FutureProviderElement<List<WordSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WordSummary>> create(Ref ref) {
    return voteDeckGuestSamples(ref);
  }
}

String _$voteDeckGuestSamplesHash() =>
    r'd66697a5fb89f667cf2dfe622e4286fb1d2eb6f0';
