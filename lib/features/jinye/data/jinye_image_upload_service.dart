import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../contribution/data/datasources/imagekit_uploader.dart';
import '../../contribution/data/models/upload_credentials_dto.dart';
import '../domain/jinye_models.dart';
import 'jinye_repository.dart';

/// Token `/jinye` → upload CDN. Reuse ImageKitUploader kontribusi.
class JinyeImageUploadService {
  JinyeImageUploadService(this._repo, {ImageKitUploader? uploader})
      : _uploader = uploader ?? ImageKitUploader();

  final JinyeRepository _repo;
  final ImageKitUploader _uploader;

  Future<JinyeImageRef> upload(File file) async {
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
      folder: '/jinye',
    );
    return JinyeImageRef(
      url: uploaded.url,
      providerFileId: uploaded.fileId,
    );
  }

  Future<JinyeImageRef> uploadXFile(XFile file) => upload(File(file.path));
}
