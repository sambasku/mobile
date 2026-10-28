import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Label versi app di kaki layar (mis. profil, login): `v1.2.3(45)`.
class AppVersionLabel extends StatelessWidget {
  const AppVersionLabel({super.key, required this.future});

  final Future<PackageInfo> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: future,
      builder: (context, snapshot) {
        final info = snapshot.data;
        if (info == null) return const SizedBox.shrink();
        return Center(
          child: Text(
            'v${info.version}(${info.buildNumber})',
            style: context.theme.typography.body.xs.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
        );
      },
    );
  }
}
