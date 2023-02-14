// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TaskViewFilter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskViewFilter _$TaskViewFilterFromJson(Map<String, dynamic> json) {
  return TaskViewFilter(
    _$enumDecodeNullable(_$OperandEnumMap, json['operand']),
    json['defaultValue'] as bool,
  )..duration = json['duration'] == null
      ? null
      : Duration(microseconds: json['duration'] as int);
}

Map<String, dynamic> _$TaskViewFilterToJson(TaskViewFilter instance) =>
    <String, dynamic>{
      'operand': _$OperandEnumMap[instance.operand],
      'duration': instance.duration?.inMicroseconds,
      'defaultValue': instance.defaultValue,
    };

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

const _$OperandEnumMap = {
  Operand.lessThan: 'lessThan',
  Operand.lessThanEqual: 'lessThanEqual',
  Operand.equal: 'equal',
  Operand.greaterThanEqual: 'greaterThanEqual',
  Operand.greaterThan: 'greaterThan',
};
