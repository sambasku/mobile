// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// State list komentar per kata (1 keluarga = 1 wordId). Load halaman
/// pertama; saat login, seed `myVote` per komentar dari GET /votes/my
/// (satu request batch, bukan N+1). Method mutasi (create/delete/loadMore)
/// meng-update state in-place dan mengembalikan `CommentFailure?` agar
/// widget bisa menampilkan toast.

@ProviderFor(CommentListController)
final commentListControllerProvider = CommentListControllerFamily._();

/// State list komentar per kata (1 keluarga = 1 wordId). Load halaman
/// pertama; saat login, seed `myVote` per komentar dari GET /votes/my
/// (satu request batch, bukan N+1). Method mutasi (create/delete/loadMore)
/// meng-update state in-place dan mengembalikan `CommentFailure?` agar
/// widget bisa menampilkan toast.
final class CommentListControllerProvider
    extends $AsyncNotifierProvider<CommentListController, CommentListState> {
  /// State list komentar per kata (1 keluarga = 1 wordId). Load halaman
  /// pertama; saat login, seed `myVote` per komentar dari GET /votes/my
  /// (satu request batch, bukan N+1). Method mutasi (create/delete/loadMore)
  /// meng-update state in-place dan mengembalikan `CommentFailure?` agar
  /// widget bisa menampilkan toast.
  CommentListControllerProvider._({
    required CommentListControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'commentListControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$commentListControllerHash();

  @override
  String toString() {
    return r'commentListControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CommentListController create() => CommentListController();

  @override
  bool operator ==(Object other) {
    return other is CommentListControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$commentListControllerHash() =>
    r'fe233502a345938b71e5ea0e633d28abb9a8385d';

/// State list komentar per kata (1 keluarga = 1 wordId). Load halaman
/// pertama; saat login, seed `myVote` per komentar dari GET /votes/my
/// (satu request batch, bukan N+1). Method mutasi (create/delete/loadMore)
/// meng-update state in-place dan mengembalikan `CommentFailure?` agar
/// widget bisa menampilkan toast.

final class CommentListControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CommentListController,
          AsyncValue<CommentListState>,
          CommentListState,
          FutureOr<CommentListState>,
          String
        > {
  CommentListControllerFamily._()
    : super(
        retry: null,
        name: r'commentListControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// State list komentar per kata (1 keluarga = 1 wordId). Load halaman
  /// pertama; saat login, seed `myVote` per komentar dari GET /votes/my
  /// (satu request batch, bukan N+1). Method mutasi (create/delete/loadMore)
  /// meng-update state in-place dan mengembalikan `CommentFailure?` agar
  /// widget bisa menampilkan toast.

  CommentListControllerProvider call(String wordId) =>
      CommentListControllerProvider._(argument: wordId, from: this);

  @override
  String toString() => r'commentListControllerProvider';
}

/// State list komentar per kata (1 keluarga = 1 wordId). Load halaman
/// pertama; saat login, seed `myVote` per komentar dari GET /votes/my
/// (satu request batch, bukan N+1). Method mutasi (create/delete/loadMore)
/// meng-update state in-place dan mengembalikan `CommentFailure?` agar
/// widget bisa menampilkan toast.

abstract class _$CommentListController
    extends $AsyncNotifier<CommentListState> {
  late final _$args = ref.$arg as String;
  String get wordId => _$args;

  FutureOr<CommentListState> build(String wordId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CommentListState>, CommentListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CommentListState>, CommentListState>,
              AsyncValue<CommentListState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
