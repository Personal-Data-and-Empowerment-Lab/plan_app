// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GoogleTasksSource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleTasksSource _$GoogleTasksSourceFromJson(Map<String, dynamic> json) {
  $checkKeys(json, disallowNullValues: const [
    'isSetUp',
    'isVisible',
    'isSyncing',
    'isSettingUp',
    'position'
  ]);
  return GoogleTasksSource()
    ..title = json['title'] as String
    ..id = json['id'] as String
    ..expanded = json['expanded'] as bool
    ..lists = (json['lists'] as List)
        ?.map((e) => e == null
            ? null
            : GoogleTaskList.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..views = (json['views'] as List)
        ?.map((e) =>
            e == null ? null : TaskView.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..dateUpdatedFor = json['dateUpdatedFor'] == null
        ? null
        : DateTime.parse(json['dateUpdatedFor'] as String)
    ..isSetUp = json['isSetUp'] as bool ?? false
    ..primaryAccountInfo = json['primaryAccountInfo'] as String
    ..lastUpdated = json['lastUpdated'] == null
        ? null
        : DateTime.parse(json['lastUpdated'] as String)
    ..isVisible = json['isVisible'] as bool ?? true
    ..isSyncing = json['isSyncing'] as bool ?? false
    ..isSettingUp = json['isSettingUp'] as bool ?? false
    ..position = json['position'] as int ?? 1;
}

Map<String, dynamic> _$GoogleTasksSourceToJson(GoogleTasksSource instance) {
  final val = <String, dynamic>{
    'title': instance.title,
    'id': instance.id,
    'expanded': instance.expanded,
    'lists': instance.lists,
    'views': instance.views,
    'dateUpdatedFor': instance.dateUpdatedFor?.toIso8601String(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('isSetUp', instance.isSetUp);
  val['primaryAccountInfo'] = instance.primaryAccountInfo;
  val['lastUpdated'] = instance.lastUpdated?.toIso8601String();
  writeNotNull('isVisible', instance.isVisible);
  writeNotNull('isSyncing', instance.isSyncing);
  writeNotNull('isSettingUp', instance.isSettingUp);
  writeNotNull('position', instance.position);
  return val;
}
