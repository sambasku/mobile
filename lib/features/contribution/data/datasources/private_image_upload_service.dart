import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/failures/contribution_failure.dart';
import '../datasources/image_remote_datasource.dart';
import '../datasources/imagekit_uploader.dart';
import '../models/create_word_image_dto.dart';
import '../../../../core/i18n/l10n.dart';

/// Upload bukti ImageKit (folder privat). Dipakai pengajuan verifikator.
/// Gambar kata kontributor: [WordImageUploadService] → ImageKit `/words`.
class PrivateImageUploadService {
  PrivateImageUploadService(this._remote, this._uploader);

  final ImageRemoteDatasource _remote;
  final ImageKitUploader _uploader;

  Future<Either<ContributionFailure, CreateWordImageDto>> uploadFile(
    File file, {
    required String folder,
    bool isPrimary = false,
    String? altText,
  }) async {
    try {
      final tokenRes = await _remote.getUploadToken(folder: folder);
      if (tokenRes.success == false || tokenRes.data == null) {
        return Either.left(
          ContributionFailure(
            tokenRes.message ?? l10n.contributeUploadTokenFailed,
            errorCode: tokenRes.errorCode,
          ),
        );
      }

      final uploaded = await _uploader.upload(
        file: file,
        creds: tokenRes.data!,
        folder: folder,
      );

      return Either.right(
        CreateWordImageDto(
          url: uploaded.url,
          providerFileId: uploaded.fileId,
          altText: altText,
          isPrimary: isPrimary,
        ),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final code = data['error_code'] as String?;
        final message = data['message'];
        if (code == 'IMAGE_UPLOAD_UNAVAILABLE' ||
            e.response?.statusCode == 503) {
          return Either.left(
            ContributionFailure(
              message is String && message.isNotEmpty
                  ? message
                  : l10n.contributeStorageUnavailable,
              errorCode: 'IMAGE_UPLOAD_UNAVAILABLE',
            ),
          );
        }
        if (message is String && message.isNotEmpty) {
          return Either.left(ContributionFailure(message, errorCode: code));
        }
      }
      return Either.left(
        ContributionFailure(l10n.contributeImageUploadFailed),
      );
    } catch (_) {
      return Either.left(
        ContributionFailure(l10n.contributeImageUploadFailed),
      );
    }
  }
}
