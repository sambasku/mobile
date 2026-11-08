import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sambasku_mobile/features/dictionary/data/dataset/lemma_data_source_kind.dart';
import 'package:sambasku_mobile/features/dictionary/data/dataset/lemma_hybrid.dart';
import 'package:sambasku_mobile/features/dictionary/data/dataset/lemma_sticky_store.dart';
import 'package:sambasku_mobile/features/dictionary/domain/failures/dictionary_failure.dart';

void main() {
  late LemmaStickyStore sticky;
  late List<LemmaDataSourceKind> sources;

  setUp(() {
    sticky = LemmaStickyStore();
    sources = [];
  });

  LemmaHybridGate gate({bool offline = false}) => LemmaHybridGate(
        sticky: sticky,
        isOffline: () => offline,
        onSource: sources.add,
      );

  test('offline goes local without remote', () async {
    var remoteCalls = 0;
    final result = await gate(offline: true).read(
      budget: const Duration(seconds: 5),
      remote: () async {
        remoteCalls++;
        return Either.right('remote');
      },
      local: () async => 'local',
      localUnavailableMessage: 'no',
    );
    expect(remoteCalls, 0);
    expect(result.match((_) => null, (v) => v), 'local');
    expect(sources, [LemmaDataSourceKind.local]);
  });

  test('timeout falls back to local and sets sticky', () async {
    final result = await gate().read(
      budget: const Duration(milliseconds: 20),
      remote: () async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return Either.right('remote');
      },
      local: () async => 'local',
      localUnavailableMessage: 'no',
    );
    expect(result.match((_) => null, (v) => v), 'local');
    expect(sticky.isActive, isTrue);
  });

  test('WORD_NOT_FOUND does not fallback', () async {
    final result = await gate().read(
      budget: const Duration(seconds: 1),
      remote: () async => Either.left(
        const DictionaryFailure('missing', errorCode: 'WORD_NOT_FOUND'),
      ),
      local: () async => 'local',
      localUnavailableMessage: 'no',
    );
    expect(
      result.match((f) => f.errorCode, (_) => null),
      'WORD_NOT_FOUND',
    );
    expect(sticky.isActive, isFalse);
  });

  test('infra DioException falls back', () async {
    final result = await gate().read(
      budget: const Duration(seconds: 1),
      remote: () async => throw DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionTimeout,
      ),
      local: () async => 'local',
      localUnavailableMessage: 'no',
    );
    expect(result.match((_) => null, (v) => v), 'local');
    expect(sticky.isActive, isTrue);
  });

  test('sticky skips remote', () async {
    sticky.activate();
    var remoteCalls = 0;
    await gate().read(
      budget: const Duration(seconds: 1),
      remote: () async {
        remoteCalls++;
        return Either.right('remote');
      },
      local: () async => 'local',
      localUnavailableMessage: 'no',
    );
    expect(remoteCalls, 0);
  });
}
