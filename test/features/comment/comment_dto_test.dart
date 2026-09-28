import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/comment/data/models/comment_dto.dart';

/// Fixture dari docs/json/comment (repo mandiri, snapshot lokal).
void main() {
  Map<String, dynamic> loadFixture(String name) {
    final file = File('test/fixtures/json/comment/$name');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  test('list-comments.200.json → CommentDto dengan vote counts', () {
    final json = loadFixture('list-comments.200.json');
    final items = (json['data'] as List).cast<Map<String, dynamic>>();
    final dtos = items.map(CommentDto.fromJson).toList();

    expect(dtos, hasLength(2));

    expect(dtos[0].id, '01JDCOMMENTMAKATN00000000A');
    expect(dtos[0].wordId, '01JDWORDMAKATN0000000000A');
    expect(dtos[0].userId, '01JDCONTRIBUTOR000000000');
    expect(dtos[0].username, 'kontributor');
    expect(dtos[0].displayName, 'Kontributor');
    expect(dtos[0].avatarUrl, isNull);
    expect(dtos[0].isVerifier, isFalse);
    expect(dtos[0].body, contains('Sambas'));
    expect(dtos[0].upvotes, 3);
    expect(dtos[0].downvotes, 0);
    // list item tidak membawa status → null
    expect(dtos[0].status, isNull);

    expect(dtos[1].username, isNull);
    expect(dtos[1].isVerifier, isFalse);
    expect(dtos[1].upvotes, 0);
    expect(dtos[1].downvotes, 1);
  });

  test('create-comment.201.json → CommentDto status published, counts 0',
      () {
    final json = loadFixture('create-comment.201.json');
    final dto = CommentDto.fromJson(json['data'] as Map<String, dynamic>);

    expect(dto.status, 'published');
    expect(dto.isVerifier, isFalse);
    // response create tidak membawa count → default 0
    expect(dto.upvotes, 0);
    expect(dto.downvotes, 0);
    expect(dto.createdAt, '2026-09-18T10:00:00.000Z');
  });
}