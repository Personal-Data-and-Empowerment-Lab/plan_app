// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'EventItem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventItem _$EventItemFromJson(Map<String, dynamic> json) {
  return EventItem(
    json['title'] as String,
    json['id'] as String,
    startTime: json['startTime'] == null
        ? null
        : DateTime.parse(json['startTime'] as String),
    endTime: json['endTime'] == null
        ? null
        : DateTime.parse(json['endTime'] as String),
  );
}

Map<String, dynamic> _$EventItemToJson(EventItem instance) => <String, dynamic>{
      'title': instance.title,
      'id': instance.id,
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
    };
