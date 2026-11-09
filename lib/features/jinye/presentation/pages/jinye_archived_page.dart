import 'package:dio/dio.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../data/jinye_providers.dart';
import '../../domain/jinye_models.dart';
import '../../jinye_router.dart';

/// Daftar Jinye arsip milik user login.
class JinyeArchivedPage extends ConsumerStatefulWidget {
  const JinyeArchivedPage({super.key});

  @override
  ConsumerState<JinyeArchivedPage> createState() => _JinyeArchivedPageState();
}

class _JinyeArchivedPageState extends ConsumerState<JinyeArchivedPage> {
  final _items = <JinyeItem>[];
  String? _cursor;
  var _loading = true;
  var _loadingMore = false;
  var _hasMore = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({required bool reset}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      if (_loadingMore || !_hasMore) return;
      setState(() => _loadingMore = true);
    }
    try {
      final page = await ref.read(jinyeRepositoryProvider).listArchived(
            cursor: reset ? null : _cursor,
          );
      if (!mounted) return;
      setState(() {
        if (reset) _items.clear();
        _items.addAll(page.items);
        _cursor = page.nextCursor;
        _hasMore = page.nextCursor != null;
        _loading = false;
        _loadingMore = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = e;
      });
    }
  }

  Future<void> _unarchive(JinyeItem item) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(jinyeRepositoryProvider).unarchive(item.id);
      if (!mounted) return;
      setState(() => _items.removeWhere((e) => e.id == item.id));
      showFToast(context: context, title: Text(l10n.jinyeUnarchiveSuccess));
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message']
          : null;
      await showAppErrorSheet(
        context,
        message: msg is String && msg.isNotEmpty
            ? msg
            : l10n.jinyeUnarchiveFailed,
      );
    } catch (_) {
      if (!mounted) return;
      await showAppErrorSheet(context, message: l10n.jinyeUnarchiveFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;

    return FScaffold(
      header: FHeader.nested(
        title: Text(l10n.jinyeArchivedTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/'),
          ),
        ],
      ),
      child: _loading
          ? const Center(child: FCircularProgress())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.jinyeArchivedLoadFailed),
                        const Gap(12),
                        FButton(
                          onPress: () => _load(reset: true),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  ),
                )
              : _items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.jinyeArchivedEmpty,
                          textAlign: TextAlign.center,
                          style: theme.typography.body.md.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _load(reset: true),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: _items.length + (_hasMore ? 1 : 0),
                        separatorBuilder: (_, _) => const Gap(8),
                        itemBuilder: (context, index) {
                          if (index >= _items.length) {
                            if (!_loadingMore) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _load(reset: false);
                              });
                            }
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: FCircularProgress()),
                            );
                          }
                          final item = _items[index];
                          final preview = item.body.trim().isNotEmpty
                              ? item.body.trim()
                              : item.hasAudio
                                  ? l10n.jinyePreviewVoiceOnly
                                  : item.images.isNotEmpty
                                      ? l10n.jinyePreviewPhotoOnly
                                      : l10n.jinyePreviewEmpty;
                          return FTile(
                            title: Text(
                              preview,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              formatDateTimeIso(
                                item.createdAt.toIso8601String(),
                              ),
                            ),
                            onPress: () => context.push(
                              JinyeRouter.detailPath(item.id),
                            ),
                            suffix: FButton(
                              variant: FButtonVariant.ghost,
                              onPress: () => _unarchive(item),
                              child: Text(l10n.jinyeUnarchiveAction),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
