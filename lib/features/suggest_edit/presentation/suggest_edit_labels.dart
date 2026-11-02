import 'package:sambasku_mobile/l10n/app_localizations.dart';
import '../../review/domain/review_access.dart';
import '../domain/suggest_category.dart';

/// Label kategori usulan (enum domain bebas l10n) -> teks locale aktif.
String suggestCategoryLabel(SuggestCategory c, AppLocalizations l10n) =>
    switch (c) {
      SuggestCategory.changeMeaning => l10n.suggestCategoryChangeMeaning,
      SuggestCategory.changeWordClass => l10n.suggestCategoryChangeWordClass,
      SuggestCategory.addMeaning => l10n.suggestCategoryAddMeaning,
      SuggestCategory.addExample => l10n.suggestCategoryAddExample,
      SuggestCategory.addPhoto => l10n.suggestCategoryAddPhoto,
      SuggestCategory.changePhoto => l10n.suggestCategoryChangePhoto,
      SuggestCategory.synonym => l10n.suggestCategorySynonym,
      SuggestCategory.antonym => l10n.suggestCategoryAntonym,
      SuggestCategory.variantOf => l10n.suggestCategoryVariantOf,
      SuggestCategory.nonstandardOf => l10n.suggestCategoryNonstandardOf,
      SuggestCategory.derivedFrom => l10n.suggestCategoryDerivedFrom,
      SuggestCategory.meaningGroup => l10n.suggestCategoryMeaningGroup,
      SuggestCategory.spellingVariant => l10n.suggestCategorySpellingVariant,
      SuggestCategory.lemmaNotes => l10n.suggestCategoryLemmaNotes,
    };

String suggestCategoryDescription(
  SuggestCategory c,
  AppLocalizations l10n,
) => switch (c) {
  SuggestCategory.changeMeaning => l10n.suggestCategoryChangeMeaningDesc,
  SuggestCategory.changeWordClass => l10n.suggestCategoryChangeWordClassDesc,
  SuggestCategory.addMeaning => l10n.suggestCategoryAddMeaningDesc,
  SuggestCategory.addExample => l10n.suggestCategoryAddExampleDesc,
  SuggestCategory.addPhoto => l10n.suggestCategoryAddPhotoDesc,
  SuggestCategory.changePhoto => l10n.suggestCategoryChangePhotoDesc,
  SuggestCategory.synonym => l10n.suggestCategorySynonymDesc,
  SuggestCategory.antonym => l10n.suggestCategoryAntonymDesc,
  SuggestCategory.variantOf => l10n.suggestCategoryVariantOfDesc,
  SuggestCategory.nonstandardOf => l10n.suggestCategoryNonstandardOfDesc,
  SuggestCategory.derivedFrom => l10n.suggestCategoryDerivedFromDesc,
  SuggestCategory.meaningGroup => l10n.suggestCategoryMeaningGroupDesc,
  SuggestCategory.spellingVariant => l10n.suggestCategorySpellingVariantDesc,
  SuggestCategory.lemmaNotes => l10n.suggestCategoryLemmaNotesDesc,
};

/// Copy tile "Perbaiki/lengkapi kata" vs "Usulkan perubahan" di detail kata.
({String title, String subtitle}) suggestEditEntryTileCopy(
  String? role,
  AppLocalizations l10n,
) {
  if (isVerifierRole(role)) {
    return (
      title: l10n.suggestEntryTileVerifierTitle,
      subtitle: l10n.suggestEntryTileVerifierSubtitle,
    );
  }
  return (
    title: l10n.suggestEntryTileContributorTitle,
    subtitle: l10n.suggestEntryTileContributorSubtitle,
  );
}

/// Copy form sebelum submit - berdasarkan role lokal.
({String banner, String cta, String ctaBusy}) suggestEditPreSubmitCopy(
  String? role,
  AppLocalizations l10n,
) {
  if (isVerifierRole(role)) {
    return (
      banner: l10n.suggestPreSubmitVerifierBanner,
      cta: l10n.suggestPreSubmitVerifierCta,
      ctaBusy: l10n.suggestPreSubmitVerifierCtaBusy,
    );
  }
  return (
    banner: l10n.suggestPreSubmitContributorBanner,
    cta: l10n.suggestPreSubmitContributorCta,
    ctaBusy: l10n.suggestPreSubmitContributorCtaBusy,
  );
}

/// Toast setelah submit sukses.
String suggestEditSuccessToast({
  required bool selfApplied,
  required bool wordVerified,
  required String lemma,
  required AppLocalizations l10n,
}) {
  final label = lemma.isEmpty ? l10n.suggestSuccessThisWord : lemma;
  if (selfApplied) return l10n.suggestSuccessApplied(label);
  if (wordVerified) return l10n.suggestSuccessQueued(label);
  return l10n.suggestSuccessPublishedPending(label);
}
