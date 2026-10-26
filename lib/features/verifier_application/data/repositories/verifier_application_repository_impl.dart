import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/models/api_response.dart';
import '../../domain/entities/verifier_application.dart';
import '../../domain/failures/verifier_application_failure.dart';
import '../../domain/repositories/verifier_application_repository.dart';
import '../datasources/verifier_application_remote_datasource.dart';
import '../models/verifier_application_dto.dart';

class VerifierApplicationRepositoryImpl
    implements VerifierApplicationRepository {
  VerifierApplicationRepositoryImpl(this._remote);

  final VerifierApplicationRemoteDatasource _remote;

  @override
  Future<Either<VerifierApplicationFailure, VerifierApplication?>>
  getMine() async {
    try {
      final response = await _remote.getMine();
      if (response.success == false || response.data == null) {
        if (response.errorCode == 'VERIFIER_APPLICATION_NOT_FOUND') {
          return Either.right(null);
        }
        return Either.left(
          VerifierApplicationFailure(
            response.message ?? 'Gagal memuat pengajuan',
            errorCode: response.errorCode,
          ),
        );
      }
      return Either.right(_map(response.data!));
    } on DioException catch (error) {
      final failure = _mapDio(error);
      if (failure.isNotFound) return Either.right(null);
      return Either.left(failure);
    } catch (error) {
      return Either.left(VerifierApplicationFailure(error.toString()));
    }
  }

  @override
  Future<Either<VerifierApplicationFailure, VerifierApplication>> submit({
    required String phone,
    required String address,
    required List<SocialLink> socialLinks,
  }) {
    return _mutate(
      () => _remote.submit(_toRequest(phone, address, socialLinks)),
    );
  }

  @override
  Future<Either<VerifierApplicationFailure, VerifierApplication>> resubmit({
    required String phone,
    required String address,
    required List<SocialLink> socialLinks,
  }) {
    return _mutate(
      () => _remote.resubmit(_toRequest(phone, address, socialLinks)),
    );
  }

  Future<Either<VerifierApplicationFailure, VerifierApplication>> _mutate(
    Future<ApiResponse<VerifierApplicationDto>> Function() call,
  ) async {
    try {
      final response = await call();
      if (response.success == false || response.data == null) {
        return Either.left(
          VerifierApplicationFailure(
            response.message ?? 'Gagal mengirim pengajuan',
            errorCode: response.errorCode,
          ),
        );
      }
      return Either.right(_map(response.data!));
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(VerifierApplicationFailure(error.toString()));
    }
  }

  SubmitVerifierApplicationRequestDto _toRequest(
    String phone,
    String address,
    List<SocialLink> socialLinks,
  ) => SubmitVerifierApplicationRequestDto(
    phone: phone,
    address: address,
    socialLinks: socialLinks
        .map(
          (l) => SocialLinkDto(
            platform: l.platform,
            username: l.username,
            screenshot: SocialScreenshotDto(
              url: l.screenshot.url,
              providerFileId: l.screenshot.providerFileId,
            ),
          ),
        )
        .toList(),
  );

  VerifierApplication _map(VerifierApplicationDto dto) => VerifierApplication(
    id: dto.id,
    status: dto.status,
    phone: dto.phone,
    address: dto.address,
    socialLinks: dto.socialLinks
        .map(
          (l) => SocialLink(
            platform: l.platform,
            username: l.username,
            screenshot: SocialScreenshot(
              url: l.screenshot.url,
              providerFileId: l.screenshot.providerFileId,
            ),
          ),
        )
        .toList(),
    adminComment: dto.adminComment,
    reviewedAt: dto.reviewedAt,
    createdAt: dto.createdAt,
    updatedAt: dto.updatedAt,
  );

  VerifierApplicationFailure _mapDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final code = data['error_code'] as String?;
      final message = data['message'];
      if (code == 'VERIFIER_APPLICATION_NOT_FOUND') {
        return VerifierApplicationFailure(
          'Pengajuan verifikator tidak ditemukan',
          errorCode: code,
        );
      }
      if (message is String && message.isNotEmpty) {
        return VerifierApplicationFailure(message, errorCode: code);
      }
      return VerifierApplicationFailure(
        _fallback(error.response?.statusCode, code),
        errorCode: code,
      );
    }
    return VerifierApplicationFailure(
      _fallback(error.response?.statusCode, null),
    );
  }

  String _fallback(int? statusCode, String? errorCode) {
    if (statusCode == 429 || errorCode == 'RATE_LIMITED') {
      return 'Terlalu banyak permintaan. Coba lagi dalam beberapa saat.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server sedang gangguan. Coba lagi dalam beberapa saat.';
    }
    return 'Terjadi kesalahan, coba lagi';
  }
}
