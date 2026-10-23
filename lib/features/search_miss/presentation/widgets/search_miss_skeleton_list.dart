import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Skeleton tile-list untuk daftar search-miss (beranda + tab Kontribusi).
class SearchMissSkeletonList extends StatelessWidget {
  const SearchMissSkeletonList({
    super.key,
    this.itemCount = 6,
    this.padding = const EdgeInsets.fromLTRB(16, 10, 16, 24),
    this.header,
  });

  final int itemCount;
  final EdgeInsetsGeometry padding;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final materialBrightness = Theme.of(context).brightness;
    final isDark = materialBrightness == Brightness.dark;
    final muted = context.theme.colors.muted;
    PaintingEffect shimmerResolver(Brightness brightness) => ShimmerEffect(
      baseColor: isDark
          ? muted.withValues(alpha: 0.35)
          : const Color(0xFFE7E7EA),
      highlightColor: isDark
          ? muted.withValues(alpha: 0.55)
          : const Color(0xFFF4F4F5),
      duration: const Duration(milliseconds: 1500),
    );

    return SkeletonizerConfig(
      data: SkeletonizerConfigData(effectResolver: shimmerResolver),
      child: IgnorePointer(
        child: Skeletonizer(
          enabled: true,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: padding,
            children: [
              if (header != null) ...[header!, const Gap(10)],
              FTileGroup(
                children: [
                  for (var i = 0; i < itemCount; i++)
                    FTile(
                      title: Text('kata dicari contoh ${i + 1}'),
                      subtitle: const Text('Sambas → Indonesia · 12× dicari'),
                      suffix: Icon(
                        FLucideIcons.chevronRight,
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
