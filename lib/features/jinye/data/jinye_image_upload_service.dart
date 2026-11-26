import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../domain/jinye_models.dart';
import 'jinye_repository.dart';

/// Unggah foto Jinye ke repo GitHub lewat API (bukan direct-upload ImageKit).
class JinyeImageUploadService {
  JinyeImageUploadService(this._repo);

  final JinyeRepository _repo;

  Future<JinyeImageRef> upload(File file) => _repo.uploadImage(file);

  Future<JinyeImageRef> uploadXFile(XFile file) => upload(File(file.path));
}
