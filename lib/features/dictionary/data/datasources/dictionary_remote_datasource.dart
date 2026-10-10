import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/models/api_response.dart';
import '../models/word_detail_dto.dart';
import '../models/word_summary_dto.dart';

part 'dictionary_remote_datasource.g.dart';

@RestApi()
abstract interface class DictionaryRemoteDatasource {
  factory DictionaryRemoteDatasource(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _DictionaryRemoteDatasource;

  /// Pencarian kata - cursor-based (?q=&limit=&cursor=&search_in=).
  /// Endpoint publik tanpa auth.
  @GET('/api/v1/words/search')
  Future<ApiResponse<List<WordSummaryDto>>> searchWords(
    @Queries() Map<String, dynamic> query,
  );

  /// Daftar semua kata A-Z (GET /api/v1/words, 18-api-list-words.md) -
  /// browsing, BUKAN pencarian. Cursor komposit opaque; q = filter
  /// server-side. Publik tanpa auth.
  @GET('/api/v1/words')
  Future<ApiResponse<List<WordSummaryDto>>> listWords(
    @Queries() Map<String, dynamic> query,
  );

  /// Feed beranda (GET /api/v1/words/latest) - published, urut
  /// waktu persetujuan. Publik tanpa auth.
  @GET('/api/v1/words/latest')
  Future<ApiResponse<List<WordSummaryDto>>> listLatestWords(
    @Queries() Map<String, dynamic> query,
  );

  /// Detail kata lengkap (makna, terjemahan, relasi, dll). Publik.
  @GET('/api/v1/words/{id}')
  Future<ApiResponse<WordDetailDto>> getWordById(@Path('id') String id);

  /// Detail by lemma (deep link / URL web publik). Publik.
  @GET('/api/v1/words/lemma/{lemma}')
  Future<ApiResponse<WordDetailDto>> getWordByLemma(
    @Path('lemma') String lemma,
  );

  /// Kata hari ini (28-api-word-of-the-day.md). Publik. data null = korpus kosong.
  @GET('/api/v1/words/today')
  Future<ApiResponse<WordDetailDto>> getWordOfDay();

  /// Daftar kategori/glosarium (GET /api/v1/categories) untuk filter
  /// browse A-Z (#50). Publik tanpa auth.
  @GET('/api/v1/categories')
  Future<ApiResponse<List<CategoryDto>>> listCategories();
}
