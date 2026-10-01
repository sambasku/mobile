import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';

ShimmerEffect shareShimmerEffect(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final muted = context.theme.colors.muted;
  return ShimmerEffect(
    baseColor: isDark ? muted.withValues(alpha: 0.35) : const Color(0xFFE7E7EA),
    highlightColor: isDark
        ? muted.withValues(alpha: 0.55)
        : const Color(0xFFF4F4F5),
    duration: const Duration(milliseconds: 1500),
  );
}

/// Skeletonizer + shimmer baku fitur share (pola Home / detail kata).
class ShareSkeleton extends StatelessWidget {
  const ShareSkeleton({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SkeletonizerConfig(
      data: SkeletonizerConfigData(effect: shareShimmerEffect(context)),
      child: IgnorePointer(child: Skeletonizer(enabled: true, child: child)),
    );
  }
}

/// Placeholder preview kartu saat latar stok masih dimuat (buka sheet pertama).
class ShareCardPreviewSkeleton extends StatelessWidget {
  const ShareCardPreviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ShareSkeleton(
      child: ColoredBox(
        color: theme.colors.muted,
        child: const Padding(
          padding: EdgeInsets.fromLTRB(22, 32, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tinggi preview ikut layar (Expanded); di layar pendek bone
              // atas dipotong, bukan overflow. Footer tetap di bawah.
              Expanded(
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Bone(
                        width: 88,
                        height: 12,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      Gap(18),
                      Bone(
                        width: 220,
                        height: 34,
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      Gap(14),
                      Bone(
                        width: 160,
                        height: 16,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      Gap(10),
                      Bone(
                        width: 260,
                        height: 12,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      Gap(8),
                      Bone(
                        width: 200,
                        height: 12,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      Gap(8),
                      Bone(
                        width: 140,
                        height: 12,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ],
                  ),
                ),
              ),
              Gap(8),
              Bone(
                width: 110,
                height: 11,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
