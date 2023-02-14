// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DeviceCalendarsSource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceCalendarsSource _$DeviceCalendarsSourceFromJson(
    Map<String, dynamic> json) {
  $checkKeys(json, disallowNullValues: const [
    'isSetUp',
    'isVisible',
    'isSyncing',
    'isSettingUp',
    'position'
  ]);
  return DeviceCalendarsSource(
    (json['calendars'] as List)
        ?.map((e) => e == null
            ? null
            : DeviceCalendarsCalendar.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  )
    ..title = json['title'] as String
    ..id = json['id'] as String
    ..expanded = json['expanded'] as bool
    ..events = (json['events'] as List)
        ?.map((e) =>
            e == null ? null : EventItem.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..dateUpdatedFor = json['dateUpdatedFor'] == null
        ? null
        : DateTime.parse(json['dateUpdatedFor'] as String)
    ..lastUpdated = json['lastUpdated'] == null
        ? null
        : DateTime.parse(json['lastUpdated'] as String)
    ..isSetUp = json['isSetUp'] as bool ?? false
    ..isVisible = json['isVisible'] as bool ?? true
    ..isSyncing = json['isSyncing'] as bool ?? false
    ..isSettingUp = json['isSettingUp'] as bool ?? false
    ..position = json['position'] as int ?? 0;
}

Map<String, dynamic> _$DeviceCalendarsSourceToJson(
    DeviceCalendarsSource instance) {
  final val = <String, dynamic>{
    'title': instance.title,
    'id': instance.id,
    'expanded': instance.expanded,
    'events': instance.events,
    'dateUpdatedFor': instance.dateUpdatedFor?.toIso8601String(),
    'lastUpdated': instance.lastUpdated?.toIso8601String(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('isSetUp', instance.isSetUp);
  writeNotNull('isVisible', instance.isVisible);
  writeNotNull('isSyncing', instance.isSyncing);
  writeNotNull('isSettingUp', instance.isSettingUp);
  writeNotNull('position', instance.position);
  val['calendars'] = instance.calendars;
  return val;
}
