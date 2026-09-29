// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_contributions_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Daftar kontribusi milik user (cursor). Guest = state kosong.
/// keepAlive: cache saat keluar ke detail lalu kembali.

@ProviderFor(MyContributionsListController)
final myContributionsListControllerProvider =
    MyContributionsListControllerProvider._();

/// Daftar kontribusi milik user (cursor). Guest = state kosong.
/// keepAlive: cache saat keluar ke detail lalu kembali.
final class MyContributionsListControllerProvider
    extends
        $AsyncNotifierProvider<
          MyContributionsListController,
          MyContributionsState
        > {
  /// Daftar kontribusi milik user (cursor). Guest = state kosong.
  /// keepAlive: cache saat keluar ke detail lalu kembali.
  MyContributionsListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myContributionsListControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myContributionsListControllerHash();

  @$internal
  @override
  MyContributionsListController create() => MyContributionsListController();
}

String _$myContributionsListControllerHash() =>
    r'7fc55c37c0344f90b364cd706a6f9f4ee3a10622';

/// Daftar kontribusi milik user (cursor). Guest = state kosong.
/// keepAlive: cache saat keluar ke detail lalu kembali.

abstract class _$MyContributionsListController
    extends $AsyncNotifier<MyContributionsState> {
  FutureOr<MyContributionsState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<MyContributionsState>, MyContributionsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<MyContributionsState>,
                MyContributionsState
              >,
              AsyncValue<MyContributionsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(myContributionDetail)
final myContributionDetailProvider = MyContributionDetailFamily._();

final class MyContributionDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<MySubmission>,
          MySubmission,
          FutureOr<MySubmission>
        >
    with $FutureModifier<MySubmission>, $FutureProvider<MySubmission> {
  MyContributionDetailProvider._({
    required MyContributionDetailFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'myContributionDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myContributionDetailHash();

  @override
  String toString() {
    return r'myContributionDetailProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<MySubmission> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MySubmission> create(Ref ref) {
    final argument = this.argument as (String, String);
    return myContributionDetail(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is MyContributionDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myContributionDetailHash() =>
    r'1930e513afbda36c36ae13fbb975be689a495dbf';

final class MyContributionDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MySubmission>, (String, String)> {
  MyContributionDetailFamily._()
    : super(
        retry: null,
        name: r'myContributionDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MyContributionDetailProvider call(String kind, String id) =>
      MyContributionDetailProvider._(argument: (kind, id), from: this);

  @override
  String toString() => r'myContributionDetailProvider';
}
