// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'about_api_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(aboutApiDatasource)
final aboutApiDatasourceProvider = AboutApiDatasourceProvider._();

final class AboutApiDatasourceProvider
    extends
        $FunctionalProvider<
          AboutApiDatasource,
          AboutApiDatasource,
          AboutApiDatasource
        >
    with $Provider<AboutApiDatasource> {
  AboutApiDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aboutApiDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aboutApiDatasourceHash();

  @$internal
  @override
  $ProviderElement<AboutApiDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AboutApiDatasource create(Ref ref) {
    return aboutApiDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AboutApiDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AboutApiDatasource>(value),
    );
  }
}

String _$aboutApiDatasourceHash() =>
    r'944e7623c4f243f2714659f8b93759f8e9e53fb5';

@ProviderFor(aboutTeam)
final aboutTeamProvider = AboutTeamProvider._();

final class AboutTeamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AboutTeamMember>?>,
          List<AboutTeamMember>?,
          FutureOr<List<AboutTeamMember>?>
        >
    with
        $FutureModifier<List<AboutTeamMember>?>,
        $FutureProvider<List<AboutTeamMember>?> {
  AboutTeamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aboutTeamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aboutTeamHash();

  @$internal
  @override
  $FutureProviderElement<List<AboutTeamMember>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AboutTeamMember>?> create(Ref ref) {
    return aboutTeam(ref);
  }
}

String _$aboutTeamHash() => r'f66d9f3719a6592e7fe210b12862f2e2cbdc3eb2';

@ProviderFor(aboutSponsorships)
final aboutSponsorshipsProvider = AboutSponsorshipsProvider._();

final class AboutSponsorshipsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AboutSponsorship>?>,
          List<AboutSponsorship>?,
          FutureOr<List<AboutSponsorship>?>
        >
    with
        $FutureModifier<List<AboutSponsorship>?>,
        $FutureProvider<List<AboutSponsorship>?> {
  AboutSponsorshipsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aboutSponsorshipsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aboutSponsorshipsHash();

  @$internal
  @override
  $FutureProviderElement<List<AboutSponsorship>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AboutSponsorship>?> create(Ref ref) {
    return aboutSponsorships(ref);
  }
}

String _$aboutSponsorshipsHash() => r'171e2713766bd199b595af44a03363bc694587e1';

@ProviderFor(aboutVerifiers)
final aboutVerifiersProvider = AboutVerifiersProvider._();

final class AboutVerifiersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AboutVerifier>?>,
          List<AboutVerifier>?,
          FutureOr<List<AboutVerifier>?>
        >
    with
        $FutureModifier<List<AboutVerifier>?>,
        $FutureProvider<List<AboutVerifier>?> {
  AboutVerifiersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aboutVerifiersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aboutVerifiersHash();

  @$internal
  @override
  $FutureProviderElement<List<AboutVerifier>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AboutVerifier>?> create(Ref ref) {
    return aboutVerifiers(ref);
  }
}

String _$aboutVerifiersHash() => r'9d0c93946796a91946ddfe68549758336fe2f8be';

@ProviderFor(AboutContributors)
final aboutContributorsProvider = AboutContributorsProvider._();

final class AboutContributorsProvider
    extends $AsyncNotifierProvider<AboutContributors, AboutContributorsState?> {
  AboutContributorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aboutContributorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aboutContributorsHash();

  @$internal
  @override
  AboutContributors create() => AboutContributors();
}

String _$aboutContributorsHash() => r'42d3d1e79e5c31112a189a4964638ff619325ed2';

abstract class _$AboutContributors
    extends $AsyncNotifier<AboutContributorsState?> {
  FutureOr<AboutContributorsState?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<AboutContributorsState?>,
              AboutContributorsState?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AboutContributorsState?>,
                AboutContributorsState?
              >,
              AsyncValue<AboutContributorsState?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
