import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/cache/cache_entry.dart';
import '../../../../core/cache/cache_key.dart';
import '../../../../core/cache/cached_json_client.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/models/image_attribution.dart';
import '../../domain/entities/word_detail.dart';
import '../../domain/entities/word_of_day.dart';
import '../../domain/entities/word_summary.dart';
import '../../domain/failures/dictionary_failure.dart';
import '../../domain/repositories/dictionary_repository.dart';
import '../datasources/dictionary_remote_datasource.dart';
import '../models/word_audio_dto.dart';
import '../models/word_detail_dto.dart';
import '../models/word_summary_dto.dart';

class DictionaryRepositoryImpl implements DictionaryRepository {
  DictionaryRepositoryImpl(
    this._remoteDatasource, {
    Dio? dio,
    CachedJsonClient? cache,
  }) : _dio = dio,
       _cache = cache;

  final DictionaryRemoteDatasource _remoteDatasource;
  final Dio? _dio;
  final CachedJsonClient? _cache;

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> searchWords({
    required String query,
    required int limit,
    String? cursor,
    String searchIn = 'lemma',
  }) async {
    try {
      final response = await _remoteDatasource.searchWords({
        'q': query,
        'limit': limit,
        'cursor': ?cursor,
        'search_in': searchIn,
      });

      if (response.success == false) {
        return Either.left(
          DictionaryFailure(
            response.message ?? 'Pencarian gagal',
            errorCode: response.errorCode,
          ),
        );
      }

      final items = response.data;
      if (items == null) {
        return Either.left(
          DictionaryFailure(
            response.message ?? 'Pencarian gagal',
            errorCode: response.errorCode,
          ),
        );
      }

      final meta = response.meta;
      return Either.right(
        WordSearchPage(
          items: items
              .map(
                (dto) => WordSummary(
                  id: dto.id,
                  lemma: dto.lemma,
                  languageCode: dto.languageCode,
                  wordType: dto.wordType,
                  status: dto.status,
                  isVerified: dto.isVerified,
                  matchedTranslation: dto.matchedTranslation,
                  sense: dto.sense,
                  usageLabels: List<String>.from(dto.usageLabels),
                ),
              )
              .toList(),
          nextCursor: meta?['next_cursor'] as String?,
          hasMore: meta?['has_more'] as bool? ?? false,
        ),
      );
    } on DioException catch (error) {
      return Either.left(
        _mapDio(error, fallback: 'Pencarian gagal, periksa koneksi'),
      );
    } catch (error) {
      return Either.left(DictionaryFailure(error.toString()));
    }
  }

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> listWords({
    required String q,
    required int limit,
    String? cursor,
    String? letter,
    bool? isVerified,
    String? category,
  }) async {
    try {
      final response = await _remoteDatasource.listWords({
        'q': q,
        'limit': limit,
        'cursor': ?cursor,
        'letter': ?letter,
        'is_verified': ?isVerified,
        'category': ?category,
      });

      if (response.success == false) {
        return Either.left(
          DictionaryFailure(
            response.message ?? 'Daftar kata gagal dimuat',
            errorCode: response.errorCode,
          ),
        );
      }

      final items = response.data;
      if (items == null) {
        return Either.left(
          DictionaryFailure(
            response.message ?? 'Daftar kata gagal dimuat',
            errorCode: response.errorCode,
          ),
        );
      }

      final meta = response.meta;
      return Either.right(
        WordSearchPage(
          items: items
              .map(
                (dto) => WordSummary(
                  id: dto.id,
                  lemma: dto.lemma,
                  languageCode: dto.languageCode,
                  wordType: dto.wordType,
                  status: dto.status,
                  isVerified: dto.isVerified,
                  sense: dto.sense,
                  usageLabels: List<String>.from(dto.usageLabels),
                ),
              )
              .toList(),
          nextCursor: meta?['next_cursor'] as String?,
          hasMore: meta?['has_more'] as bool? ?? false,
        ),
      );
    } on DioException catch (error) {
      return Either.left(
        _mapDio(error, fallback: 'Daftar kata gagal dimuat, periksa koneksi'),
      );
    } catch (error) {
      return Either.left(DictionaryFailure(error.toString()));
    }
  }

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> listLatest({
    required int limit,
    String? cursor,
    bool forceRefresh = false,
  }) async {
    try {
      final query = <String, dynamic>{
        'limit': limit,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      };
      final cache = _cache;
      final dio = _dio;
      late final ApiResponse<List<WordSummaryDto>> response;
      if (cache != null && dio != null) {
        final key = buildCacheKey(
          method: 'GET',
          path: '/api/v1/words/latest',
          query: query,
        );
        // Halaman dengan cursor: TTL feed, tapi hard miss hanya page-1
        // lewat forceRefresh.
        final envelope = await cache.getOrFetch(
          key: key,
          cacheClass: CacheClass.feedList,
          forceRefresh: forceRefresh && (cursor == null || cursor.isEmpty),
          fetch: () async {
            final resp = await dio.get<dynamic>(
              '/api/v1/words/latest',
              queryParameters: query,
            );
            final body = resp.data;
            if (body is! Map) {
              throw StateError('Envelope latest tidak valid');
            }
            return Map<String, dynamic>.from(body);
          },
        );
        response = ApiResponse<List<WordSummaryDto>>.fromJson(
          envelope,
          (Object? j) {
            if (j is! List) return <WordSummaryDto>[];
            return j
                .whereType<Map>()
                .map(
                  (e) => WordSummaryDto.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList();
          },
        );
      } else {
        response = await _remoteDatasource.listLatestWords(query);
      }

      if (response.success == false) {
        return Either.left(
          DictionaryFailure(
            response.message ?? 'Feed gagal dimuat',
            errorCode: response.errorCode,
          ),
        );
      }

      final items = response.data;
      if (items == null) {
        return Either.left(
          DictionaryFailure(
            response.message ?? 'Feed gagal dimuat',
            errorCode: response.errorCode,
          ),
        );
      }

      final meta = response.meta;
      return Either.right(
        WordSearchPage(
          items: items
              .map(
                (dto) => WordSummary(
                  id: dto.id,
                  lemma: dto.lemma,
                  languageCode: dto.languageCode,
                  wordType: dto.wordType,
                  status: dto.status,
                  isVerified: dto.isVerified,
                  sense: dto.sense,
                  approvedAt: dto.approvedAt == null
                      ? null
                      : DateTime.tryParse(dto.approvedAt!),
                  usageLabels: List<String>.from(dto.usageLabels),
                ),
              )
              .toList(),
          nextCursor: meta?['next_cursor'] as String?,
          hasMore: meta?['has_more'] as bool? ?? false,
        ),
      );
    } on DioException catch (error) {
      return Either.left(
        _mapDio(error, fallback: 'Feed gagal dimuat, periksa koneksi'),
      );
    } catch (error) {
      return Either.left(DictionaryFailure(error.toString()));
    }
  }

  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordById(
    String id, {
    bool forceRefresh = false,
  }) async {
    try {
      final cache = _cache;
      final dio = _dio;
      WordDetailDto? dto;
      String? errorMessage;
      String? errorCode;
      var success = true;

      if (cache != null && dio != null) {
        final key = buildCacheKey(
          method: 'GET',
          path: '/api/v1/words/$id',
        );
        final envelope = await cache.getOrFetch(
          key: key,
          cacheClass: CacheClass.dictionaryDetail,
          forceRefresh: forceRefresh,
          fetch: () async {
            final resp = await dio.get<dynamic>('/api/v1/words/$id');
            final body = resp.data;
            if (body is! Map) {
              throw StateError('Envelope detail kata tidak valid');
            }
            return Map<String, dynamic>.from(body);
          },
        );
        success = envelope['success'] != false;
        errorMessage = envelope['message'] as String?;
        errorCode = envelope['error_code'] as String?;
        final raw = envelope['data'];
        if (raw is Map) {
          dto = WordDetailDto.fromJson(Map<String, dynamic>.from(raw));
        }
      } else {
        final response = await _remoteDatasource.getWordById(id);
        success = response.success != false;
        errorMessage = response.message;
        errorCode = response.errorCode;
        dto = response.data;
      }

      if (!success) {
        return Either.left(
          DictionaryFailure(
            errorMessage ?? 'Kata tidak ditemukan',
            errorCode: errorCode,
          ),
        );
      }

      if (dto == null) {
        return Either.left(
          DictionaryFailure(
            errorMessage ?? 'Kata tidak ditemukan',
            errorCode: errorCode ?? 'WORD_NOT_FOUND',
          ),
        );
      }

      return Either.right(_mapDetail(dto));
    } on DioException catch (error) {
      return Either.left(
        _mapDio(
          error,
          fallback: 'Gagal memuat detail kata',
          notFoundMessage: 'Kata tidak ditemukan',
        ),
      );
    } catch (error) {
      return Either.left(DictionaryFailure(error.toString()));
    }
  }

  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordByLemma(
    String lemma, {
    bool forceRefresh = false,
  }) async {
    try {
      final encoded = Uri.encodeComponent(lemma);
      final cache = _cache;
      final dio = _dio;
      WordDetailDto? dto;
      String? errorMessage;
      String? errorCode;
      var success = true;

      if (cache != null && dio != null) {
        final key = buildCacheKey(
          method: 'GET',
          path: '/api/v1/words/lemma/$encoded',
        );
        final envelope = await cache.getOrFetch(
          key: key,
          cacheClass: CacheClass.dictionaryDetail,
          forceRefresh: forceRefresh,
          fetch: () async {
            final resp = await dio.get<dynamic>(
              '/api/v1/words/lemma/$encoded',
            );
            final body = resp.data;
            if (body is! Map) {
              throw StateError('Envelope detail lemma tidak valid');
            }
            return Map<String, dynamic>.from(body);
          },
        );
        success = envelope['success'] != false;
        errorMessage = envelope['message'] as String?;
        errorCode = envelope['error_code'] as String?;
        final raw = envelope['data'];
        if (raw is Map) {
          dto = WordDetailDto.fromJson(Map<String, dynamic>.from(raw));
        }
      } else {
        final response = await _remoteDatasource.getWordByLemma(lemma);
        success = response.success != false;
        errorMessage = response.message;
        errorCode = response.errorCode;
        dto = response.data;
      }

      if (!success) {
        return Either.left(
          DictionaryFailure(
            errorMessage ?? 'Kata tidak ditemukan',
            errorCode: errorCode,
          ),
        );
      }

      if (dto == null) {
        return Either.left(
          DictionaryFailure(
            errorMessage ?? 'Kata tidak ditemukan',
            errorCode: errorCode ?? 'WORD_NOT_FOUND',
          ),
        );
      }

      return Either.right(_mapDetail(dto));
    } on DioException catch (error) {
      return Either.left(
        _mapDio(
          error,
          fallback: 'Gagal memuat detail kata',
          notFoundMessage: 'Kata tidak ditemukan',
        ),
      );
    } catch (error) {
      return Either.left(DictionaryFailure(error.toString()));
    }
  }

  @override
  Future<Either<DictionaryFailure, List<WordCategory>>> listCategories() async {
    try {
      final response = await _remoteDatasource.listCategories();

      if (response.success == false) {
        return Either.left(
          DictionaryFailure(
            response.message ?? 'Gagal memuat kategori',
            errorCode: response.errorCode,
          ),
        );
      }

      final items = response.data;
      if (items == null) {
        return Either.left(
          DictionaryFailure(
            response.message ?? 'Gagal memuat kategori',
            errorCode: response.errorCode,
          ),
        );
      }

      return Either.right(
        items
            .map(
              (c) => WordCategory(
                id: c.id,
                name: c.name,
              ),
            )
            .toList(),
      );
    } on DioException catch (e) {
      return Either.left(
        DictionaryFailure(
          e.message ?? 'Gagal memuat kategori',
          errorCode: e.response?.data?['error_code'] as String?,
        ),
      );
    }
  }

  @override
  Future<Either<DictionaryFailure, WordOfDay?>> getWordOfDay({
    bool forceRefresh = false,
  }) async {
    try {
      final cache = _cache;
      final dio = _dio;
      WordDetailDto? dto;
      String? errorMessage;
      String? errorCode;
      var success = true;

      if (cache != null && dio != null) {
        final key = buildCacheKey(method: 'GET', path: '/api/v1/words/today');
        final envelope = await cache.getOrFetch(
          key: key,
          cacheClass: CacheClass.wordOfDay,
          forceRefresh: forceRefresh,
          fetch: () async {
            final resp = await dio.get<dynamic>('/api/v1/words/today');
            final body = resp.data;
            if (body is! Map) {
              throw StateError('Envelope word-of-day tidak valid');
            }
            return Map<String, dynamic>.from(body);
          },
        );
        success = envelope['success'] != false;
        errorMessage = envelope['message'] as String?;
        errorCode = envelope['error_code'] as String?;
        final raw = envelope['data'];
        if (raw is Map) {
          dto = WordDetailDto.fromJson(Map<String, dynamic>.from(raw));
        }
      } else {
        final response = await _remoteDatasource.getWordOfDay();
        success = response.success != false;
        errorMessage = response.message;
        errorCode = response.errorCode;
        dto = response.data;
      }

      if (!success) {
        return Either.left(
          DictionaryFailure(
            errorMessage ?? 'Gagal memuat kata hari ini',
            errorCode: errorCode,
          ),
        );
      }

      if (dto == null) return Either.right(null);

      return Either.right(
        WordOfDay(
          word: _mapDetail(dto),
          date: dto.date ?? '',
          isNewThisWeek: dto.isNewThisWeek,
        ),
      );
    } on DioException catch (error) {
      return Either.left(
        _mapDio(error, fallback: 'Gagal memuat kata hari ini'),
      );
    } catch (error) {
      return Either.left(DictionaryFailure(error.toString()));
    }
  }

  WordDetail _mapDetail(WordDetailDto dto) => WordDetail(
    id: dto.id,
    lemma: dto.lemma,
    languageId: dto.languageId,
    notes: dto.notes,
    wordType: dto.wordType,
    status: dto.status,
    isVerified: dto.isVerified,
    isCorrected: dto.isCorrected,
    selfVerified: dto.selfVerified,
    verifiedAt: dto.verifiedAt,
    verifiedBy: dto.verifiedBy == null
        ? null
        : WordVerifier(
            username: dto.verifiedBy!.username,
            displayName:
                (dto.verifiedBy!.displayName?.trim().isNotEmpty == true)
                    ? dto.verifiedBy!.displayName!.trim()
                    : dto.verifiedBy!.username,
            role: dto.verifiedBy!.role,
          ),
    createdBy: dto.createdBy == null
        ? null
        : WordVerifier(
            username: dto.createdBy!.username,
            displayName:
                (dto.createdBy!.displayName?.trim().isNotEmpty == true)
                    ? dto.createdBy!.displayName!.trim()
                    : dto.createdBy!.username,
            role: dto.createdBy!.role,
          ),
    meanings: dto.meanings
        .map(
          (m) => WordMeaning(
            id: m.id,
            wordClassId: m.wordClass?.id,
            wordClassCode: m.wordClass?.code,
            // ponytail: format di mapper biar UI cukup pakai wordClassName
            wordClassName: m.wordClass == null
                ? null
                : (m.wordClass!.alias == null || m.wordClass!.alias!.isEmpty)
                ? m.wordClass!.name
                : '${m.wordClass!.name} (${m.wordClass!.alias})',
            definition: m.definition,
            orderIndex: m.orderIndex,
            translations: m.translations
                .map(
                  (t) => WordTranslation(
                    text: t.translationText,
                    type: t.translationType,
                    languageId: t.languageId,
                  ),
                )
                .toList(),
            examples: m.examples
                .map(
                  (e) => WordExample(
                    id: e.id,
                    sourceSentence: e.sourceSentence,
                    targetSentence: e.targetSentence,
                    audios: e.audios.map(_mapAudio).toList(),
                  ),
                )
                .toList(),
          ),
        )
        .toList(),
    categories: dto.categories
        .map((c) => WordCategory(id: c.id, name: c.name))
        .toList(),
    usageLabels: List<String>.from(dto.usageLabels),
    pronunciations: dto.pronunciations
        .map((p) => WordPronunciation(notation: p.notation, value: p.value))
        .toList(),
    audios: sortWordAudios(dto.audios.map(_mapAudio).toList()),
    images: dto.images
        .map(
          (i) => WordImage(
            id: i.id,
            url: i.url,
            altText: i.altText,
            isPrimary: i.isPrimary,
            isVerified: i.isVerified,
            contentWarnings: List<String>.from(i.contentWarnings),
            attribution: ImageAttribution.fromJson(i.attribution),
          ),
        )
        .toList(),
    relatedWords: dto.relatedWords
        .map(
          (r) => RelatedWord(
            wordId: r.wordId,
            lemma: r.lemma,
            relationType: r.relationType,
          ),
        )
        .toList(),
    appearsIn: dto.appearsIn
        .map(
          (r) => RelatedWord(
            wordId: r.wordId,
            lemma: r.lemma,
            relationType: r.relationType,
          ),
        )
        .toList(),
    variants: dto.variants
        .map(
          (v) => WordVariant(
            form: v.form,
            variantType: v.variantType,
            affixType: v.affixType,
            affixValue: v.affixValue,
            notes: v.notes,
          ),
        )
        .toList(),
  );

  WordAudio _mapAudio(WordAudioDto dto) => WordAudio(
    id: dto.id,
    url: dto.url,
    dialectId: dto.dialectId,
    speakerName: dto.speakerName,
    durationMs: dto.durationMs,
    isPrimary: dto.isPrimary,
    mimeType: dto.mimeType,
    isVerified: dto.isVerified,
  );

  DictionaryFailure _mapDio(
    DioException error, {
    required String fallback,
    String? notFoundMessage,
  }) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final code = data['error_code'] as String?;
      final message = data['message'];
      if (error.response?.statusCode == 404) {
        return DictionaryFailure(
          message is String && message.isNotEmpty
              ? message
              : (notFoundMessage ?? 'Tidak ditemukan'),
          errorCode: code ?? 'WORD_NOT_FOUND',
        );
      }
      if (message is String && message.isNotEmpty) {
        return DictionaryFailure(message, errorCode: code);
      }
    }
    return DictionaryFailure(fallback);
  }
}
