import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/models/api_response.dart';
import 'package:sambasku_mobile/features/dictionary/data/datasources/dictionary_remote_datasource.dart';
import 'package:sambasku_mobile/features/dictionary/data/models/word_detail_dto.dart';
import 'package:sambasku_mobile/features/dictionary/data/repositories/dictionary_repository_impl.dart';

class _FakeRemoteDatasource implements DictionaryRemoteDatasource {
  _FakeRemoteDatasource(this._detail);

  final WordDetailDto _detail;

  @override
  Future<ApiResponse<WordDetailDto>> getWordById(String id) async =>
      ApiResponse<WordDetailDto>(success: true, data: _detail);

  @override
  Future<ApiResponse<WordDetailDto>> getWordByLemma(String lemma) async =>
      ApiResponse<WordDetailDto>(success: true, data: _detail);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

WordDetailDto _sampleDetail() => const WordDetailDto(
  id: '01TESTWORD0000000000000001',
  lemma: 'kete',
  languageId: '01LANGSMB00000000000000001',
  wordType: 'base',
  status: 'published',
  isVerified: true,
  meanings: [
    MeaningDto(
      id: 'm-verified',
      definition: 'makna lama',
      orderIndex: 0,
      isVerified: true,
    ),
    MeaningDto(
      id: 'm-unverified',
      definition: 'makna menunggu',
      orderIndex: 1,
      isVerified: false,
    ),
  ],
);

void main() {
  group('DictionaryRepositoryImpl meaning visibility (#351)', () {
    test('verifikator tetap menerima makna unverified dari remote', () async {
      final repo = DictionaryRepositoryImpl(
        _FakeRemoteDatasource(_sampleDetail()),
        isVerifier: () => true,
      );

      final result = await repo.getWordById('01TESTWORD0000000000000001');
      final detail = result.getOrElse((l) => fail(l.message));

      expect(detail.meanings.map((m) => m.id).toList(), [
        'm-verified',
        'm-unverified',
      ]);
    });

    test('publik non-verifikator tetap menyaring makna unverified', () async {
      final repo = DictionaryRepositoryImpl(
        _FakeRemoteDatasource(_sampleDetail()),
        isVerifier: () => false,
      );

      final result = await repo.getWordById('01TESTWORD0000000000000001');
      final detail = result.getOrElse((l) => fail(l.message));

      expect(detail.meanings.map((m) => m.id).toList(), ['m-verified']);
    });
  });
}
