import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/vote/data/models/my_vote_dto.dart';
import 'package:sambasku_mobile/features/vote/data/models/vote_count_dto.dart';
import 'package:sambasku_mobile/features/vote/data/models/vote_toggle_response_dto.dart';

/// Fixture snapshot lokal.
void main() {
  Map<String, dynamic> loadFixture(String name) {
    final file = File('test/fixtures/json/vote/$name');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  test('toggle-vote.200.json → VoteToggleResponseDto (my_vote 1)', () {
    final json = loadFixture('toggle-vote.200.json');
    final dto = VoteToggleResponseDto.fromJson(json['data'] as Map<String, dynamic>);

    expect(dto.targetType, 'word');
    expect(dto.targetId, '01JDWORDMAKATN0000000000A');
    expect(dto.myVote, 1);
    expect(dto.upvotes, 4);
    expect(dto.downvotes, 1);
  });

  test('toggle-vote.200.toggle-off.json → my_vote null (batal vote)', () {
    final json = loadFixture('toggle-vote.200.toggle-off.json');
    final dto = VoteToggleResponseDto.fromJson(json['data'] as Map<String, dynamic>);

    expect(dto.myVote, isNull);
    expect(dto.upvotes, 3);
    expect(dto.downvotes, 1);
  });

  test('vote-counts.200.json → daftar VoteCountDto', () {
    final json = loadFixture('vote-counts.200.json');
    final items = (json['data'] as List).cast<Map<String, dynamic>>();
    final dtos = items.map(VoteCountDto.fromJson).toList();

    expect(dtos, hasLength(3));
    expect(dtos[0].targetType, 'word');
    expect(dtos[0].targetId, '01JDWORDMAKATN0000000000A');
    expect(dtos[0].upvotes, 4);
    expect(dtos[0].downvotes, 1);
    expect(dtos[1].upvotes, 0);
    expect(dtos[1].downvotes, 0);
  });

  test('my-votes.200.json → daftar MyVoteDto (hanya target yang dipilih)', () {
    final json = loadFixture('my-votes.200.json');
    final items = (json['data'] as List).cast<Map<String, dynamic>>();
    final dtos = items.map(MyVoteDto.fromJson).toList();

    expect(dtos, hasLength(2));
    expect(dtos[0].targetType, 'word');
    expect(dtos[0].value, 1);
    expect(dtos[1].targetType, 'pronunciation');
    expect(dtos[1].value, -1);
  });
}