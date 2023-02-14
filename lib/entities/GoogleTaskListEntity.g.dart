// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GoogleTaskListEntity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleTaskListEntity _$GoogleTaskListEntityFromJson(Map<String, dynamic> json) {
  return GoogleTaskListEntity(
    json['id'] as String,
    json['url'] as String,
    json['title'] as String,
  );
}

Map<String, dynamic> _$GoogleTaskListEntityToJson(
        GoogleTaskListEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'title': instance.title,
    };
