import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/search_miss.dart';
import '../../domain/failures/search_miss_failure.dart';
import '../../domain/repositories/search_miss_repository.dart';
import '../datasources/search_miss_remote_datasource.dart';
import '../models/search_miss_dto.dart';

class SearchMissRepositoryImpl implements SearchMissRepository {
  SearchMissRepositoryImpl(this._remoteDatasource);

  final SearchMissRemoteDatasource _remoteDatasource;

  @override
  Future<Either<SearchMissFailure, List<SearchMiss>>> listSearchMisses({
    required int limit,
  }) async {
    try {
      final response = await _remoteDatasource.listSearchMisses({
        'limit': limit,
      });

      if (response.success == false) {
        return Either.left(
          SearchMissFailure(
            response.message ?? 'Gagal memuat daftar pencarian populer',
            errorCode: response.errorCode,
          ),
        );
      }

      final data = response.data;
      if (data == null) {
        return Either.left(
          SearchMissFailure(
            response.message ?? 'Gagal memuat daftar pencarian populer',
            errorCode: response.errorCode,
          ),
        );
      }

      // Server sudah filter is_visible=true (14-api). Render apa adanya.
      return Either.right(data.map(_toEntity).toList());
    } on DioException catch (error) {
      return Either.left(
        _mapDio(
          error,
          fallback: 'Gagal memuat. Coba lagi dalam beberapa saat.',
        ),
      );
    } catch (error) {
      return Either.left(SearchMissFailure(error.toString()));
    }
  }

  SearchMiss _toEntity(SearchMissDto dto) => SearchMiss(
    id: dto.id,
    term: dto.term,
    searchIn: dto.searchIn,
    hitCount: dto.hitCount,
    lastSearchedAt: dto.lastSearchedAt,
  );

  SearchMissFailure _mapDio(DioException error, {required String fallback}) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final code = data['error_code'] as String?;
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return SearchMissFailure(message, errorCode: code);
      }
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const SearchMissFailure(
          'Server lama merespons. Coba lagi dalam beberapa saat.',
        );
      case DioExceptionType.connectionError:
        return const SearchMissFailure(
          'Gagal terhubung ke server. Coba lagi dalam beberapa saat.',
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.badResponse:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
      default:
        return SearchMissFailure(fallback);
    }
  }
}
