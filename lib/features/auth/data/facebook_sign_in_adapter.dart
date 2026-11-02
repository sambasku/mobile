import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../../../core/constants/env.dart';
import '../domain/ports/facebook_sign_in_port.dart';
import '../../../core/i18n/l10n.dart';

class FacebookSignInAdapter implements FacebookSignInPort {
  @override
  Future<String?> authenticate() async {
    final appId = Env.facebookAppId?.trim();
    if (appId == null || appId.isEmpty) return null;

    final result = await FacebookAuth.instance.login(
      permissions: const ['email', 'public_profile'],
      loginTracking: LoginTracking.enabled,
    );

    if (result.status == LoginStatus.cancelled) return null;
    if (result.status != LoginStatus.success) {
      throw StateError(l10n.authFacebookUnavailable);
    }
    return result.accessToken?.tokenString;
  }
}
