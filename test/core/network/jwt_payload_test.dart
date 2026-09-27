import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:sambasku_mobile/core/network/jwt_payload.dart';

void main() {
  String tokenWithUsername(String username) {
    final header = base64Url
        .encode(utf8.encode('{"alg":"none","typ":"JWT"}'))
        .replaceAll('=', '');
    final payload = base64Url
        .encode(utf8.encode('{"username":"$username","role":"reviewer"}'))
        .replaceAll('=', '');
    return '$header.$payload.sig';
  }

  test('usernameFromAccessToken membaca klaim username', () {
    expect(
      usernameFromAccessToken(tokenWithUsername('ibnul-mutaki')),
      'ibnul-mutaki',
    );
  });

  test('usernameFromAccessToken null jika token rusak', () {
    expect(usernameFromAccessToken('bukan.jwt'), isNull);
    expect(usernameFromAccessToken(null), isNull);
    expect(usernameFromAccessToken(''), isNull);
  });
}
