// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'letter_words_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Browse kata per huruf (setara web `/huruf/:letter`).
/// Family per huruf supaya state A tidak bentrok dengan B.

@ProviderFor(LetterWordsNotifier)
final letterWordsProvider = LetterWordsNotifierFamily._();

/// Browse kata per huruf (setara web `/huruf/:letter`).
/// Family per huruf supaya state A tidak bentrok dengan B.
final class LetterWordsNotifierProvider
    extends $NotifierProvider<LetterWordsNotifier, LetterWordsState> {
  /// Browse kata per huruf (setara web `/huruf/:letter`).
  /// Family per huruf supaya state A tidak bentrok dengan B.
  LetterWordsNotifierProvider._({
    required LetterWordsNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'letterWordsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$letterWordsNotifierHash();

  @override
  String toString() {
    return r'letterWordsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LetterWordsNotifier create() => LetterWordsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LetterWordsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LetterWordsState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LetterWordsNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$letterWordsNotifierHash() =>
    r'7d9ef7950e41ae58bc55232c7a060f70e945d32a';

/// Browse kata per huruf (setara web `/huruf/:letter`).
/// Family per huruf supaya state A tidak bentrok dengan B.

final class LetterWordsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          LetterWordsNotifier,
          LetterWordsState,
          LetterWordsState,
          LetterWordsState,
          String
        > {
  LetterWordsNotifierFamily._()
    : super(
        retry: null,
        name: r'letterWordsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Browse kata per huruf (setara web `/huruf/:letter`).
  /// Family per huruf supaya state A tidak bentrok dengan B.

  LetterWordsNotifierProvider call(String letter) =>
      LetterWordsNotifierProvider._(argument: letter, from: this);

  @override
  String toString() => r'letterWordsProvider';
}

/// Browse kata per huruf (setara web `/huruf/:letter`).
/// Family per huruf supaya state A tidak bentrok dengan B.

abstract class _$LetterWordsNotifier extends $Notifier<LetterWordsState> {
  late final _$args = ref.$arg as String;
  String get letter => _$args;

  LetterWordsState build(String letter);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LetterWordsState, LetterWordsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LetterWordsState, LetterWordsState>,
              LetterWordsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
