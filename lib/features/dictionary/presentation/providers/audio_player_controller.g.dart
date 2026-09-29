// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_player_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Satu [AudioPlayer] per halaman detail kata.

@ProviderFor(WordDetailAudioPlayer)
final wordDetailAudioPlayerProvider = WordDetailAudioPlayerFamily._();

/// Satu [AudioPlayer] per halaman detail kata.
final class WordDetailAudioPlayerProvider
    extends $NotifierProvider<WordDetailAudioPlayer, WordDetailAudioView> {
  /// Satu [AudioPlayer] per halaman detail kata.
  WordDetailAudioPlayerProvider._({
    required WordDetailAudioPlayerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'wordDetailAudioPlayerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$wordDetailAudioPlayerHash();

  @override
  String toString() {
    return r'wordDetailAudioPlayerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WordDetailAudioPlayer create() => WordDetailAudioPlayer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WordDetailAudioView value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WordDetailAudioView>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WordDetailAudioPlayerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$wordDetailAudioPlayerHash() =>
    r'2828446b73d61a91164a84403137f20c6bc6cba6';

/// Satu [AudioPlayer] per halaman detail kata.

final class WordDetailAudioPlayerFamily extends $Family
    with
        $ClassFamilyOverride<
          WordDetailAudioPlayer,
          WordDetailAudioView,
          WordDetailAudioView,
          WordDetailAudioView,
          String
        > {
  WordDetailAudioPlayerFamily._()
    : super(
        retry: null,
        name: r'wordDetailAudioPlayerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Satu [AudioPlayer] per halaman detail kata.

  WordDetailAudioPlayerProvider call(String wordId) =>
      WordDetailAudioPlayerProvider._(argument: wordId, from: this);

  @override
  String toString() => r'wordDetailAudioPlayerProvider';
}

/// Satu [AudioPlayer] per halaman detail kata.

abstract class _$WordDetailAudioPlayer extends $Notifier<WordDetailAudioView> {
  late final _$args = ref.$arg as String;
  String get wordId => _$args;

  WordDetailAudioView build(String wordId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WordDetailAudioView, WordDetailAudioView>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WordDetailAudioView, WordDetailAudioView>,
              WordDetailAudioView,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
