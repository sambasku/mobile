// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_votes_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Daftar riwayat vote. keepAlive + watch auth: login/logout memuat ulang
/// tanpa invalidate dari AuthStatusNotifier (circular di Riverpod 3).

@ProviderFor(MyVotesListController)
final myVotesListControllerProvider = MyVotesListControllerProvider._();

/// Daftar riwayat vote. keepAlive + watch auth: login/logout memuat ulang
/// tanpa invalidate dari AuthStatusNotifier (circular di Riverpod 3).
final class MyVotesListControllerProvider
    extends $AsyncNotifierProvider<MyVotesListController, MyVotesState> {
  /// Daftar riwayat vote. keepAlive + watch auth: login/logout memuat ulang
  /// tanpa invalidate dari AuthStatusNotifier (circular di Riverpod 3).
  MyVotesListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myVotesListControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myVotesListControllerHash();

  @$internal
  @override
  MyVotesListController create() => MyVotesListController();
}

String _$myVotesListControllerHash() =>
    r'f29e61b90b4d1f639c1c69faa754be04427d1a0b';

/// Daftar riwayat vote. keepAlive + watch auth: login/logout memuat ulang
/// tanpa invalidate dari AuthStatusNotifier (circular di Riverpod 3).

abstract class _$MyVotesListController extends $AsyncNotifier<MyVotesState> {
  FutureOr<MyVotesState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<MyVotesState>, MyVotesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MyVotesState>, MyVotesState>,
              AsyncValue<MyVotesState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
