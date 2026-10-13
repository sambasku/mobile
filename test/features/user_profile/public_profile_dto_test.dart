import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/user_profile/data/models/public_profile_dto.dart';

void main() {
  Map<String, dynamic> loadFixture(String name) {
    final file = File('test/fixtures/json/users/$name');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  test('get-public-profile.200.json → PublicProfileDto', () {
    final json = loadFixture('get-public-profile.200.json');
    final dto = PublicProfileDto.fromJson(json['data'] as Map<String, dynamic>);

    expect(dto.username, 'budi');
    expect(dto.role, 'reviewer');
    expect(dto.isVerifier, isTrue);
    expect(dto.joinedAt, '2026-08-01T00:00:00.000Z');
    expect(dto.stats.contributionsApproved, 12);
    expect(dto.stats.wordsApproved, 4);
    expect(dto.stats.correctionsApproved, 8);
    expect(dto.stats.verificationsDone, 34);
  });

  test('get-public-profile.404.json → USER_NOT_FOUND', () {
    final json = loadFixture('get-public-profile.404.json');

    expect(json['success'], isFalse);
    expect(json['error_code'], 'USER_NOT_FOUND');
  });
}
