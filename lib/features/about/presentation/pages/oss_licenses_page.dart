import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/oss_license.dart';

/// Daftar pustaka sumber terbuka yang ikut terpasang di aplikasi.
class OssLicensesPage extends StatefulWidget {
  const OssLicensesPage({super.key, this.loader});

  static const path = '/about/licenses';

  final Future<List<OssLicense>> Function()? loader;

  @override
  State<OssLicensesPage> createState() => _OssLicensesPageState();
}

class _OssLicensesPageState extends State<OssLicensesPage> {
  late final Future<List<OssLicense>> _future;

  @override
  void initState() {
    super.initState();
    final loader = widget.loader;
    _future = loader != null ? loader() : collectOssLicenses();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.aboutOssListTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/about'),
          ),
        ],
      ),
      child: FutureBuilder<List<OssLicense>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Semantics(
              label: l10n.aboutOssLoading,
              child: const Center(child: FCircularProgress(size: .md)),
            );
          }
          final items = snapshot.data ?? const <OssLicense>[];
          if (items.isEmpty) {
            return Center(
              child: Text(l10n.aboutOssEmpty, textAlign: TextAlign.center),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
            children: [
              FTileGroup(
                children: [
                  for (final item in items)
                    FTile(
                      title: Text(item.name),
                      subtitle: Text(item.kind ?? l10n.aboutOssUnknown),
                      suffix: const Icon(FLucideIcons.chevronRight, size: 16),
                      onPress: () =>
                          context.push(OssLicenseDetailPage.path, extra: item),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Teks lisensi penuh untuk satu pustaka.
class OssLicenseDetailPage extends StatelessWidget {
  const OssLicenseDetailPage({super.key, required this.license});

  static const path = '/about/licenses/detail';

  final OssLicense? license;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final item = license;
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(item?.name ?? l10n.aboutOssListTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go(OssLicensesPage.path),
          ),
        ],
      ),
      child: item == null
          ? Center(child: Text(l10n.aboutOssEmpty))
          : ListView(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
              children: [
                Text(
                  item.kind ?? l10n.aboutOssUnknown,
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colors.foreground,
                  ),
                ),
                const Gap(12),
                SelectableText(
                  item.text,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                    height: 1.4,
                  ),
                ),
              ],
            ),
    );
  }
}
