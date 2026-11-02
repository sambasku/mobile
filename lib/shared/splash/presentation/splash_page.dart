import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/brand_logo.dart';
import '../../../flavors.dart';

/// Cek sesi singkat lalu arahkan ke HOME.
/// Login opsional (via tab Profil / route /login) - pencarian publik
/// tidak butuh auth.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      childPad: true,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandLogo(size: 160),
            const Gap(16),
            Text(
              F.title,
              style: context.theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(32),
            const FCircularProgress(),
          ],
        ),
      ),
    );
  }
}
