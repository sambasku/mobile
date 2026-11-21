// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'periksa_kata_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Feed Periksa Kata - terpisah dari [VoteDeckController].

@ProviderFor(PeriksaKataFeedController)
final periksaKataFeedControllerProvider = PeriksaKataFeedControllerProvider._();

/// Feed Periksa Kata - terpisah dari [VoteDeckController].
final class PeriksaKataFeedControllerProvider
    extends
        $AsyncNotifierProvider<
          PeriksaKataFeedController,
          PeriksaKataFeedState
        > {
  /// Feed Periksa Kata - terpisah dari [VoteDeckController].
  PeriksaKataFeedControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'periksaKataFeedControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$periksaKataFeedControllerHash();

  @$internal
  @override
  PeriksaKataFeedController create() => PeriksaKataFeedController();
}

String _$periksaKataFeedControllerHash() =>
    r'353f6fa3bfda44f6f99f49a39bb151f322e770f1';

/// Feed Periksa Kata - terpisah dari [VoteDeckController].

abstract class _$PeriksaKataFeedController
    extends $AsyncNotifier<PeriksaKataFeedState> {
  FutureOr<PeriksaKataFeedState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<PeriksaKataFeedState>, PeriksaKataFeedState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PeriksaKataFeedState>,
                PeriksaKataFeedState
              >,
              AsyncValue<PeriksaKataFeedState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(PeriksaKataHistoryController)
final periksaKataHistoryControllerProvider =
    PeriksaKataHistoryControllerProvider._();

final class PeriksaKataHistoryControllerProvider
    extends
        $AsyncNotifierProvider<
          PeriksaKataHistoryController,
          PeriksaKataHistoryState
        > {
  PeriksaKataHistoryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'periksaKataHistoryControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$periksaKataHistoryControllerHash();

  @$internal
  @override
  PeriksaKataHistoryController create() => PeriksaKataHistoryController();
}

String _$periksaKataHistoryControllerHash() =>
    r'c23231b8920dd83ed52810621a7ee0b7399656c3';

abstract class _$PeriksaKataHistoryController
    extends $AsyncNotifier<PeriksaKataHistoryState> {
  FutureOr<PeriksaKataHistoryState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PeriksaKataHistoryState>,
              PeriksaKataHistoryState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PeriksaKataHistoryState>,
                PeriksaKataHistoryState
              >,
              AsyncValue<PeriksaKataHistoryState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
