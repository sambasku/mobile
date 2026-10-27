import 'package:flutter/services.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../domain/entities/word_detail.dart';

/// Teks polos untuk clipboard dari satu makna (+ lemma).
String buildWordMeaningClipboardText({
  required String lemma,
  required WordMeaning meaning,
}) {
  final buf = StringBuffer(lemma.trim());
  _appendMeaning(buf, meaning, prefix: '');
  buf.write('\n\n#SambasKu');
  return buf.toString();
}

/// Teks polos untuk clipboard dari seluruh detail kata.
String buildWordClipboardText(WordDetail detail) {
  final buf = StringBuffer(detail.lemma);

  final variantForms = <String>[];
  final seen = <String>{detail.lemma.trim().toLowerCase()};
  for (final v in detail.variants) {
    final form = v.form.trim();
    if (form.isEmpty) continue;
    if (!seen.add(form.toLowerCase())) continue;
    variantForms.add(form);
  }
  if (variantForms.isNotEmpty) {
    buf.write('\n${variantForms.join(' / ')}');
  }

  final meanings = [...detail.meanings]
    ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  for (var i = 0; i < meanings.length; i++) {
    final prefix = meanings.length > 1 ? '${i + 1} ' : '';
    _appendMeaning(buf, meanings[i], prefix: prefix);
  }

  buf.write('\n\n#SambasKu');
  return buf.toString();
}

void _appendMeaning(
  StringBuffer buf,
  WordMeaning m, {
  required String prefix,
}) {
  final bracket = m.wordClassBracket;
  final padanan = _pickPadanan(m);
  final definition = m.definition?.trim();
  final defOk =
      definition != null && definition.isNotEmpty && definition != '-';

  final head = [
    ?bracket,
    if (padanan != null) '→ $padanan',
  ].join(' ');
  if (head.isNotEmpty) {
    buf.write('\n$prefix$head');
  }
  if (defOk) {
    buf.write(head.isEmpty ? '\n$prefix$definition' : '\n$definition');
  }

  for (final ex in m.examples) {
    final src = ex.sourceSentence.trim();
    if (src.isEmpty) continue;
    buf.write('\n"$src"');
    final tgt = ex.targetSentence?.trim();
    if (tgt != null && tgt.isNotEmpty) {
      buf.write('\n→ $tgt');
    }
    break; // satu contoh per makna
  }
}

String? _pickPadanan(WordMeaning meaning) {
  final direct = meaning.translations.where((t) => t.type == 'direct');
  if (direct.isNotEmpty) return direct.first.text.trim();
  if (meaning.translations.isNotEmpty) {
    return meaning.translations.first.text.trim();
  }
  return null;
}

Future<void> copyWordDetailToClipboard(
  BuildContext context,
  WordDetail detail,
) async {
  await Clipboard.setData(ClipboardData(text: buildWordClipboardText(detail)));
  if (!context.mounted) return;
  showFToast(
    context: context,
    title: Text(AppLocalizations.of(context).dictCopiedWord),
  );
}

Future<void> copyWordMeaningToClipboard(
  BuildContext context, {
  required String lemma,
  required WordMeaning meaning,
}) async {
  await Clipboard.setData(
    ClipboardData(
      text: buildWordMeaningClipboardText(lemma: lemma, meaning: meaning),
    ),
  );
  if (!context.mounted) return;
  showFToast(
    context: context,
    title: Text(AppLocalizations.of(context).dictCopiedMeaning),
  );
}
