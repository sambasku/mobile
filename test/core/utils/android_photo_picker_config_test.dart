import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:sambasku_mobile/core/utils/android_photo_picker_config.dart';

class _FakeOtherImagePickerPlatform extends ImagePickerPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = kAndroidPhotoPickerChannel;

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('mengaktifkan useAndroidPhotoPicker saat native mendukung (API 33+)', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'isSupported');
          return true;
        });

    final android = ImagePickerAndroid();
    final enabled = await configureAndroidPhotoPicker(platform: android);

    expect(enabled, isTrue);
    expect(android.useAndroidPhotoPicker, isTrue);
  });

  test('menonaktifkan useAndroidPhotoPicker di Android <= 12 (mis. Vivo Y12 Android 11)', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => false);

    final android = ImagePickerAndroid()..useAndroidPhotoPicker = true;
    final enabled = await configureAndroidPhotoPicker(platform: android);

    expect(enabled, isFalse);
    expect(android.useAndroidPhotoPicker, isFalse);
  });

  test('fallback ke false saat MethodChannel error', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(code: 'unavailable');
        });

    final android = ImagePickerAndroid()..useAndroidPhotoPicker = true;
    final enabled = await configureAndroidPhotoPicker(platform: android);

    expect(enabled, isFalse);
    expect(android.useAndroidPhotoPicker, isFalse);
  });

  test('tidak memanggil channel di platform non-Android', () async {
    var called = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          called = true;
          return true;
        });

    final enabled = await configureAndroidPhotoPicker(
      platform: _FakeOtherImagePickerPlatform(),
    );

    expect(enabled, isFalse);
    expect(called, isFalse);
  });
}
