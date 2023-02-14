// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ViewFilter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ViewFilter _$ViewFilterFromJson(Map<String, dynamic> json) {
  return ViewFilter(
    _$enumDecodeNullable(_$OperandEnumMap, json['operand']),
    json['date'] == null ? null : DateTime.parse(json['date'] as String),
  )..duration = json['duration'] == null
      ? null
      : Duration(microseconds: json['duration'] as int);
}

Map<String, dynamic> _$ViewFilterToJson(ViewFilter instance) =>
    <String, dynamic>{
      'operand': _$OperandEnumMap[instance.operand],
      'date': instance.date?.toIso8601String(),
      'duration': instance.duration?.inMicroseconds,
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
