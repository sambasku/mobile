// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usaha_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(usahaRemoteDatasource)
final usahaRemoteDatasourceProvider = UsahaRemoteDatasourceProvider._();

final class UsahaRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          UsahaRemoteDatasource,
          UsahaRemoteDatasource,
          UsahaRemoteDatasource
        >
    with $Provider<UsahaRemoteDatasource> {
  UsahaRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usahaRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usahaRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<UsahaRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UsahaRemoteDatasource create(Ref ref) {
    return usahaRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UsahaRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UsahaRemoteDatasource>(value),
    );
  }
}

String _$usahaRemoteDatasourceHash() =>
    r'252eb728bf51963b5d5aef057becf05ea52e4ee7';

@ProviderFor(usahaRepository)
final usahaRepositoryProvider = UsahaRepositoryProvider._();

final class UsahaRepositoryProvider
    extends
        $FunctionalProvider<
          UsahaRepositoryImpl,
          UsahaRepositoryImpl,
          UsahaRepositoryImpl
        >
    with $Provider<UsahaRepositoryImpl> {
  UsahaRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usahaRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usahaRepositoryHash();

  @$internal
  @override
  $ProviderElement<UsahaRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UsahaRepositoryImpl create(Ref ref) {
    return usahaRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UsahaRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UsahaRepositoryImpl>(value),
    );
  }
}

String _$usahaRepositoryHash() => r'59401c871264452d0debcdee856335f0557366c6';

@ProviderFor(usahaContributionApi)
final usahaContributionApiProvider = UsahaContributionApiProvider._();

final class UsahaContributionApiProvider
    extends
        $FunctionalProvider<
          UsahaContributionApi,
          UsahaContributionApi,
          UsahaContributionApi
        >
    with $Provider<UsahaContributionApi> {
  UsahaContributionApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usahaContributionApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usahaContributionApiHash();

  @$internal
  @override
  $ProviderElement<UsahaContributionApi> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UsahaContributionApi create(Ref ref) {
    return usahaContributionApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UsahaContributionApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UsahaContributionApi>(value),
    );
  }
}

String _$usahaContributionApiHash() =>
    r'c5e5bf2ba9e0cb7744b0bda698ec19234dc310b6';

/// Detail usaha by slug. Null = 404 atau dibatasi (restricted).

@ProviderFor(usahaBySlug)
final usahaBySlugProvider = UsahaBySlugFamily._();

/// Detail usaha by slug. Null = 404 atau dibatasi (restricted).

final class UsahaBySlugProvider
    extends $FunctionalProvider<AsyncValue<Usaha?>, Usaha?, FutureOr<Usaha?>>
    with $FutureModifier<Usaha?>, $FutureProvider<Usaha?> {
  /// Detail usaha by slug. Null = 404 atau dibatasi (restricted).
  UsahaBySlugProvider._({
    required UsahaBySlugFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'usahaBySlugProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$usahaBySlugHash();

  @override
  String toString() {
    return r'usahaBySlugProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Usaha?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Usaha?> create(Ref ref) {
    final argument = this.argument as String;
    return usahaBySlug(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UsahaBySlugProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$usahaBySlugHash() => r'a9f515531d1b0d07a3d4d7cbe168fd0ede9e11b1';

/// Detail usaha by slug. Null = 404 atau dibatasi (restricted).

final class UsahaBySlugFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Usaha?>, String> {
  UsahaBySlugFamily._()
    : super(
        retry: null,
        name: r'usahaBySlugProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Detail usaha by slug. Null = 404 atau dibatasi (restricted).

  UsahaBySlugProvider call(String slug) =>
      UsahaBySlugProvider._(argument: slug, from: this);

  @override
  String toString() => r'usahaBySlugProvider';
}

/// Katalog kategori usaha (published).

@ProviderFor(usahaCategories)
final usahaCategoriesProvider = UsahaCategoriesProvider._();

/// Katalog kategori usaha (published).

final class UsahaCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UsahaCategoryRef>>,
          List<UsahaCategoryRef>,
          FutureOr<List<UsahaCategoryRef>>
        >
    with
        $FutureModifier<List<UsahaCategoryRef>>,
        $FutureProvider<List<UsahaCategoryRef>> {
  /// Katalog kategori usaha (published).
  UsahaCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usahaCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usahaCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<UsahaCategoryRef>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UsahaCategoryRef>> create(Ref ref) {
    return usahaCategories(ref);
  }
}

String _$usahaCategoriesHash() => r'a7118494d92413dcbfc328390694b3a56b30fe33';

/// Usaha yang saya kelola. Guest = data kosong (bukan error).

@ProviderFor(UsahaMineController)
final usahaMineControllerProvider = UsahaMineControllerProvider._();

/// Usaha yang saya kelola. Guest = data kosong (bukan error).
final class UsahaMineControllerProvider
    extends $AsyncNotifierProvider<UsahaMineController, UsahaMine> {
  /// Usaha yang saya kelola. Guest = data kosong (bukan error).
  UsahaMineControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usahaMineControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usahaMineControllerHash();

  @$internal
  @override
  UsahaMineController create() => UsahaMineController();
}

String _$usahaMineControllerHash() =>
    r'c1602659b4c9527fdd10a74143d33cc5b37b6fd7';

/// Usaha yang saya kelola. Guest = data kosong (bukan error).

abstract class _$UsahaMineController extends $AsyncNotifier<UsahaMine> {
  FutureOr<UsahaMine> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UsahaMine>, UsahaMine>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UsahaMine>, UsahaMine>,
              AsyncValue<UsahaMine>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Usulan usaha milik user (status usulan).

@ProviderFor(UsahaProposalsController)
final usahaProposalsControllerProvider = UsahaProposalsControllerProvider._();

/// Usulan usaha milik user (status usulan).
final class UsahaProposalsControllerProvider
    extends
        $AsyncNotifierProvider<
          UsahaProposalsController,
          List<UsahaContribution>
        > {
  /// Usulan usaha milik user (status usulan).
  UsahaProposalsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usahaProposalsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usahaProposalsControllerHash();

  @$internal
  @override
  UsahaProposalsController create() => UsahaProposalsController();
}

String _$usahaProposalsControllerHash() =>
    r'ef6cf9420be5630a37ba30d8cce6a4da12a0b1cb';

/// Usulan usaha milik user (status usulan).

abstract class _$UsahaProposalsController
    extends $AsyncNotifier<List<UsahaContribution>> {
  FutureOr<List<UsahaContribution>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<UsahaContribution>>,
              List<UsahaContribution>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<UsahaContribution>>,
                List<UsahaContribution>
              >,
              AsyncValue<List<UsahaContribution>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Klaim pengelolaan milik user.

@ProviderFor(UsahaClaimsController)
final usahaClaimsControllerProvider = UsahaClaimsControllerProvider._();

/// Klaim pengelolaan milik user.
final class UsahaClaimsControllerProvider
    extends $AsyncNotifierProvider<UsahaClaimsController, List<UsahaClaim>> {
  /// Klaim pengelolaan milik user.
  UsahaClaimsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usahaClaimsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usahaClaimsControllerHash();

  @$internal
  @override
  UsahaClaimsController create() => UsahaClaimsController();
}

String _$usahaClaimsControllerHash() =>
    r'3bcbd2bfee1e04ec14b43ee61f38b9e5677c699e';

/// Klaim pengelolaan milik user.

abstract class _$UsahaClaimsController
    extends $AsyncNotifier<List<UsahaClaim>> {
  FutureOr<List<UsahaClaim>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<UsahaClaim>>, List<UsahaClaim>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<UsahaClaim>>, List<UsahaClaim>>,
              AsyncValue<List<UsahaClaim>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
