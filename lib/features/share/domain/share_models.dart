import 'package:flutter/material.dart';

import '../../../core/models/image_attribution.dart';
import 'word_public_url.dart';

export '../../../core/models/image_attribution.dart';

/// Kandidat latar dari GET /api/v1/share/backgrounds.
class ShareBackground {
  const ShareBackground({
    required this.id,
    required this.url,
    required this.photographer,
    required this.username,
    required this.attributionUrl,
    this.provider = 'pixabay',
    this.kind = ShareMediaKind.photo,
    this.previewUrl,
    this.width = 0,
    this.height = 0,
    this.durationSeconds = 0,
    this.license,
    this.licenseUrl,
    this.source,
  });

  final String id;
  final String url;
  final String photographer;
  final String username;
  final String attributionUrl;
  final String provider;
  final ShareMediaKind kind;
  final String? previewUrl;
  final int width;
  final int height;
  final int durationSeconds;

  /// Openverse (CC): label lisensi, mis. `CC BY 2.0`.
  final String? license;
  final String? licenseUrl;

  /// Openverse: sumber asli, mis. `flickr`.
  final String? source;

  /// Alias lama.
  String get unsplashUrl => attributionUrl;

  /// Kredit wajib (tile Explorer, kartu share, gambar kata).
  ImageAttribution get attribution {
    final lic = license?.trim() ?? '';
    final src = source?.trim() ?? '';
    final name = photographer.trim().isNotEmpty
        ? photographer.trim()
        : username.trim().isNotEmpty
        ? username.trim()
        : shareProviderLabel(provider);
    return ImageAttribution(
      name: name,
      provider: provider,
      url: provider == 'unsplash' && username.isNotEmpty
          ? unsplashProfileUri(username).toString()
          : attributionUrl,
      license: lic.isEmpty ? null : lic,
      licenseUrl: licenseUrl,
      source: src.isEmpty ? null : src,
    );
  }

  String get thumbUrl {
    final preview = previewUrl;
    if (kind == ShareMediaKind.video && preview != null && preview.isNotEmpty) {
      return preview;
    }
    return url;
  }

  bool get isVideo => kind == ShareMediaKind.video;
}

class ShareBackgroundsResult {
  const ShareBackgroundsResult({
    required this.items,
    required this.page,
    required this.degraded,
    this.provider = 'pixabay',
  });

  final List<ShareBackground> items;
  final int page;
  final bool degraded;
  final String provider;
}

/// Sumber latar kartu (terpisah dari gaya template).
enum ShareBgSource { stock, device, wordImage, none }

enum ShareMediaKind { photo, video }

/// Satu baris makna pada kartu share (`[n] → kumis` + definisi).
class ShareSenseLine {
  const ShareSenseLine({
    this.wordClassCode,
    this.padanan,
    this.definition,
  });

  final String? wordClassCode;
  final String? padanan;
  final String? definition;

  String? get wordClassBracket {
    final code = wordClassCode?.trim();
    if (code == null || code.isEmpty) return null;
    return '[${code.toLowerCase()}]';
  }

  bool get hasBody {
    final pad = padanan?.trim() ?? '';
    final def = definition?.trim() ?? '';
    return pad.isNotEmpty || def.isNotEmpty;
  }
}

/// Data teks yang digambar ke kartu share.
class ShareCardData {
  const ShareCardData({
    required this.lemma,
    this.wordClassName,
    this.wordClassCode,
    this.definition,
    this.padanan,
    this.senses = const [],
    this.exampleSentence,
    this.photographer,
    this.provider,
    this.license,
    this.source,
    this.isVideo = false,
    this.variantsLine,
    this.isVerified = true,
  });

  final String lemma;
  final String? wordClassName;

  /// Kode kelas kata makna aktif (`n`, `v`, …).
  final String? wordClassCode;
  final String? definition;
  final String? padanan;

  /// Satu atau beberapa makna. Kosong = fallback ke [padanan]/[definition].
  final List<ShareSenseLine> senses;
  final String? exampleSentence;
  final String? photographer;
  final String? provider;

  /// Openverse (CC): label lisensi + sumber asli untuk kredit wajib.
  final String? license;
  final String? source;
  final bool isVideo;
  final String? variantsLine;
  final bool isVerified;

  String get trustLabel => isVerified ? 'Terverifikasi' : 'Menunggu pengecekan';

  String? get wordClassBracket {
    final code = wordClassCode?.trim();
    if (code == null || code.isEmpty) return null;
    return '[${code.toLowerCase()}]';
  }

  /// Baris atribusi stok. Kosong jika tidak ada nama fotografer.
  String? get creditLine {
    final name = photographer?.trim();
    if (name == null || name.isEmpty) return null;
    final kind = isVideo ? 'Video' : 'Foto';
    final id = provider?.trim() ?? '';
    final lic = license?.trim() ?? '';
    if (lic.isNotEmpty) {
      // Kredit CC wajib ikut gambar. BY 4.0 minta tanda perubahan
      // (foto dipotong / ditimpa teks), jadi "diubah" untuk semua CC BY.
      final changed = lic.startsWith('CC BY') ? ', diubah' : '';
      final src = source?.trim() ?? '';
      final from = src.isNotEmpty
          ? shareSourceLabel(src)
          : shareProviderLabel(id.isEmpty ? 'openverse' : id);
      return '$kind: $name ($lic$changed) / $from';
    }
    if (id.isEmpty) return '$kind: $name';
    return '$kind: $name / ${shareProviderLabel(id)}';
  }

  String get caption {
    final pad = (padanan != null && padanan!.isNotEmpty) ? padanan! : lemma;
    final variants = variantsLine;
    final base = variants != null && variants.isNotEmpty
        ? '"$lemma" ($variants) - $pad · kamus bahasa Sambas #SambasKu'
        : '"$lemma" - $pad · kamus bahasa Sambas #SambasKu';
    final url = wordPublicUrl(lemma);
    final withUrl = url == null ? base : '$base\n$url';
    if (isVerified) return withUrl;
    return '$withUrl\nArti belum diperiksa tim Sambasku.';
  }

  String get copyText {
    final buf = StringBuffer(lemma);
    if (variantsLine != null && variantsLine!.isNotEmpty) {
      buf.write('\n${variantsLine!}');
    }
    final lines = senses.isNotEmpty
        ? senses
        : [
            ShareSenseLine(
              wordClassCode: wordClassCode,
              padanan: padanan,
              definition: definition,
            ),
          ];
    for (var i = 0; i < lines.length; i++) {
      final sense = lines[i];
      if (!sense.hasBody && sense.wordClassBracket == null) continue;
      final prefix = lines.length > 1 ? '${i + 1} ' : '';
      final bracket = sense.wordClassBracket;
      final head = [
        ?bracket,
        if (sense.padanan?.trim() case final pad? when pad.isNotEmpty)
          '→ $pad',
      ].join(' ');
      if (head.isNotEmpty) buf.write('\n$prefix$head');
      final def = sense.definition?.trim();
      if (def != null && def.isNotEmpty) {
        buf.write(head.isEmpty ? '\n$prefix$def' : '\n$def');
      }
    }
    if (exampleSentence != null && exampleSentence!.isNotEmpty) {
      buf.write('\n"$exampleSentence"');
    }
    if (!isVerified) {
      buf.write('\nArti belum diperiksa tim Sambasku.');
    }
    buf.write('\n\n#SambasKu');
    return buf.toString();
  }
}

enum ShareFontPair { classic, editorial, modern }

extension ShareFontPairX on ShareFontPair {
  String get label => switch (this) {
    ShareFontPair.classic => 'Klasik',
    ShareFontPair.editorial => 'Editorial',
    ShareFontPair.modern => 'Modern',
  };
}

enum ShareTextColorId { putih, krem, tinta, terracotta, sky }

extension ShareTextColorIdX on ShareTextColorId {
  String get label => switch (this) {
    ShareTextColorId.putih => 'Putih',
    ShareTextColorId.krem => 'Krem',
    ShareTextColorId.tinta => 'Tinta',
    ShareTextColorId.terracotta => 'Terracotta',
    ShareTextColorId.sky => 'Sky',
  };

  Color get lemma => switch (this) {
    ShareTextColorId.putih => const Color(0xFFFFFFFF),
    ShareTextColorId.krem => const Color(0xFFFFF7ED),
    ShareTextColorId.tinta => const Color(0xFF1C1917),
    ShareTextColorId.terracotta => const Color(0xFFFDBA74),
    ShareTextColorId.sky => const Color(0xFFBAE6FD),
  };

  Color get body => switch (this) {
    ShareTextColorId.putih => const Color(0xFFFFFFFF).withValues(alpha: 0.92),
    ShareTextColorId.krem => const Color(0xFFFFEDD5),
    ShareTextColorId.tinta => const Color(0xFF44403C),
    ShareTextColorId.terracotta => const Color(0xFFFED7AA),
    ShareTextColorId.sky => const Color(0xFFE0F2FE),
  };

  /// Surface gelap (editorial/polaroid) jika teks terang.
  bool get prefersDarkSurface => this != ShareTextColorId.tinta;
}

enum ShareBackdropKind { gradient, solid }

enum ShareGradientId { senja, laut, hutan, pasir, charcoal }

extension ShareGradientIdX on ShareGradientId {
  String get label => switch (this) {
    ShareGradientId.senja => 'Senja',
    ShareGradientId.laut => 'Laut',
    ShareGradientId.hutan => 'Hutan',
    ShareGradientId.pasir => 'Pasir',
    ShareGradientId.charcoal => 'Charcoal',
  };

  List<Color> get colors => switch (this) {
    ShareGradientId.senja => const [
      Color(0xFF1B3A4B),
      Color(0xFFC45C26),
      Color(0xFF2A1810),
    ],
    ShareGradientId.laut => const [
      Color(0xFF0F172A),
      Color(0xFF1E3A5F),
      Color(0xFF0EA5E9),
    ],
    ShareGradientId.hutan => const [
      Color(0xFF14532D),
      Color(0xFF3F6212),
      Color(0xFFD9F99D),
    ],
    ShareGradientId.pasir => const [
      Color(0xFFF5E6D3),
      Color(0xFFC45C26),
      Color(0xFFA16207),
    ],
    ShareGradientId.charcoal => const [
      Color(0xFF292524),
      Color(0xFF57534E),
      Color(0xFFA8A29E),
    ],
  };
}

enum ShareTextElementId { lemma, padanan, definition, example, wordClass }

extension ShareTextElementIdX on ShareTextElementId {
  String get label => switch (this) {
    ShareTextElementId.lemma => 'Lemma',
    ShareTextElementId.padanan => 'Terjemahan',
    ShareTextElementId.definition => 'Definisi',
    ShareTextElementId.example => 'Contoh',
    ShareTextElementId.wordClass => 'Kelas kata',
  };
}

/// Offset + rotasi relatif terhadap posisi default (koordinat canvas).
class ShareTextLayout {
  const ShareTextLayout({
    this.offset = Offset.zero,
    this.rotationDeg = 0,
  });

  final Offset offset;
  final double rotationDeg;

  static const zero = ShareTextLayout();

  ShareTextLayout copyWith({Offset? offset, double? rotationDeg}) {
    return ShareTextLayout(
      offset: offset ?? this.offset,
      rotationDeg: rotationDeg ?? this.rotationDeg,
    );
  }
}

/// Kontrol editor praktis (bukan Canva).
class ShareEditorSettings {
  const ShareEditorSettings({
    this.lemmaFontScale = 1.0,
    this.bodyFontScale = 1.0,
    this.overlayStrength = 0.75,
    this.fontPair = ShareFontPair.classic,
    this.textColorId = ShareTextColorId.putih,
    this.gradientId = ShareGradientId.senja,
    this.backdropKind = ShareBackdropKind.gradient,
    this.solidColor = const Color(0xFF1C1917),
    this.showWordClass = true,
    this.showPadanan = true,
    this.showDefinition = true,
    this.showExample = false,
    this.showAllMeanings = false,
    this.showWatermark = true,
    this.lemmaLayout = ShareTextLayout.zero,
    this.padananLayout = ShareTextLayout.zero,
    this.definitionLayout = ShareTextLayout.zero,
    this.exampleLayout = ShareTextLayout.zero,
    this.wordClassLayout = ShareTextLayout.zero,
    this.mediaAlignment = Offset.zero,
  });

  final double lemmaFontScale;
  final double bodyFontScale;
  final double overlayStrength;
  final ShareFontPair fontPair;
  final ShareTextColorId textColorId;
  final ShareGradientId gradientId;
  final ShareBackdropKind backdropKind;
  final Color solidColor;
  final bool showWordClass;
  final bool showPadanan;
  final bool showDefinition;
  final bool showExample;

  /// Tampilkan hingga 3 makna sekaligus (daftar bernomor + `[n]`).
  final bool showAllMeanings;
  final bool showWatermark;
  final ShareTextLayout lemmaLayout;
  final ShareTextLayout padananLayout;
  final ShareTextLayout definitionLayout;
  final ShareTextLayout exampleLayout;
  final ShareTextLayout wordClassLayout;

  /// -1..1, mengikuti `Alignment` `BoxFit.cover` (geser crop foto/video).
  final Offset mediaAlignment;

  /// Isi latar Tanpa latar / Poster / fallback. Solid = dua warna sama.
  List<Color> get backdropColors => backdropKind == ShareBackdropKind.solid
      ? [solidColor, solidColor]
      : gradientId.colors;

  ShareTextLayout layoutFor(ShareTextElementId id) => switch (id) {
    ShareTextElementId.lemma => lemmaLayout,
    ShareTextElementId.padanan => padananLayout,
    ShareTextElementId.definition => definitionLayout,
    ShareTextElementId.example => exampleLayout,
    ShareTextElementId.wordClass => wordClassLayout,
  };

  ShareEditorSettings withLayout(ShareTextElementId id, ShareTextLayout layout) {
    return switch (id) {
      ShareTextElementId.lemma => copyWith(lemmaLayout: layout),
      ShareTextElementId.padanan => copyWith(padananLayout: layout),
      ShareTextElementId.definition => copyWith(definitionLayout: layout),
      ShareTextElementId.example => copyWith(exampleLayout: layout),
      ShareTextElementId.wordClass => copyWith(wordClassLayout: layout),
    };
  }

  ShareEditorSettings resetLayouts() {
    return copyWith(
      lemmaLayout: ShareTextLayout.zero,
      padananLayout: ShareTextLayout.zero,
      definitionLayout: ShareTextLayout.zero,
      exampleLayout: ShareTextLayout.zero,
      wordClassLayout: ShareTextLayout.zero,
      mediaAlignment: Offset.zero,
    );
  }

  ShareEditorSettings copyWith({
    double? lemmaFontScale,
    double? bodyFontScale,
    double? overlayStrength,
    ShareFontPair? fontPair,
    ShareTextColorId? textColorId,
    ShareGradientId? gradientId,
    ShareBackdropKind? backdropKind,
    Color? solidColor,
    bool? showWordClass,
    bool? showPadanan,
    bool? showDefinition,
    bool? showExample,
    bool? showAllMeanings,
    bool? showWatermark,
    ShareTextLayout? lemmaLayout,
    ShareTextLayout? padananLayout,
    ShareTextLayout? definitionLayout,
    ShareTextLayout? exampleLayout,
    ShareTextLayout? wordClassLayout,
    Offset? mediaAlignment,
  }) {
    return ShareEditorSettings(
      lemmaFontScale: lemmaFontScale ?? this.lemmaFontScale,
      bodyFontScale: bodyFontScale ?? this.bodyFontScale,
      overlayStrength: overlayStrength ?? this.overlayStrength,
      fontPair: fontPair ?? this.fontPair,
      textColorId: textColorId ?? this.textColorId,
      gradientId: gradientId ?? this.gradientId,
      backdropKind: backdropKind ?? this.backdropKind,
      solidColor: solidColor ?? this.solidColor,
      showWordClass: showWordClass ?? this.showWordClass,
      showPadanan: showPadanan ?? this.showPadanan,
      showDefinition: showDefinition ?? this.showDefinition,
      showExample: showExample ?? this.showExample,
      showAllMeanings: showAllMeanings ?? this.showAllMeanings,
      showWatermark: showWatermark ?? this.showWatermark,
      lemmaLayout: lemmaLayout ?? this.lemmaLayout,
      padananLayout: padananLayout ?? this.padananLayout,
      definitionLayout: definitionLayout ?? this.definitionLayout,
      exampleLayout: exampleLayout ?? this.exampleLayout,
      wordClassLayout: wordClassLayout ?? this.wordClassLayout,
      mediaAlignment: mediaAlignment ?? this.mediaAlignment,
    );
  }
}

enum ShareTemplateId {
  unsplash,
  kamusEditorial,
  posterHuruf,
  polaroid,
  sisi,
  kaca,
  kutipan,
  kartu,
}

enum ShareRatioId {
  /// Instagram / TikTok Stories - 9:16
  story,

  /// Potret klasik foto - 2:3
  portrait23,

  /// Potret umum ponsel - 3:4
  portrait34,

  /// Instagram feed potret - 4:5
  portrait45,

  /// Kotak - 1:1
  post,
}

extension ShareRatioIdX on ShareRatioId {
  double get width => 1080;

  double get height => switch (this) {
    ShareRatioId.story => 1920,
    ShareRatioId.portrait23 => 1620,
    ShareRatioId.portrait34 => 1440,
    ShareRatioId.portrait45 => 1350,
    ShareRatioId.post => 1080,
  };

  String get label => switch (this) {
    ShareRatioId.story => '9:16',
    ShareRatioId.portrait23 => '2:3',
    ShareRatioId.portrait34 => '3:4',
    ShareRatioId.portrait45 => '4:5',
    ShareRatioId.post => '1:1',
  };

  /// Query stok foto: potret / kotak / lanskap.
  String get stockOrientation {
    if (height > width) return 'portrait';
    if (height < width) return 'landscape';
    return 'square';
  }

  /// Template Sisi: media|teks berdampingan bila hampir kotak.
  bool get prefersSideSplit => height / width <= 1.05;
}

extension ShareTemplateIdX on ShareTemplateId {
  String get label => switch (this) {
    ShareTemplateId.unsplash => 'Penuh',
    ShareTemplateId.kamusEditorial => 'Editorial',
    ShareTemplateId.posterHuruf => 'Poster',
    ShareTemplateId.polaroid => 'Bingkai',
    ShareTemplateId.sisi => 'Sisi',
    ShareTemplateId.kaca => 'Kaca',
    ShareTemplateId.kutipan => 'Kutipan',
    ShareTemplateId.kartu => 'Kartu',
  };

  bool get forcesNoPhoto => this == ShareTemplateId.posterHuruf;

  bool get allowsMediaPan => !forcesNoPhoto;

  bool get usesOverlay => switch (this) {
    ShareTemplateId.unsplash ||
    ShareTemplateId.kaca ||
    ShareTemplateId.kutipan => true,
    _ => false,
  };
}
