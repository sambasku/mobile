// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(communityApi)
final communityApiProvider = CommunityApiProvider._();

final class CommunityApiProvider
    extends $FunctionalProvider<CommunityApi, CommunityApi, CommunityApi>
    with $Provider<CommunityApi> {
  CommunityApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'communityApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$communityApiHash();

  @$internal
  @override
  $ProviderElement<CommunityApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CommunityApi create(Ref ref) {
    return communityApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommunityApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommunityApi>(value),
    );
  }
}

String _$communityApiHash() => r'5b481dd4ad032d83cbec1ff56262a804574eff47';

@ProviderFor(communityCategories)
final communityCategoriesProvider = CommunityCategoriesProvider._();

final class CommunityCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CommunityCategoryRef>>,
          List<CommunityCategoryRef>,
          FutureOr<List<CommunityCategoryRef>>
        >
    with
        $FutureModifier<List<CommunityCategoryRef>>,
        $FutureProvider<List<CommunityCategoryRef>> {
  CommunityCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'communityCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$communityCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<CommunityCategoryRef>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CommunityCategoryRef>> create(Ref ref) {
    return communityCategories(ref);
  }
}

String _$communityCategoriesHash() =>
    r'a176e358128922b90a50f1c7f7d18eb59a6ad8e1';

@ProviderFor(communityOrgList)
final communityOrgListProvider = CommunityOrgListFamily._();

final class CommunityOrgListProvider
    extends
        $FunctionalProvider<
          AsyncValue<CommunityOrgPage>,
          CommunityOrgPage,
          FutureOr<CommunityOrgPage>
        >
    with $FutureModifier<CommunityOrgPage>, $FutureProvider<CommunityOrgPage> {
  CommunityOrgListProvider._({
    required CommunityOrgListFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'communityOrgListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$communityOrgListHash();

  @override
  String toString() {
    return r'communityOrgListProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<CommunityOrgPage> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CommunityOrgPage> create(Ref ref) {
    final argument = this.argument as (String, String);
    return communityOrgList(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityOrgListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$communityOrgListHash() => r'e12d206128d7adb88a487d756a5d2cc4cdcb6420';

final class CommunityOrgListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<CommunityOrgPage>,
          (String, String)
        > {
  CommunityOrgListFamily._()
    : super(
        retry: null,
        name: r'communityOrgListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CommunityOrgListProvider call(String categoryId, String query) =>
      CommunityOrgListProvider._(argument: (categoryId, query), from: this);

  @override
  String toString() => r'communityOrgListProvider';
}

@ProviderFor(communityOrgDetail)
final communityOrgDetailProvider = CommunityOrgDetailFamily._();

final class CommunityOrgDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<CommunityOrg?>,
          CommunityOrg?,
          FutureOr<CommunityOrg?>
        >
    with $FutureModifier<CommunityOrg?>, $FutureProvider<CommunityOrg?> {
  CommunityOrgDetailProvider._({
    required CommunityOrgDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'communityOrgDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$communityOrgDetailHash();

  @override
  String toString() {
    return r'communityOrgDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CommunityOrg?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CommunityOrg?> create(Ref ref) {
    final argument = this.argument as String;
    return communityOrgDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityOrgDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$communityOrgDetailHash() =>
    r'74bd57fa0c5d36a0a844c48d4f9c54dfe536d1b1';

final class CommunityOrgDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CommunityOrg?>, String> {
  CommunityOrgDetailFamily._()
    : super(
        retry: null,
        name: r'communityOrgDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CommunityOrgDetailProvider call(String slug) =>
      CommunityOrgDetailProvider._(argument: slug, from: this);

  @override
  String toString() => r'communityOrgDetailProvider';
}

@ProviderFor(communityFeatured)
final communityFeaturedProvider = CommunityFeaturedProvider._();

final class CommunityFeaturedProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CommunityOrg>>,
          List<CommunityOrg>,
          FutureOr<List<CommunityOrg>>
        >
    with
        $FutureModifier<List<CommunityOrg>>,
        $FutureProvider<List<CommunityOrg>> {
  CommunityFeaturedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'communityFeaturedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$communityFeaturedHash();

  @$internal
  @override
  $FutureProviderElement<List<CommunityOrg>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CommunityOrg>> create(Ref ref) {
    return communityFeatured(ref);
  }
}

String _$communityFeaturedHash() => r'874acbc17ebb8419b0e572d4af65cea051cd48e0';

@ProviderFor(CommunityMineController)
final communityMineControllerProvider = CommunityMineControllerProvider._();

final class CommunityMineControllerProvider
    extends
        $AsyncNotifierProvider<
          CommunityMineController,
          List<CommunityProposal>
        > {
  CommunityMineControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'communityMineControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$communityMineControllerHash();

  @$internal
  @override
  CommunityMineController create() => CommunityMineController();
}

String _$communityMineControllerHash() =>
    r'1c52d32dda5731485c092473ad33a3935608d356';

abstract class _$CommunityMineController
    extends $AsyncNotifier<List<CommunityProposal>> {
  FutureOr<List<CommunityProposal>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<CommunityProposal>>,
              List<CommunityProposal>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<CommunityProposal>>,
                List<CommunityProposal>
              >,
              AsyncValue<List<CommunityProposal>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(uploadCommunityLogo)
final uploadCommunityLogoProvider = UploadCommunityLogoFamily._();

final class UploadCommunityLogoProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  UploadCommunityLogoProvider._({
    required UploadCommunityLogoFamily super.from,
    required File super.argument,
  }) : super(
         retry: null,
         name: r'uploadCommunityLogoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$uploadCommunityLogoHash();

  @override
  String toString() {
    return r'uploadCommunityLogoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as File;
    return uploadCommunityLogo(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UploadCommunityLogoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$uploadCommunityLogoHash() =>
    r'14318ff5b8408fc7cacfbd4ec0e1b017811f95a6';

final class UploadCommunityLogoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, File> {
  UploadCommunityLogoFamily._()
    : super(
        retry: null,
        name: r'uploadCommunityLogoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UploadCommunityLogoProvider call(File file) =>
      UploadCommunityLogoProvider._(argument: file, from: this);

  @override
  String toString() => r'uploadCommunityLogoProvider';
}
