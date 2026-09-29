// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Load profil publik; error object = [UserProfileFailure] (termasuk 404).

@ProviderFor(publicProfile)
final publicProfileProvider = PublicProfileFamily._();

/// Load profil publik; error object = [UserProfileFailure] (termasuk 404).

final class PublicProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<PublicProfile>,
          PublicProfile,
          FutureOr<PublicProfile>
        >
    with $FutureModifier<PublicProfile>, $FutureProvider<PublicProfile> {
  /// Load profil publik; error object = [UserProfileFailure] (termasuk 404).
  PublicProfileProvider._({
    required PublicProfileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publicProfileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publicProfileHash();

  @override
  String toString() {
    return r'publicProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PublicProfile> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PublicProfile> create(Ref ref) {
    final argument = this.argument as String;
    return publicProfile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublicProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publicProfileHash() => r'36f8d3456b2a2b3af9c71a274dbd1c4e97a55672';

/// Load profil publik; error object = [UserProfileFailure] (termasuk 404).

final class PublicProfileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PublicProfile>, String> {
  PublicProfileFamily._()
    : super(
        retry: null,
        name: r'publicProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Load profil publik; error object = [UserProfileFailure] (termasuk 404).

  PublicProfileProvider call(String username) =>
      PublicProfileProvider._(argument: username, from: this);

  @override
  String toString() => r'publicProfileProvider';
}

@ProviderFor(publicActivity)
final publicActivityProvider = PublicActivityFamily._();

final class PublicActivityProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PublicActivityItem>>,
          List<PublicActivityItem>,
          FutureOr<List<PublicActivityItem>>
        >
    with
        $FutureModifier<List<PublicActivityItem>>,
        $FutureProvider<List<PublicActivityItem>> {
  PublicActivityProvider._({
    required PublicActivityFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publicActivityProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publicActivityHash();

  @override
  String toString() {
    return r'publicActivityProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PublicActivityItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PublicActivityItem>> create(Ref ref) {
    final argument = this.argument as String;
    return publicActivity(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublicActivityProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publicActivityHash() => r'fa37e0690a884798376a1bd863125a2a362d26de';

final class PublicActivityFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PublicActivityItem>>, String> {
  PublicActivityFamily._()
    : super(
        retry: null,
        name: r'publicActivityProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublicActivityProvider call(String username) =>
      PublicActivityProvider._(argument: username, from: this);

  @override
  String toString() => r'publicActivityProvider';
}
