import 'dart:async';

import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../user_profile/domain/entities/public_profile.dart';
import '../../../user_profile/domain/providers/user_profile_domain_providers.dart';

/// Bottom sheet cari + pilih username teman (referral Baleho).
///
/// Styling seragam dengan `showBalehoEntitySearchSheet`.
Future<MentionSuggestion?> showBalehoReferralSearchSheet(
  BuildContext context, {
  String initialQuery = '',
}) {
  final container = ProviderScope.containerOf(context);
  return showModalBottomSheet<MentionSuggestion>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    builder: (_) => UncontrolledProviderScope(
      container: container,
      child: _BalehoReferralSearchBody(initialQuery: initialQuery),
    ),
  );
}

class _BalehoReferralSearchBody extends ConsumerStatefulWidget {
  const _BalehoReferralSearchBody({this.initialQuery = ''});

  final String initialQuery;

  @override
  ConsumerState<_BalehoReferralSearchBody> createState() =>
      _BalehoReferralSearchBodyState();
}

class _BalehoReferralSearchBodyState
    extends ConsumerState<_BalehoReferralSearchBody> {
  late final TextEditingController _queryCtrl;
  Timer? _debounce;
  var _seq = 0;
  var _loading = false;
  var _searched = false;
  var _failed = false;
  List<MentionSuggestion> _hits = const [];

  @override
  void initState() {
    super.initState();
    _queryCtrl = TextEditingController(text: widget.initialQuery.trim());
    _queryCtrl.addListener(_onQueryChanged);
    if (_queryCtrl.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _search());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryCtrl.removeListener(_onQueryChanged);
    _queryCtrl.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _search);
  }

  double _sheetHeight(BuildContext context) {
    final media = MediaQuery.of(context);
    final available = media.size.height - media.viewInsets.bottom;
    if (available <= 0) return 0;
    final target = available * 0.78;
    final minH = available < 320 ? available : 300.0;
    return target.clamp(minH, available);
  }

  Future<void> _search() async {
    final raw = _queryCtrl.text.trim();
    final q = raw.startsWith('@') ? raw.substring(1).trim() : raw;
    if (q.isEmpty) {
      ++_seq;
      setState(() {
        _hits = const [];
        _searched = false;
        _loading = false;
        _failed = false;
      });
      return;
    }

    final seq = ++_seq;
    setState(() {
      _loading = true;
      _failed = false;
    });

    final result = await ref.read(suggestMentionsUseCaseProvider).call(q);
    if (!mounted || seq != _seq) return;

    result.match(
      (_) => setState(() {
        _hits = const [];
        _searched = true;
        _loading = false;
        _failed = true;
      }),
      (items) => setState(() {
        _hits = items;
        _searched = true;
        _loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: _sheetHeight(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
              child: Row(
                children: [
                  Icon(
                    FLucideIcons.search,
                    size: 18,
                    color: theme.colors.primary,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      l10n.balehoReferralSearchTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.lg.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(FLucideIcons.x),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FTextField(
                control: FTextFieldControl.managed(controller: _queryCtrl),
                hint: l10n.balehoReferralSearchHint,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmit: (_) {
                  _debounce?.cancel();
                  _search();
                },
                suffixBuilder: _loading
                    ? (context, style, _) => Padding(
                        padding: style.clearButtonPadding,
                        child: const FCircularProgress(size: .sm),
                      )
                    : null,
              ),
            ),
            const Gap(8),
            Expanded(
              child: !_searched && _loading
                  ? const Center(child: FCircularProgress())
                  : _failed
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          l10n.balehoReferralSearchFailed,
                          textAlign: TextAlign.center,
                          style: theme.typography.body.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                    )
                  : _hits.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _searched
                              ? l10n.balehoReferralSearchEmpty
                              : l10n.balehoReferralSearchPrompt,
                          textAlign: TextAlign.center,
                          style: theme.typography.body.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _hits.length,
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemBuilder: (context, index) {
                        final user = _hits[index];
                        final name = user.displayName?.trim();
                        final hasName = name != null && name.isNotEmpty;
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(user),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  UserAvatar(
                                    size: 36,
                                    name: hasName ? name : user.username,
                                    imageUrl: user.avatarUrl,
                                  ),
                                  const Gap(10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hasName ? name : '@${user.username}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.typography.body.sm
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        if (hasName) ...[
                                          const Gap(2),
                                          Text(
                                            '@${user.username}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.typography.body.sm
                                                .copyWith(
                                                  color: theme
                                                      .colors
                                                      .mutedForeground,
                                                  fontSize: 12,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const Gap(8),
                                  Icon(
                                    FLucideIcons.chevronRight,
                                    size: 16,
                                    color: theme.colors.mutedForeground,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
