// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// State vote per target (1 keluarga = 1 VoteTarget). Load counts (publik)
/// + my_vote (kalau login), lalu toggle memutakhirkan state in-place
/// memakai response server (count + my_vote final).

@ProviderFor(VoteController)
final voteControllerProvider = VoteControllerFamily._();

/// State vote per target (1 keluarga = 1 VoteTarget). Load counts (publik)
/// + my_vote (kalau login), lalu toggle memutakhirkan state in-place
/// memakai response server (count + my_vote final).
final class VoteControllerProvider
    extends $AsyncNotifierProvider<VoteController, VoteView> {
  /// State vote per target (1 keluarga = 1 VoteTarget). Load counts (publik)
  /// + my_vote (kalau login), lalu toggle memutakhirkan state in-place
  /// memakai response server (count + my_vote final).
  VoteControllerProvider._({
    required VoteControllerFamily super.from,
    required VoteTarget super.argument,
  }) : super(
         retry: null,
         name: r'voteControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$voteControllerHash();

  @override
  String toString() {
    return r'voteControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  VoteController create() => VoteController();

  @override
  bool operator ==(Object other) {
    return other is VoteControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$voteControllerHash() => r'afd593ac2abead1ac98173ea2f58308507e880c6';

/// State vote per target (1 keluarga = 1 VoteTarget). Load counts (publik)
/// + my_vote (kalau login), lalu toggle memutakhirkan state in-place
/// memakai response server (count + my_vote final).

final class VoteControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          VoteController,
          AsyncValue<VoteView>,
          VoteView,
          FutureOr<VoteView>,
          VoteTarget
        > {
  VoteControllerFamily._()
    : super(
        retry: null,
        name: r'voteControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// State vote per target (1 keluarga = 1 VoteTarget). Load counts (publik)
  /// + my_vote (kalau login), lalu toggle memutakhirkan state in-place
  /// memakai response server (count + my_vote final).

  VoteControllerProvider call(VoteTarget target) =>
      VoteControllerProvider._(argument: target, from: this);

  @override
  String toString() => r'voteControllerProvider';
}

/// State vote per target (1 keluarga = 1 VoteTarget). Load counts (publik)
/// + my_vote (kalau login), lalu toggle memutakhirkan state in-place
/// memakai response server (count + my_vote final).

abstract class _$VoteController extends $AsyncNotifier<VoteView> {
  late final _$args = ref.$arg as VoteTarget;
  VoteTarget get target => _$args;

  FutureOr<VoteView> build(VoteTarget target);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<VoteView>, VoteView>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<VoteView>, VoteView>,
              AsyncValue<VoteView>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
