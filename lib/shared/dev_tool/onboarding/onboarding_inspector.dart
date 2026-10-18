import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../core/router/app_router.dart';
import '../../../features/onboarding/data/onboarding_prefs.dart';
import '../../../features/onboarding/onboarding_router.dart';
import '../dev_tool_inspector.dart';

class OnboardingInspector extends DevToolInspector {
  @override
  Color get color => const Color(0xFF2563EB);

  @override
  String get description => 'Reset flag dan buka ulang onboarding';

  @override
  IconData get icon => FLucideIcons.clapperboard;

  @override
  String get name => 'Onboarding';

  @override
  Widget buildPage(BuildContext context) => const _OnboardingDevPage();
}

class _OnboardingDevPage extends StatelessWidget {
  const _OnboardingDevPage();

  Future<void> _replay() async {
    await OnboardingPrefs.reset();
    AppRouter.rootNavigatorKey.currentState?.pop();
    AppRouter.router.go(OnboardingRouter.onboarding.path);
  }

  @override
  Widget build(BuildContext context) {
    final done = OnboardingPrefs.done;

    // Tanpa horizontal - childPad FScaffold DevTool sudah pad.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          done ? 'Status: selesai' : 'Status: belum selesai',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        const Gap(8),
        Text(
          'Mengulang menulis flag onboarding menjadi belum selesai, lalu membuka halaman onboarding.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
        const Gap(20),
        FButton(
          onPress: _replay,
          child: const Text('Ulangi onboarding'),
        ),
      ],
    );
  }
}
