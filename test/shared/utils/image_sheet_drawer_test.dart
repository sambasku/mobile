import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';
import 'package:sambasku_mobile/shared/utils/image_sheet_drawer.dart';

class _ThrowingImagePicker extends ImagePicker {
  _ThrowingImagePicker(this.error);

  final Object error;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    throw error;
  }
}

void main() {
  Widget wrapApp(Widget child) {
    final fTheme = foruiPalettes[defaultPalette]!.light.touch;
    return MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        ...FLocalizations.localizationsDelegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: fTheme.toApproximateMaterialTheme(),
      builder: (context, appChild) => FTheme(
        data: fTheme,
        child: FToaster(child: appChild ?? const SizedBox.shrink()),
      ),
      home: FScaffold(child: child),
    );
  }

  testWidgets('pickImageFromGallery fallback ke FilePicker saat PlatformException', (
    tester,
  ) async {
    final fallbackFile = File('/tmp/sample_fallback.jpg');
    XFile? picked;
    final picker = _ThrowingImagePicker(
      PlatformException(code: 'activity_not_found', message: 'No photo picker'),
    );

    await tester.pumpWidget(
      wrapApp(
        Builder(
          builder: (context) => Center(
            child: FButton(
              onPress: () {
                showModalBottomSheet<void>(
                  context: context,
                  useRootNavigator: true,
                  builder: (sheetContext) => FButton(
                    onPress: () => pickImageFromGallery(
                      sheetContext,
                      picker,
                      (file) => picked = file,
                      fallbackFilePicker: () async => fallbackFile,
                      processFile: (file) async => file,
                    ),
                    child: const Text('Galeri'),
                  ),
                );
              },
              child: const Text('Buka'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Galeri'));
    await tester.pumpAndSettle();

    expect(picked?.path, fallbackFile.path);
    expect(find.text('Galeri'), findsNothing);
  });

  testWidgets('pickImageFromGallery tampilkan FToast saat picker dan fallback gagal', (
    tester,
  ) async {
    final picker = _ThrowingImagePicker(
      PlatformException(code: 'activity_not_found', message: 'No photo picker'),
    );

    await tester.pumpWidget(
      wrapApp(
        Builder(
          builder: (context) => Center(
            child: FButton(
              onPress: () => pickImageFromGallery(
                context,
                picker,
                (_) {},
                fallbackFilePicker: () async =>
                    throw StateError('fallback failed'),
                processFile: (file) async => file,
              ),
              child: const Text('Galeri'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Galeri'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Gagal memilih dari galeri'), findsOneWidget);
  });

  testWidgets('pickImageFromGallery tidak fallback saat already_active (double-tap)', (
    tester,
  ) async {
    var fallbackCalled = false;
    final picker = _ThrowingImagePicker(
      PlatformException(code: 'already_active', message: 'Already active'),
    );

    await tester.pumpWidget(
      wrapApp(
        Builder(
          builder: (context) => Center(
            child: FButton(
              onPress: () => pickImageFromGallery(
                context,
                picker,
                (_) {},
                fallbackFilePicker: () async {
                  fallbackCalled = true;
                  return File('/tmp/should_not_run.jpg');
                },
                processFile: (file) async => file,
              ),
              child: const Text('Galeri'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Galeri'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(fallbackCalled, isFalse);
    expect(find.text('Gagal memilih dari galeri'), findsNothing);
  });
}
