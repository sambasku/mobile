// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Milik user login: owned + locked (GET /me/achievements).

@ProviderFor(myAchievements)
final myAchievementsProvider = MyAchievementsFamily._();

/// Milik user login: owned + locked (GET /me/achievements).

final class MyAchievementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Achievement>>,
          List<Achievement>,
          FutureOr<List<Achievement>>
        >
    with
        $FutureModifier<List<Achievement>>,
        $FutureProvider<List<Achievement>> {
  /// Milik user login: owned + locked (GET /me/achievements).
  MyAchievementsProvider._({
    required MyAchievementsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'myAchievementsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myAchievementsHash();

  @override
  String toString() {
    return r'myAchievementsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Achievement>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Achievement>> create(Ref ref) {
    final argument = this.argument as String?;
    return myAchievements(ref, rewardType: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyAchievementsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myAchievementsHash() => r'8ffe7a5e18a42b313f851ec020e557070a62087b';

/// Milik user login: owned + locked (GET /me/achievements).

final class MyAchievementsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Achievement>>, String?> {
  MyAchievementsFamily._()
    : super(
        retry: null,
        name: r'myAchievementsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Milik user login: owned + locked (GET /me/achievements).

  MyAchievementsProvider call({String? rewardType}) =>
      MyAchievementsProvider._(argument: rewardType, from: this);

  @override
  String toString() => r'myAchievementsProvider';
}

/// Reward milik user publik by username (badge profil).

@ProviderFor(userAchievements)
final userAchievementsProvider = UserAchievementsFamily._();

/// Reward milik user publik by username (badge profil).

final class UserAchievementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Achievement>>,
          List<Achievement>,
          FutureOr<List<Achievement>>
        >
    with
        $FutureModifier<List<Achievement>>,
        $FutureProvider<List<Achievement>> {
  /// Reward milik user publik by username (badge profil).
  UserAchievementsProvider._({
    required UserAchievementsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userAchievementsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userAchievementsHash();

  @override
  String toString() {
    return r'userAchievementsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Achievement>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Achievement>> create(Ref ref) {
    final argument = this.argument as String;
    return userAchievements(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserAchievementsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userAchievementsHash() => r'6782ecc15cdb2bb8309f41f3ebb745228d47c39b';

/// Reward milik user publik by username (badge profil).

final class UserAchievementsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Achievement>>, String> {
  UserAchievementsFamily._()
    : super(
        retry: null,
        name: r'userAchievementsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Reward milik user publik by username (badge profil).

  UserAchievementsProvider call(String username) =>
      UserAchievementsProvider._(argument: username, from: this);

  @override
  String toString() => r'userAchievementsProvider';
}

/// Border aktif milik user login (overlay avatar profil sendiri). null = tanpa bingkai.

@ProviderFor(myActiveBorder)
final myActiveBorderProvider = MyActiveBorderProvider._();

/// Border aktif milik user login (overlay avatar profil sendiri). null = tanpa bingkai.

final class MyActiveBorderProvider
    extends
        $FunctionalProvider<
          AsyncValue<ActiveBorder?>,
          ActiveBorder?,
          FutureOr<ActiveBorder?>
        >
    with $FutureModifier<ActiveBorder?>, $FutureProvider<ActiveBorder?> {
  /// Border aktif milik user login (overlay avatar profil sendiri). null = tanpa bingkai.
  MyActiveBorderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myActiveBorderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myActiveBorderHash();

  @$internal
  @override
  $FutureProviderElement<ActiveBorder?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ActiveBorder?> create(Ref ref) {
    return myActiveBorder(ref);
  }
}

String _$myActiveBorderHash() => r'91b14ddf8d4d46744d30ec2cdec25c810c9ae92b';
