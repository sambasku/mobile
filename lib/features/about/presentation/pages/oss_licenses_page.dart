import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/tile_group_list.dart';
import '../../domain/oss_direct_packages.dart';
import '../../domain/oss_license.dart';

/// Daftar pustaka sumber terbuka yang ikut terpasang di aplikasi.
///
/// Nama diambil langsung dari pubspec (sync). Teks lisensi baru diload
/// saat detail dibuka, supaya daftar tidak menunggu LicenseRegistry.
/// List memakai [TileGroupList] seperti inbox notifikasi (kartu + divider
/// Forui seragam).
class OssLicensesPage extends StatefulWidget {
  const OssLicensesPage({super.key, this.packageNames});

  static const path = '/about/licenses';

  /// Override daftar nama (test). Default: [kDirectOssPackages].
  final Set<String>? packageNames;

  @override
  State<OssLicensesPage> createState() => _OssLicensesPageState();
}

class _OssLicensesPageState extends State<OssLicensesPage> {
  late final List<String> _names = directOssPackageNames(
    packageNames: widget.packageNames ?? kDirectOssPackages,
  );

  @override
  void initState() {
    super.initState();
    // Prefetch di background; daftar sudah tampil tanpa menunggu.
    loadOssLicenseMap(packageNames: widget.packageNames ?? kDirectOssPackages);
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
      child: _names.isEmpty
          ? Center(child: Text(l10n.aboutOssEmpty, textAlign: TextAlign.center))
          : TileGroupList<String>(
              items: _names,
              hasMore: false,
              onLoadMore: () async {},
              tileBuilder: (context, name) => _OssPackageTile(name: name),
            ),
    );
  }
}

class _OssPackageTile extends StatelessWidget with FTileMixin {
  const _OssPackageTile({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FTile(
      prefix: const Icon(FLucideIcons.bookOpen),
      title: Text(name),
      subtitle: Text(l10n.aboutOssUnknown),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: () => context.push(
        OssLicenseDetailPage.path,
        extra: OssLicense(name: name, text: ''),
      ),
    );
  }
}

/// Teks lisensi penuh untuk satu pustaka (lazy dari cache / Registry).
class OssLicenseDetailPage extends StatefulWidget {
  const OssLicenseDetailPage({
    super.key,
    required this.license,
    this.packageNames,
  });

  static const path = '/about/licenses/detail';

  final OssLicense? license;
  final Set<String>? packageNames;

  @override
  State<OssLicenseDetailPage> createState() => _OssLicenseDetailPageState();
}

class _OssLicenseDetailPageState extends State<OssLicenseDetailPage> {
  late final Future<OssLicense?> _future;

  @override
  void initState() {
    super.initState();
    final seed = widget.license;
    if (seed != null && seed.text.isNotEmpty) {
      _future = Future<OssLicense?>.value(seed);
    } else if (seed != null) {
      _future = loadOssLicense(
        seed.name,
        packageNames: widget.packageNames ?? kDirectOssPackages,
      ).then((loaded) => loaded ?? seed);
    } else {
      _future = Future<OssLicense?>.value(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final title = widget.license?.name ?? l10n.aboutOssListTitle;
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(title),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go(OssLicensesPage.path),
          ),
        ],
      ),
      child: FutureBuilder<OssLicense?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Semantics(
              label: l10n.aboutOssLoading,
              child: const Center(child: FCircularProgress(size: .md)),
            );
          }
          final item = snapshot.data;
          if (item == null || item.text.isEmpty) {
            return Center(child: Text(l10n.aboutOssEmpty));
          }
          return ListView(
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
          );
        },
      ),
    );
  }
}
