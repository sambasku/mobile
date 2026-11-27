import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

const MethodChannel kAndroidPhotoPickerChannel = MethodChannel(
  'sambasku/android_photo_picker',
);

/// Mengaktifkan Android Photo Picker hanya di perangkat Android 13+ yang
/// memiliki handler native `ACTION_PICK_IMAGES` (issue mobile#385).
///
/// Pada Android <= 12 (termasuk Vivo Y12 Funtouch OS / Android 11),
/// `useAndroidPhotoPicker` dibiarkan `false` agar `image_picker_android`
/// memakai `ACTION_GET_CONTENT` (tetap tanpa izin `READ_MEDIA_*`).
Future<bool> configureAndroidPhotoPicker({
  ImagePickerPlatform? platform,
  MethodChannel channel = kAndroidPhotoPickerChannel,
}) async {
  final impl = platform ?? ImagePickerPlatform.instance;
  if (impl is! ImagePickerAndroid) return false;

  var supported = false;
  try {
    supported = await channel.invokeMethod<bool>('isSupported') ?? false;
  } catch (e) {
    debugPrint(
      '[PhotoPicker] cek dukungan gagal, fallback ACTION_GET_CONTENT: $e',
    );
    supported = false;
  }
  impl.useAndroidPhotoPicker = supported;
  return supported;
}
