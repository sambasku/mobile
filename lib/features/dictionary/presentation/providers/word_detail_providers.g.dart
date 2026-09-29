// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_detail_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Load detail kata; [wordIdOrLemma] boleh ULID atau lemma (deep link web).
/// Error object = [DictionaryFailure] (termasuk 404).
///
/// keepAlive: family per kunci tetap di cache saat pop detail → buka
/// lagi / navigasi antar kata yang sudah pernah dibuka tidak refetch
/// Riverpod. Repository juga menulis L1 (`CacheClass.dictionaryDetail`)
/// supaya cold start / kill process masih bisa HIT dalam TTL.
/// Pull-to-refresh: hard miss L1 (`forceRefresh: true`) lalu invalidate.

@ProviderFor(wordDetail)
final wordDetailProvider = WordDetailFamily._();

/// Load detail kata; [wordIdOrLemma] boleh ULID atau lemma (deep link web).
/// Error object = [DictionaryFailure] (termasuk 404).
///
/// keepAlive: family per kunci tetap di cache saat pop detail → buka
/// lagi / navigasi antar kata yang sudah pernah dibuka tidak refetch
/// Riverpod. Repository juga menulis L1 (`CacheClass.dictionaryDetail`)
/// supaya cold start / kill process masih bisa HIT dalam TTL.
/// Pull-to-refresh: hard miss L1 (`forceRefresh: true`) lalu invalidate.

final class WordDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<WordDetail>,
          WordDetail,
          FutureOr<WordDetail>
        >
    with $FutureModifier<WordDetail>, $FutureProvider<WordDetail> {
  /// Load detail kata; [wordIdOrLemma] boleh ULID atau lemma (deep link web).
  /// Error object = [DictionaryFailure] (termasuk 404).
  ///
  /// keepAlive: family per kunci tetap di cache saat pop detail → buka
  /// lagi / navigasi antar kata yang sudah pernah dibuka tidak refetch
  /// Riverpod. Repository juga menulis L1 (`CacheClass.dictionaryDetail`)
  /// supaya cold start / kill process masih bisa HIT dalam TTL.
  /// Pull-to-refresh: hard miss L1 (`forceRefresh: true`) lalu invalidate.
  WordDetailProvider._({
    required WordDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'wordDetailProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$wordDetailHash();

  @override
  String toString() {
    return r'wordDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<WordDetail> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<WordDetail> create(Ref ref) {
    final argument = this.argument as String;
    return wordDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WordDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$wordDetailHash() => r'42dcb13eb996b23cd2e75a0a23467a76b99cd39f';

/// Load detail kata; [wordIdOrLemma] boleh ULID atau lemma (deep link web).
/// Error object = [DictionaryFailure] (termasuk 404).
///
/// keepAlive: family per kunci tetap di cache saat pop detail → buka
/// lagi / navigasi antar kata yang sudah pernah dibuka tidak refetch
/// Riverpod. Repository juga menulis L1 (`CacheClass.dictionaryDetail`)
/// supaya cold start / kill process masih bisa HIT dalam TTL.
/// Pull-to-refresh: hard miss L1 (`forceRefresh: true`) lalu invalidate.

final class WordDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<WordDetail>, String> {
  WordDetailFamily._()
    : super(
        retry: null,
        name: r'wordDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Load detail kata; [wordIdOrLemma] boleh ULID atau lemma (deep link web).
  /// Error object = [DictionaryFailure] (termasuk 404).
  ///
  /// keepAlive: family per kunci tetap di cache saat pop detail → buka
  /// lagi / navigasi antar kata yang sudah pernah dibuka tidak refetch
  /// Riverpod. Repository juga menulis L1 (`CacheClass.dictionaryDetail`)
  /// supaya cold start / kill process masih bisa HIT dalam TTL.
  /// Pull-to-refresh: hard miss L1 (`forceRefresh: true`) lalu invalidate.

  WordDetailProvider call(String wordIdOrLemma) =>
      WordDetailProvider._(argument: wordIdOrLemma, from: this);

  @override
  String toString() => r'wordDetailProvider';
}
