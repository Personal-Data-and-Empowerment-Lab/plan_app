// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GoogleTaskEntity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleTaskEntity _$GoogleTaskEntityFromJson(Map<String, dynamic> json) {
  return GoogleTaskEntity(
    json['id'] as String,
    json['title'] as String,
    url: json['url'] as String,
    parent: json['parent'] as String,
    position: json['position'] as String,
    notes: json['notes'] as String,
    dueDate: json['dueDate'] == null
        ? null
        : DateTime.parse(json['dueDate'] as String),
    completed: json['completed'] as bool,
    deleted: json['deleted'] as bool,
  );
}

Map<String, dynamic> _$GoogleTaskEntityToJson(GoogleTaskEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
      'parent': instance.parent,
      'position': instance.position,
      'notes': instance.notes,
      'dueDate': instance.dueDate?.toIso8601String(),
      'completed': instance.completed,
      'deleted': instance.deleted,
    };
