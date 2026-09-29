// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pronunciation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pronunciationAudioUploadService)
final pronunciationAudioUploadServiceProvider =
    PronunciationAudioUploadServiceProvider._();

final class PronunciationAudioUploadServiceProvider
    extends
        $FunctionalProvider<
          PronunciationAudioUploadService,
          PronunciationAudioUploadService,
          PronunciationAudioUploadService
        >
    with $Provider<PronunciationAudioUploadService> {
  PronunciationAudioUploadServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pronunciationAudioUploadServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pronunciationAudioUploadServiceHash();

  @$internal
  @override
  $ProviderElement<PronunciationAudioUploadService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PronunciationAudioUploadService create(Ref ref) {
    return pronunciationAudioUploadService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PronunciationAudioUploadService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PronunciationAudioUploadService>(
        value,
      ),
    );
  }
}

String _$pronunciationAudioUploadServiceHash() =>
    r'f2de9a7882b19a94c9ad2fbc56217e4be47bc046';

/// Set true setelah 503 - sembunyikan tombol rekam di halaman ini.

@ProviderFor(PronunciationUploadUnavailable)
final pronunciationUploadUnavailableProvider =
    PronunciationUploadUnavailableFamily._();

/// Set true setelah 503 - sembunyikan tombol rekam di halaman ini.
final class PronunciationUploadUnavailableProvider
    extends $NotifierProvider<PronunciationUploadUnavailable, bool> {
  /// Set true setelah 503 - sembunyikan tombol rekam di halaman ini.
  PronunciationUploadUnavailableProvider._({
    required PronunciationUploadUnavailableFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'pronunciationUploadUnavailableProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pronunciationUploadUnavailableHash();

  @override
  String toString() {
    return r'pronunciationUploadUnavailableProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PronunciationUploadUnavailable create() => PronunciationUploadUnavailable();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PronunciationUploadUnavailableProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pronunciationUploadUnavailableHash() =>
    r'cd9792fddea99d4824dbec22b067aabe831bcdec';

/// Set true setelah 503 - sembunyikan tombol rekam di halaman ini.

final class PronunciationUploadUnavailableFamily extends $Family
    with
        $ClassFamilyOverride<
          PronunciationUploadUnavailable,
          bool,
          bool,
          bool,
          String
        > {
  PronunciationUploadUnavailableFamily._()
    : super(
        retry: null,
        name: r'pronunciationUploadUnavailableProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Set true setelah 503 - sembunyikan tombol rekam di halaman ini.

  PronunciationUploadUnavailableProvider call(String wordId) =>
      PronunciationUploadUnavailableProvider._(argument: wordId, from: this);

  @override
  String toString() => r'pronunciationUploadUnavailableProvider';
}

/// Set true setelah 503 - sembunyikan tombol rekam di halaman ini.

abstract class _$PronunciationUploadUnavailable extends $Notifier<bool> {
  late final _$args = ref.$arg as String;
  String get wordId => _$args;

  bool build(String wordId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Toast 503 sekali per sesi halaman.

@ProviderFor(PronunciationUploadToastShown)
final pronunciationUploadToastShownProvider =
    PronunciationUploadToastShownFamily._();

/// Toast 503 sekali per sesi halaman.
final class PronunciationUploadToastShownProvider
    extends $NotifierProvider<PronunciationUploadToastShown, bool> {
  /// Toast 503 sekali per sesi halaman.
  PronunciationUploadToastShownProvider._({
    required PronunciationUploadToastShownFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'pronunciationUploadToastShownProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pronunciationUploadToastShownHash();

  @override
  String toString() {
    return r'pronunciationUploadToastShownProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PronunciationUploadToastShown create() => PronunciationUploadToastShown();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PronunciationUploadToastShownProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pronunciationUploadToastShownHash() =>
    r'067901f3e02b0834a3043c06e3400b248496190a';

/// Toast 503 sekali per sesi halaman.

final class PronunciationUploadToastShownFamily extends $Family
    with
        $ClassFamilyOverride<
          PronunciationUploadToastShown,
          bool,
          bool,
          bool,
          String
        > {
  PronunciationUploadToastShownFamily._()
    : super(
        retry: null,
        name: r'pronunciationUploadToastShownProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Toast 503 sekali per sesi halaman.

  PronunciationUploadToastShownProvider call(String wordId) =>
      PronunciationUploadToastShownProvider._(argument: wordId, from: this);

  @override
  String toString() => r'pronunciationUploadToastShownProvider';
}

/// Toast 503 sekali per sesi halaman.

abstract class _$PronunciationUploadToastShown extends $Notifier<bool> {
  late final _$args = ref.$arg as String;
  String get wordId => _$args;

  bool build(String wordId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(wordDialects)
final wordDialectsProvider = WordDialectsFamily._();

final class WordDialectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DialectOption>>,
          List<DialectOption>,
          FutureOr<List<DialectOption>>
        >
    with
        $FutureModifier<List<DialectOption>>,
        $FutureProvider<List<DialectOption>> {
  WordDialectsProvider._({
    required WordDialectsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'wordDialectsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$wordDialectsHash();

  @override
  String toString() {
    return r'wordDialectsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DialectOption>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DialectOption>> create(Ref ref) {
    final argument = this.argument as String;
    return wordDialects(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WordDialectsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$wordDialectsHash() => r'110350ee97ce524ef4282dce132006fcd7e6221e';

final class WordDialectsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<DialectOption>>, String> {
  WordDialectsFamily._()
    : super(
        retry: null,
        name: r'wordDialectsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WordDialectsProvider call(String languageId) =>
      WordDialectsProvider._(argument: languageId, from: this);

  @override
  String toString() => r'wordDialectsProvider';
}
