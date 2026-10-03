import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/bookmark/data/models/bookmark_item_dto.dart';
import 'package:sambasku_mobile/features/bookmark/data/models/toggle_bookmark_response_dto.dart';

/// Fixture snapshot lokal.
void main() {
  Map<String, dynamic> loadFixture(String name) {
    final file = File('test/fixtures/json/bookmark/$name');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  test('toggle-bookmark.200.json → ToggleBookmarkResponseDto (pasang)', () {
    final json = loadFixture('toggle-bookmark.200.json');
    final dto =
        ToggleBookmarkResponseDto.fromJson(json['data'] as Map<String, dynamic>);

    expect(dto.wordId, '01JDWORDMAKATN000000000000');
    expect(dto.isBookmarked, isTrue);
    expect(dto.bookmarkedAt, '2026-09-20T03:00:00.000Z');
  });

  test('toggle-bookmark.200.removed.json → is_bookmarked false + null', () {
    final json = loadFixture('toggle-bookmark.200.removed.json');
    final dto =
        ToggleBookmarkResponseDto.fromJson(json['data'] as Map<String, dynamic>);

    expect(dto.isBookmarked, isFalse);
    expect(dto.bookmarkedAt, isNull);
  });

  test('toggle-bookmark.404.json → envelope error WORD_NOT_FOUND', () {
    final json = loadFixture('toggle-bookmark.404.json');

    expect(json['success'], isFalse);
    expect(json['error_code'], 'WORD_NOT_FOUND');
  });

  test('my-bookmarks.200.json → daftar BookmarkItemDto + meta cursor', () {
    final json = loadFixture('my-bookmarks.200.json');
    final items = (json['data'] as List).cast<Map<String, dynamic>>();
    final dtos = items.map(BookmarkItemDto.fromJson).toList();

    expect(dtos, hasLength(2));
    expect(dtos[0].wordId, '01JDWORDMAKATN000000000000');
    expect(dtos[0].bookmarkedAt, '2026-09-20T03:00:00.000Z');
    expect(dtos[0].word.id, '01JDWORDMAKATN000000000000');
    expect(dtos[0].word.lemma, 'makatn');
    expect(dtos[0].word.wordType, 'word');
    expect(dtos[0].word.isVerified, isTrue);
    expect(dtos[1].word.lemma, 'minum');
    expect(dtos[1].word.isVerified, isFalse);

    final meta = json['meta'] as Map<String, dynamic>;
    expect(meta['limit'], 20);
    expect(meta['next_cursor'], isNull);
    expect(meta['has_more'], isFalse);
  });
}
