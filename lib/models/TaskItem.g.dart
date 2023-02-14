// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TaskItem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskItem _$TaskItemFromJson(Map<String, dynamic> json) {
  return TaskItem(
    json['title'] as String,
    json['id'] as String,
    dueDate: json['dueDate'] == null
        ? null
        : DateTime.parse(json['dueDate'] as String),
  );
}

Map<String, dynamic> _$TaskItemToJson(TaskItem instance) => <String, dynamic>{
      'title': instance.title,
      'id': instance.id,
      'dueDate': instance.dueDate?.toIso8601String(),
    };
