import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';

/// Pastikan user login sebelum aksi tulis ensiklopedia.
/// Return true bila sudah auth; false bila sheet dibatalkan / diarahkan login.
Future<bool> ensureEncyclopediaAuth(
  BuildContext context,
  WidgetRef ref, {
  required String body,
}) async {
  final authed = ref.read(authStatusProvider).value?.isAuth == true;
  if (authed) return true;
  final l10n = AppLocalizations.of(context);
  final goLogin = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      top: false,
      child: FTileGroup(
        children: [
          FTile(
            title: Text(l10n.encyclopediaLoginFirstTitle),
            subtitle: Text(body),
          ),
          FTile(
            title: Text(l10n.authLoginAction),
            onPress: () => Navigator.pop(ctx, true),
          ),
          FTile(
            title: Text(l10n.authLater),
            onPress: () => Navigator.pop(ctx, false),
          ),
        ],
      ),
    ),
  );
  if (goLogin == true && context.mounted) {
    context.push('/login');
  }
  return false;
}
