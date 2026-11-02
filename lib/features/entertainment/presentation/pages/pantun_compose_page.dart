import 'dart:async';

import 'package:flutter/services.dart' show TextInputAction;
import 'package:flutter/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/pantun_api.dart';
import '../../domain/pantun_models.dart';
import '../../domain/rhyme_check.dart';
import '../providers/pantun_providers.dart';

/// Tulis pantun 4 baris dengan cek rima live (checker sama dengan API).
class PantunComposePage extends HookConsumerWidget {
  const PantunComposePage({super.key, this.parentId});

  /// Null = pantun pembuka; berisi = balasan ke pantun pembuka itu.
  final String? parentId;

  static const _hints = [
    'Baris 1 (pembayang)',
    'Baris 2 (pembayang)',
    'Baris 3 (isi)',
    'Baris 4 (isi)',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controllers = List.generate(4, (_) => useTextEditingController());
    final focusNodes = List.generate(4, (_) => useFocusNode());
    final submitting = useState(false);

    useEffect(() {
      unawaited(
        AnalyticsService.instance.logPantunComposeOpen(
          isReply: parentId != null,
        ),
      );
      return null;
    }, const []);

    // Cek live: nilai controller dibaca saat rebuild (hook memo berganti
    // tiap frame karena kita rebuild via listenable di bawah).
    final tick = useState(0);
    for (final c in controllers) {
      useEffect(() {
        void listener() => tick.value++;
        c.addListener(listener);
        return () => c.removeListener(listener);
      }, [c]);
    }
    final lines = controllers.map((c) => c.text.trim()).toList();
    final allFilled = lines.every((l) => l.isNotEmpty);
    // Skema rima tidak dipilih user: app yang cari (ABAB lalu AAAA).
    final scheme = allFilled ? pickRhymeScheme(lines) : null;
    final check = scheme == null
        ? (allFilled ? detectRhyme(lines, 'ABAB') : null)
        : detectRhyme(lines, scheme);
    final canSubmit = scheme != null && !submitting.value;

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(parentId == null ? l10n.pantunWrite : l10n.pantunReply),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      footer: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: FButton(
          onPress: canSubmit
              ? () => submit(context, ref, lines, scheme, submitting)
              : null,
          child: submitting.value
              ? const FCircularProgress(size: .sm)
              : Text(l10n.pantunSend),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          const Gap(16),
          for (var i = 0; i < 4; i++) ...[
            FTextField(
              control: FTextFieldControl.managed(controller: controllers[i]),
              focusNode: focusNodes[i],
              hint: _hints[i],
              // Auto-wrap: baris panjang naik ke baris baru (maks 3) supaya
              // keempat baris pantun terbaca utuh saat menyusun.
              maxLines: 3,
              minLines: 1,
              textInputAction: i < 3
                  ? TextInputAction.next
                  : TextInputAction.done,
            ),
            const Gap(12),
          ],
          const Gap(8),
          _RhymeStatus(check: check, allFilled: allFilled, scheme: scheme),
        ],
      ),
    );
  }

  Future<void> submit(
    BuildContext context,
    WidgetRef ref,
    List<String> lines,
    String? scheme,
    ValueNotifier<bool> submitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    final auth = await ref.read(authStatusProvider.future);
    if (!auth.isAuth) {
      if (context.mounted) {
        await showAppErrorSheet(
          context,
          message: l10n.pantunReplyLoginRequired,
        );
      }
      return;
    }
    submitting.value = true;
    try {
      final api = ref.read(pantunApiProvider);
      // rhymeScheme null = biarkan server yang deteksi (ABAB/AAAA).
      final row = parentId == null
          ? await api.create(lines: lines, rhymeScheme: scheme)
          : await api.createReply(
              parentId: parentId!,
              lines: lines,
              rhymeScheme: scheme,
            );
      unawaited(
        AnalyticsService.instance.logPantunSubmit(isReply: parentId != null),
      );
      if (context.mounted) {
        ref.invalidate(pantunFeedProvider);
        if (parentId != null) ref.invalidate(pantunDetailProvider(parentId!));
        context.pop(row);
      }
    } on PantunFailure catch (e) {
      if (context.mounted) await showAppErrorSheet(context, message: e.message);
    } catch (_) {
      if (context.mounted) {
        await showAppErrorSheet(context, message: l10n.pantunSendFailed);
      }
    } finally {
      submitting.value = false;
    }
  }
}

class _RhymeStatus extends StatelessWidget {
  const _RhymeStatus({
    required this.check,
    required this.allFilled,
    this.scheme,
  });

  final RhymeCheckResult? check;
  final bool allFilled;

  /// Skema yang terdeteksi otomatis; null = belum ada yang cocok.
  final String? scheme;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    if (!allFilled) {
      return Text(
        l10n.pantunComposeIncomplete,
        style: theme.typography.body.sm.copyWith(
          color: theme.colors.mutedForeground,
        ),
      );
    }
    return switch (check) {
      RhymeOk(:final warning) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FBadge(
            variant: FBadgeVariant.primary,
            child: Text(
              scheme == null ? 'Pola rima cocok' : 'Pola rima $scheme cocok',
            ),
          ),
          if (warning != null) ...[
            const Gap(6),
            Text(
              warning,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.primary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
      RhymeMismatch(:final pairs) => FBadge(
        variant: FBadgeVariant.destructive,
        child: Text(
          pairs.map((p) => 'Baris ${p.$1} & ${p.$2} belum berima').join('; '),
        ),
      ),
      RhymeLastWordUndetected(:final lineIndex) => FBadge(
        variant: FBadgeVariant.destructive,
        child: Text(
          'Kata akhir baris ${lineIndex + 1} tidak terdeteksi. Perbaiki ya.',
        ),
      ),
      null => const SizedBox.shrink(),
    };
  }
}
