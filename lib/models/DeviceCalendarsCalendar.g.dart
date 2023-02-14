// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DeviceCalendarsCalendar.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceCalendarsCalendar _$DeviceCalendarsCalendarFromJson(
    Map<String, dynamic> json) {
  return DeviceCalendarsCalendar()
    ..selected = json['selected'] as bool
    ..title = json['title'] as String
    ..id = json['id'] as String;
}

Map<String, dynamic> _$DeviceCalendarsCalendarToJson(
        DeviceCalendarsCalendar instance) =>
    <String, dynamic>{
      'selected': instance.selected,
      'title': instance.title,
      'id': instance.id,
    };
