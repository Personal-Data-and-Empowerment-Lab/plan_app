// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GoogleTasksCache.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleTasksCache _$GoogleTasksCacheFromJson(Map<String, dynamic> json) {
  return GoogleTasksCache()
    ..tasks = (json['tasks'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k,
          (e as List)
              ?.map((e) => e == null
                  ? null
                  : GoogleTaskEntity.fromJson(e as Map<String, dynamic>))
              ?.toList()),
    )
    ..taskLists = (json['taskLists'] as List)
        ?.map((e) => e == null
            ? null
            : GoogleTaskListEntity.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..lastUpdated = json['lastUpdated'] == null
        ? null
        : DateTime.parse(json['lastUpdated'] as String);
}

Map<String, dynamic> _$GoogleTasksCacheToJson(GoogleTasksCache instance) =>
    <String, dynamic>{
      'tasks': instance.tasks,
      'taskLists': instance.taskLists,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };
