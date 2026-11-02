import 'package:sambasku_mobile/l10n/app_localizations.dart';
import '../domain/share_models.dart';

/// Mapping label enum share (domain layer, bebas l10n) -> teks locale
/// aktif. Taxonomy konten kartu (rasio "9:16", nama provider) tetap
/// tidak diterjemahkan.
String shareTemplateLabel(ShareTemplateId t, AppLocalizations l10n) =>
    switch (t) {
      ShareTemplateId.unsplash => l10n.shareTemplateFull,
      ShareTemplateId.kamusEditorial => l10n.shareTemplateEditorial,
      ShareTemplateId.posterHuruf => l10n.shareTemplatePoster,
      ShareTemplateId.polaroid => l10n.shareTemplateFrame,
      ShareTemplateId.sisi => l10n.shareTemplateSide,
      ShareTemplateId.kaca => l10n.shareTemplateGlass,
      ShareTemplateId.kutipan => l10n.shareTemplateQuote,
      ShareTemplateId.kartu => l10n.shareTemplateCard,
    };

String shareFontLabel(ShareFontPair f, AppLocalizations l10n) => switch (f) {
      ShareFontPair.classic => l10n.shareFontClassic,
      ShareFontPair.editorial => l10n.shareFontEditorial,
      ShareFontPair.modern => l10n.shareFontModern,
    };

String shareTextElementLabel(ShareTextElementId e, AppLocalizations l10n) =>
    switch (e) {
      ShareTextElementId.lemma => l10n.shareElementLemma,
      ShareTextElementId.padanan => l10n.shareElementTranslation,
      ShareTextElementId.definition => l10n.shareElementDefinition,
      ShareTextElementId.example => l10n.shareElementExample,
      ShareTextElementId.wordClass => l10n.shareElementWordClass,
    };
