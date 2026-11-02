import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';

import '../pages/mic_permission_onboarding_page.dart';

/// Pastikan izin mikrofon siap sebelum membuka sheet rekam.
///
/// - Sudah granted → `true` (langsung rekam)
/// - Belum → halaman onboarding edukasi → dialog sistem → `true`/`false`
Future<bool> ensureMicrophoneReady(BuildContext context) async {
  final status = await Permission.microphone.status;
  if (status.isGranted) return true;
  if (!context.mounted) return false;

  final granted = await Navigator.of(context, rootNavigator: true).push<bool>(
    MaterialPageRoute<bool>(
      fullscreenDialog: true,
      builder: (_) => const MicPermissionOnboardingPage(),
    ),
  );

  return granted == true;
}
