import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../contribution/data/datasources/imagekit_uploader.dart';
import '../../contribution/data/models/upload_credentials_dto.dart';
import '../domain/entities/comment_image.dart';
import '../domain/repositories/comment_repository.dart';

/// Token folder `/comments` → upload CDN (ImageKit staging).
class CommentImageUploadService {
  CommentImageUploadService(this._repo, {ImageKitUploader? uploader})
    : _uploader = uploader ?? ImageKitUploader();

  final CommentRepository _repo;
  final ImageKitUploader _uploader;

  Future<CommentImageStaging> upload(File file) async {
    final creds = await _repo.getUploadToken();
    final uploaded = await _uploader.upload(
      file: file,
      creds: UploadCredentialsDto(
        token: creds.token,
        signature: creds.signature,
        expire: creds.expire,
        publicKey: creds.publicKey,
        uploadEndpoint: creds.uploadEndpoint,
      ),
      folder: '/comments',
    );
    return CommentImageStaging(
      url: uploaded.url,
      providerFileId: uploaded.fileId,
    );
  }

  Future<CommentImageStaging> uploadXFile(XFile file) =>
      upload(File(file.path));
}
