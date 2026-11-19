import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../l10n/app_localizations.dart';

/// Tier yang boleh tampil di splash (Perak tidak ikut).
enum SplashSponsorTier {
  emas,
  intan,
  mustika,
}

/// Rasio holder + aset logo.
enum SplashSponsorLogoAspect {
  /// Landscape ~5:3 (holder ikut).
  landscape,

  /// Kotak 1:1 (holder ikut, bukan letterbox di dalam 4:3).
  square,
}

/// Satu logo di slot splash (mock DevTool atau data API nanti).
class SplashSponsorLogo {
  const SplashSponsorLogo({
    required this.tier,
    required this.imageUrl,
    this.name,
    this.aspect = SplashSponsorLogoAspect.landscape,
  });

  final SplashSponsorTier tier;
  final String imageUrl;
  final String? name;
  final SplashSponsorLogoAspect aspect;
}

/// Ukuran box: hierarki Mustika > Intan > Emas; rasio ikut [SplashSponsorLogoAspect].
extension SplashSponsorTierSize on SplashSponsorTier {
  /// Landscape ~5:3. Di bawah BrandMark splash (~248) supaya tidak menyaingi.
  Size get boxSizeLandscape => switch (this) {
    .mustika => const Size(100, 60),
    .intan => const Size(68, 40),
    .emas => const Size(44, 26),
  };

  /// 1:1 - hierarki jelas, tetap lebih kecil dari BrandMark.
  Size get boxSizeSquare => switch (this) {
    .mustika => const Size(56, 56),
    .intan => const Size(40, 40),
    .emas => const Size(28, 28),
  };

  Size boxSizeFor(SplashSponsorLogoAspect aspect) => switch (aspect) {
    SplashSponsorLogoAspect.landscape => boxSizeLandscape,
    SplashSponsorLogoAspect.square => boxSizeSquare,
  };

  /// Padding dalam holder - tipis supaya border rapat ke logo (terutama PNG alpha).
  double get boxPadding => 1;

  double get rowGap => switch (this) {
    .emas => 5,
    .intan => 8,
    .mustika => 12,
  };

  /// Cap deck: Mustika 2, Intan 3, Emas 5.
  int get maxCount => switch (this) {
    .emas => 5,
    .intan => 3,
    .mustika => 2,
  };

  int get sortRank => switch (this) {
    .mustika => 0,
    .intan => 1,
    .emas => 2,
  };
}

/// Warna holder logo: null = ikut tema ([dark]).
Color splashSponsorHolderColor({required bool dark, Color? override}) {
  if (override != null) return override;
  return dark ? const Color(0xFF1C1917) : const Color(0xFFFFFFFF);
}

/// Label "Didukung oleh" + stack logo Mustika → Intan → Emas.
///
/// [logoBackground] opsional: override warna kotak holder. Null = ikut tema.
/// Tanpa border; contrast lewat holder + (opsional) gradasi kaki di parent.
class SplashSponsorSlot extends StatelessWidget {
  const SplashSponsorSlot({
    super.key,
    required this.logos,
    this.dark = false,
    this.logoBackground,
  });

  final List<SplashSponsorLogo> logos;
  final bool dark;

  /// Warna kotak di belakang logo. Null = putih (light) / batu gelap (dark).
  final Color? logoBackground;

  static const stackGap = 10.0;

  @override
  Widget build(BuildContext context) {
    if (logos.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final byTier = <SplashSponsorTier, List<SplashSponsorLogo>>{};
    for (final logo in logos) {
      byTier.putIfAbsent(logo.tier, () => []).add(logo);
    }
    final orderedTiers = SplashSponsorTier.values.toList()
      ..sort((a, b) => a.sortRank.compareTo(b.sortRank));

    final labelColor = dark
        ? const Color(0xFFA8A29E)
        : const Color(0xFF78716C);
    final holder = splashSponsorHolderColor(
      dark: dark,
      override: logoBackground,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.splashSupportedBy,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: labelColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.05 * 11,
            height: 1.2,
          ),
        ),
        const Gap(10),
        for (var i = 0; i < orderedTiers.length; i++) ...[
          if (byTier[orderedTiers[i]] case final row? when row.isNotEmpty) ...[
            if (i > 0 &&
                orderedTiers
                    .take(i)
                    .any((t) => (byTier[t]?.isNotEmpty ?? false)))
              const Gap(stackGap),
            _SponsorRow(
              tier: orderedTiers[i],
              logos: row.take(orderedTiers[i].maxCount).toList(),
              holderColor: holder,
              dark: dark,
            ),
          ],
        ],
      ],
    );
  }
}

class _SponsorRow extends StatelessWidget {
  const _SponsorRow({
    required this.tier,
    required this.logos,
    required this.holderColor,
    required this.dark,
  });

  final SplashSponsorTier tier;
  final List<SplashSponsorLogo> logos;
  final Color holderColor;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      for (final logo in logos)
        _SponsorLogoTile(
          tier: tier,
          imageUrl: logo.imageUrl,
          aspect: logo.aspect,
          holderColor: holderColor,
          dark: dark,
        ),
    ];

    // Emas: selalu satu baris (tidak wrap). Mustika/Intan boleh Wrap.
    if (tier == SplashSponsorTier.emas) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              if (i > 0) SizedBox(width: tier.rowGap),
              tiles[i],
            ],
          ],
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: tier.rowGap,
      runSpacing: tier.rowGap,
      children: tiles,
    );
  }
}

/// Kotak holder + logo; tinggi seragam; stroke tipis.
class _SponsorLogoTile extends StatelessWidget {
  const _SponsorLogoTile({
    required this.tier,
    required this.imageUrl,
    required this.aspect,
    required this.holderColor,
    required this.dark,
  });

  final SplashSponsorTier tier;
  final String imageUrl;
  final SplashSponsorLogoAspect aspect;
  final Color holderColor;
  final bool dark;

  static const _radius = 4.0;
  static const _stroke = 1.5;

  @override
  Widget build(BuildContext context) {
    final size = tier.boxSizeFor(aspect);
    final pad = tier.boxPadding;
    final innerW = size.width - pad * 2;
    final innerH = size.height - pad * 2;
    final strokeColor = dark
        ? const Color(0xFF44403C)
        : const Color(0xFFE7E5E4);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: holderColor,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: strokeColor, width: _stroke),
        ),
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: ClipRRect(
            borderRadius: BorderRadius.circular((_radius - pad).clamp(0, _radius)),
            child: _SponsorLogoImage(
              imageUrl: imageUrl,
              width: innerW,
              height: innerH,
              holderColor: holderColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Network atau asset (`assets/...`) - PNG transparan pakai [Image.asset].
class _SponsorLogoImage extends StatelessWidget {
  const _SponsorLogoImage({
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.holderColor,
  });

  final String imageUrl;
  final double width;
  final double height;
  final Color holderColor;

  bool get _isAsset => imageUrl.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    if (_isAsset) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => _LogoSkeleton(
          width: width,
          height: height,
          base: holderColor,
          enable: false,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
      width: width,
      height: height,
      placeholder: (_, _) => _LogoSkeleton(
        width: width,
        height: height,
        base: holderColor,
      ),
      errorWidget: (_, _, _) => _LogoSkeleton(
        width: width,
        height: height,
        base: holderColor,
        enable: false,
      ),
    );
  }
}

/// Skeleton seukuran logo: soft pulse, sudut ikut holder - bukan Bone expand.
class _LogoSkeleton extends StatelessWidget {
  const _LogoSkeleton({
    required this.width,
    required this.height,
    required this.base,
    this.enable = true,
  });

  final double width;
  final double height;
  final Color base;
  final bool enable;

  @override
  Widget build(BuildContext context) {
    final bone = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.06),
      base,
    );
    final child = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bone,
        borderRadius: BorderRadius.circular(1),
      ),
    );
    if (!enable) return child;
    return Skeletonizer(
      effect: ShimmerEffect(
        baseColor: bone,
        highlightColor: Color.alphaBlend(
          Colors.white.withValues(alpha: 0.35),
          bone,
        ),
      ),
      child: child,
    );
  }
}

/// Rasio gambar mock di DevTool.
enum MockSplashImageRatio {
  /// ~3:2 landscape (192×112).
  landscape,

  /// 1:1 kotak (128×128).
  square,

  /// Campur: ganjil 1:1, genap landscape.
  mixed,
}

const _kTransparentPngNames = [
  'alpha',
  'beta',
  'gamma',
  'delta',
  'epsilon',
];

/// Bangun list logo mock untuk DevTool (picsum atau PNG transparan lokal).
List<SplashSponsorLogo> buildMockSplashSponsors({
  required int mustika,
  required int intan,
  required int emas,
  int seed = 1,
  MockSplashImageRatio ratio = MockSplashImageRatio.landscape,
  bool transparentPng = false,
}) {
  final out = <SplashSponsorLogo>[];
  var s = seed;
  var iGlobal = 0;

  (String url, SplashSponsorLogoAspect aspect) assetFor(
    int seedVal,
    int index,
  ) {
    final useSquare = switch (ratio) {
      MockSplashImageRatio.landscape => false,
      MockSplashImageRatio.square => true,
      MockSplashImageRatio.mixed => index.isOdd,
    };
    final aspect = useSquare
        ? SplashSponsorLogoAspect.square
        : SplashSponsorLogoAspect.landscape;

    if (transparentPng) {
      final name = _kTransparentPngNames[index % _kTransparentPngNames.length];
      final suffix = useSquare ? 'sq' : 'ls';
      return (
        'assets/dev/splash_sponsors/${name}_$suffix.png',
        aspect,
      );
    }
    if (useSquare) {
      return (
        'https://picsum.photos/seed/sk-splash-$seedVal/128/128',
        aspect,
      );
    }
    return (
      'https://picsum.photos/seed/sk-splash-$seedVal/192/112',
      aspect,
    );
  }

  void add(SplashSponsorTier tier, int count) {
    final n = count.clamp(0, tier.maxCount);
    for (var i = 0; i < n; i++) {
      final (url, aspect) = assetFor(s, iGlobal);
      out.add(
        SplashSponsorLogo(
          tier: tier,
          imageUrl: url,
          name: '${tier.name}-$i',
          aspect: aspect,
        ),
      );
      s++;
      iGlobal++;
    }
  }

  add(SplashSponsorTier.mustika, mustika);
  add(SplashSponsorTier.intan, intan);
  add(SplashSponsorTier.emas, emas);
  return out;
}
