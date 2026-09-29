// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_miss_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SearchMissDto _$SearchMissDtoFromJson(Map<String, dynamic> json) =>
    _SearchMissDto(
      id: json['id'] as String,
      term: json['term'] as String,
      searchIn: json['direction'] as String,
      hitCount: (json['hit_count'] as num).toInt(),
      lastSearchedAt: json['last_searched_at'] == null
          ? null
          : DateTime.parse(json['last_searched_at'] as String),
    );

Map<String, dynamic> _$SearchMissDtoToJson(_SearchMissDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'term': instance.term,
      'direction': instance.searchIn,
      'hit_count': instance.hitCount,
      'last_searched_at': instance.lastSearchedAt?.toIso8601String(),
    };
