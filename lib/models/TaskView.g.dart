// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TaskView.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskView _$TaskViewFromJson(Map<String, dynamic> json) {
  $checkKeys(json, disallowNullValues: const ['id', 'expanded']);
  return TaskView(
    json['title'] as String,
  )
    ..id = json['id'] as String
    ..expanded = json['expanded'] as bool
    ..active = json['active'] as bool
    ..position = json['position'] as int
    ..items = (json['items'] as List)
        ?.map((e) =>
            e == null ? null : TaskItem.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..subSourceIDs =
        (json['subSourceIDs'] as List)?.map((e) => e as String)?.toList()
    ..filters = (json['filters'] as List)
        ?.map((e) => e == null
            ? null
            : TaskViewFilter.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..sortedBy = _$enumDecodeNullable(_$SortTypeEnumMap, json['sortedBy']);
}

Map<String, dynamic> _$TaskViewToJson(TaskView instance) {
  final val = <String, dynamic>{
    'title': instance.title,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('expanded', instance.expanded);
  val['active'] = instance.active;
  val['position'] = instance.position;
  val['items'] = instance.items;
  val['subSourceIDs'] = instance.subSourceIDs;
  val['filters'] = instance.filters;
  val['sortedBy'] = _$SortTypeEnumMap[instance.sortedBy];
  return val;
}

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$SortTypeEnumMap = {
  SortType.DueDate_A: 'DueDate_A',
  SortType.DueDate_D: 'DueDate_D',
  SortType.Alphabetical_A: 'Alphabetical_A',
  SortType.Alphabetical_D: 'Alphabetical_D',
  SortType.Original: 'Original',
};
