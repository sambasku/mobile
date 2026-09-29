// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_of_day_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Kata hari ini. Null = korpus kosong ATAU gagal (soft-fail: kartu hilang).

@ProviderFor(wordOfDay)
final wordOfDayProvider = WordOfDayProvider._();

/// Kata hari ini. Null = korpus kosong ATAU gagal (soft-fail: kartu hilang).

final class WordOfDayProvider
    extends
        $FunctionalProvider<
          AsyncValue<WordOfDay?>,
          WordOfDay?,
          FutureOr<WordOfDay?>
        >
    with $FutureModifier<WordOfDay?>, $FutureProvider<WordOfDay?> {
  /// Kata hari ini. Null = korpus kosong ATAU gagal (soft-fail: kartu hilang).
  WordOfDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wordOfDayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wordOfDayHash();

  @$internal
  @override
  $FutureProviderElement<WordOfDay?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<WordOfDay?> create(Ref ref) {
    return wordOfDay(ref);
  }
}

String _$wordOfDayHash() => r'cc682bb0f506b38d25f3a52ff6f69d96b7630442';
