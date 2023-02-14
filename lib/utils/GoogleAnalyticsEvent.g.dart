// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GoogleAnalyticsEvent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleAnalyticsEvent _$GoogleAnalyticsEventFromJson(Map<String, dynamic> json) {
  return GoogleAnalyticsEvent(
    json['name'] as String,
    json['parameters'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$GoogleAnalyticsEventToJson(
        GoogleAnalyticsEvent instance) =>
    <String, dynamic>{
      'name': instance.name,
      'parameters': instance.parameters,
    };
