// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_comments_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Filter chip. null = Semua. Ganti nilai memuat ulang daftar dari awal.

@ProviderFor(MyCommentsStatusFilter)
final myCommentsStatusFilterProvider = MyCommentsStatusFilterProvider._();

/// Filter chip. null = Semua. Ganti nilai memuat ulang daftar dari awal.
final class MyCommentsStatusFilterProvider
    extends $NotifierProvider<MyCommentsStatusFilter, String?> {
  /// Filter chip. null = Semua. Ganti nilai memuat ulang daftar dari awal.
  MyCommentsStatusFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myCommentsStatusFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myCommentsStatusFilterHash();

  @$internal
  @override
  MyCommentsStatusFilter create() => MyCommentsStatusFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$myCommentsStatusFilterHash() =>
    r'3c38e9368092e401acba423b289583402456f337';

/// Filter chip. null = Semua. Ganti nilai memuat ulang daftar dari awal.

abstract class _$MyCommentsStatusFilter extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(MyCommentsListController)
final myCommentsListControllerProvider = MyCommentsListControllerProvider._();

final class MyCommentsListControllerProvider
    extends $AsyncNotifierProvider<MyCommentsListController, MyCommentsState> {
  MyCommentsListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myCommentsListControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myCommentsListControllerHash();

  @$internal
  @override
  MyCommentsListController create() => MyCommentsListController();
}

String _$myCommentsListControllerHash() =>
    r'3ce76bb97eadc4b53e51f3a6911e4995b3ba6f62';

abstract class _$MyCommentsListController
    extends $AsyncNotifier<MyCommentsState> {
  FutureOr<MyCommentsState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<MyCommentsState>, MyCommentsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MyCommentsState>, MyCommentsState>,
              AsyncValue<MyCommentsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
