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

/// Load aktivitas publik (mode merge - tanpa filter kind, max 20, tanpa cursor).

@ProviderFor(publicActivity)
final publicActivityProvider = PublicActivityFamily._();

/// Load aktivitas publik (mode merge - tanpa filter kind, max 20, tanpa cursor).

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
  /// Load aktivitas publik (mode merge - tanpa filter kind, max 20, tanpa cursor).
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

String _$publicActivityHash() => r'178655bc089e83b6700272b5f263b1cfbd77e622';

/// Load aktivitas publik (mode merge - tanpa filter kind, max 20, tanpa cursor).

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

  /// Load aktivitas publik (mode merge - tanpa filter kind, max 20, tanpa cursor).

  PublicActivityProvider call(String username) =>
      PublicActivityProvider._(argument: username, from: this);

  @override
  String toString() => r'publicActivityProvider';
}

/// Provider family per kategori (kind: contribution|comment|verification|vote).
/// Pagination manual via parameter `cursor` - dipakai di bottom sheet.

@ProviderFor(publicActivityByKind)
final publicActivityByKindProvider = PublicActivityByKindFamily._();

/// Provider family per kategori (kind: contribution|comment|verification|vote).
/// Pagination manual via parameter `cursor` - dipakai di bottom sheet.

final class PublicActivityByKindProvider
    extends
        $FunctionalProvider<
          AsyncValue<PublicActivityCategoryState>,
          PublicActivityCategoryState,
          FutureOr<PublicActivityCategoryState>
        >
    with
        $FutureModifier<PublicActivityCategoryState>,
        $FutureProvider<PublicActivityCategoryState> {
  /// Provider family per kategori (kind: contribution|comment|verification|vote).
  /// Pagination manual via parameter `cursor` - dipakai di bottom sheet.
  PublicActivityByKindProvider._({
    required PublicActivityByKindFamily super.from,
    required (String, String, {String? cursor}) super.argument,
  }) : super(
         retry: null,
         name: r'publicActivityByKindProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publicActivityByKindHash();

  @override
  String toString() {
    return r'publicActivityByKindProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PublicActivityCategoryState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PublicActivityCategoryState> create(Ref ref) {
    final argument = this.argument as (String, String, {String? cursor});
    return publicActivityByKind(
      ref,
      argument.$1,
      argument.$2,
      cursor: argument.cursor,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PublicActivityByKindProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publicActivityByKindHash() =>
    r'a7887d150784c3bb8795b59c940515b306e29ebf';

/// Provider family per kategori (kind: contribution|comment|verification|vote).
/// Pagination manual via parameter `cursor` - dipakai di bottom sheet.

final class PublicActivityByKindFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PublicActivityCategoryState>,
          (String, String, {String? cursor})
        > {
  PublicActivityByKindFamily._()
    : super(
        retry: null,
        name: r'publicActivityByKindProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider family per kategori (kind: contribution|comment|verification|vote).
  /// Pagination manual via parameter `cursor` - dipakai di bottom sheet.

  PublicActivityByKindProvider call(
    String username,
    String kind, {
    String? cursor,
  }) => PublicActivityByKindProvider._(
    argument: (username, kind, cursor: cursor),
    from: this,
  );

  @override
  String toString() => r'publicActivityByKindProvider';
}
