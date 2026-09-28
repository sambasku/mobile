import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../contribution/data/datasources/imagekit_uploader.dart';
import '../../contribution/data/models/upload_credentials_dto.dart';
import '../domain/discussion_models.dart';
import 'discussion_repository.dart';

/// Token `/discussions` → upload CDN. Reuse ImageKitUploader kontribusi.
class DiscussionImageUploadService {
  DiscussionImageUploadService(this._repo, {ImageKitUploader? uploader})
    : _uploader = uploader ?? ImageKitUploader();

  final DiscussionRepository _repo;
  final ImageKitUploader _uploader;

  Future<DiscussionImageRef> upload(File file) async {
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
      folder: '/discussions',
    );
    return DiscussionImageRef(
      url: uploaded.url,
      providerFileId: uploaded.fileId,
    );
  }

  Future<DiscussionImageRef> uploadXFile(XFile file) =>
      upload(File(file.path));
}
