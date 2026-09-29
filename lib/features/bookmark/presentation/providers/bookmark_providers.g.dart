// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// State bookmark satu kata (1 keluarga = 1 wordId). Guest = selalu
/// unbookmarked; saat login, seed status dari GET /bookmarks/my?word_ids=.
/// Seed gagal → degrade unbookmarked (tombol tetap ada). Toggle memutakhirkan
/// state dari response server (state final).

@ProviderFor(BookmarkToggleController)
final bookmarkToggleControllerProvider = BookmarkToggleControllerFamily._();

/// State bookmark satu kata (1 keluarga = 1 wordId). Guest = selalu
/// unbookmarked; saat login, seed status dari GET /bookmarks/my?word_ids=.
/// Seed gagal → degrade unbookmarked (tombol tetap ada). Toggle memutakhirkan
/// state dari response server (state final).
final class BookmarkToggleControllerProvider
    extends $AsyncNotifierProvider<BookmarkToggleController, BookmarkStatus> {
  /// State bookmark satu kata (1 keluarga = 1 wordId). Guest = selalu
  /// unbookmarked; saat login, seed status dari GET /bookmarks/my?word_ids=.
  /// Seed gagal → degrade unbookmarked (tombol tetap ada). Toggle memutakhirkan
  /// state dari response server (state final).
  BookmarkToggleControllerProvider._({
    required BookmarkToggleControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookmarkToggleControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookmarkToggleControllerHash();

  @override
  String toString() {
    return r'bookmarkToggleControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BookmarkToggleController create() => BookmarkToggleController();

  @override
  bool operator ==(Object other) {
    return other is BookmarkToggleControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookmarkToggleControllerHash() =>
    r'36bfd5a48563373d9d600e2f3c4a461c3d86de33';

/// State bookmark satu kata (1 keluarga = 1 wordId). Guest = selalu
/// unbookmarked; saat login, seed status dari GET /bookmarks/my?word_ids=.
/// Seed gagal → degrade unbookmarked (tombol tetap ada). Toggle memutakhirkan
/// state dari response server (state final).

final class BookmarkToggleControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          BookmarkToggleController,
          AsyncValue<BookmarkStatus>,
          BookmarkStatus,
          FutureOr<BookmarkStatus>,
          String
        > {
  BookmarkToggleControllerFamily._()
    : super(
        retry: null,
        name: r'bookmarkToggleControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// State bookmark satu kata (1 keluarga = 1 wordId). Guest = selalu
  /// unbookmarked; saat login, seed status dari GET /bookmarks/my?word_ids=.
  /// Seed gagal → degrade unbookmarked (tombol tetap ada). Toggle memutakhirkan
  /// state dari response server (state final).

  BookmarkToggleControllerProvider call(String wordId) =>
      BookmarkToggleControllerProvider._(argument: wordId, from: this);

  @override
  String toString() => r'bookmarkToggleControllerProvider';
}

/// State bookmark satu kata (1 keluarga = 1 wordId). Guest = selalu
/// unbookmarked; saat login, seed status dari GET /bookmarks/my?word_ids=.
/// Seed gagal → degrade unbookmarked (tombol tetap ada). Toggle memutakhirkan
/// state dari response server (state final).

abstract class _$BookmarkToggleController
    extends $AsyncNotifier<BookmarkStatus> {
  late final _$args = ref.$arg as String;
  String get wordId => _$args;

  FutureOr<BookmarkStatus> build(String wordId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<BookmarkStatus>, BookmarkStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BookmarkStatus>, BookmarkStatus>,
              AsyncValue<BookmarkStatus>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// State halaman Bookmark (list milik user login, cursor pagination).
/// Guest = state kosong (halaman menampilkan prompt login). Hapus item
/// optimistik + restore saat gagal.
///
/// keepAlive: cache daftar tersimpan saat keluar halaman lalu kembali.
/// Watch authStatus: login/logout otomatis rebuild (jangan invalidate dari
/// AuthStatusNotifier - circular di Riverpod 3).

@ProviderFor(BookmarkListController)
final bookmarkListControllerProvider = BookmarkListControllerProvider._();

/// State halaman Bookmark (list milik user login, cursor pagination).
/// Guest = state kosong (halaman menampilkan prompt login). Hapus item
/// optimistik + restore saat gagal.
///
/// keepAlive: cache daftar tersimpan saat keluar halaman lalu kembali.
/// Watch authStatus: login/logout otomatis rebuild (jangan invalidate dari
/// AuthStatusNotifier - circular di Riverpod 3).
final class BookmarkListControllerProvider
    extends $AsyncNotifierProvider<BookmarkListController, BookmarkListState> {
  /// State halaman Bookmark (list milik user login, cursor pagination).
  /// Guest = state kosong (halaman menampilkan prompt login). Hapus item
  /// optimistik + restore saat gagal.
  ///
  /// keepAlive: cache daftar tersimpan saat keluar halaman lalu kembali.
  /// Watch authStatus: login/logout otomatis rebuild (jangan invalidate dari
  /// AuthStatusNotifier - circular di Riverpod 3).
  BookmarkListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookmarkListControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookmarkListControllerHash();

  @$internal
  @override
  BookmarkListController create() => BookmarkListController();
}

String _$bookmarkListControllerHash() =>
    r'269ae45bb3e389eca12058a5ea027bcbd5466d3e';

/// State halaman Bookmark (list milik user login, cursor pagination).
/// Guest = state kosong (halaman menampilkan prompt login). Hapus item
/// optimistik + restore saat gagal.
///
/// keepAlive: cache daftar tersimpan saat keluar halaman lalu kembali.
/// Watch authStatus: login/logout otomatis rebuild (jangan invalidate dari
/// AuthStatusNotifier - circular di Riverpod 3).

abstract class _$BookmarkListController
    extends $AsyncNotifier<BookmarkListState> {
  FutureOr<BookmarkListState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<BookmarkListState>, BookmarkListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BookmarkListState>, BookmarkListState>,
              AsyncValue<BookmarkListState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
