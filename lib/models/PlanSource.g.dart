// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PlanSource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanSource _$PlanSourceFromJson(Map<String, dynamic> json) {
  return PlanSource(
    json['title'] as String,
    iconPath: json['iconPath'] as String,
    isEnabled: json['isEnabled'] as bool,
    isSetUp: json['isSetUp'] as bool,
    views: (json['views'] as List)
        ?.map(
            (e) => e == null ? null : View.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  )..accountInfo = json['accountInfo'] == null
      ? null
      : AccountInfo.fromJson(json['accountInfo'] as Map<String, dynamic>);
}

Map<String, dynamic> _$PlanSourceToJson(PlanSource instance) =>
    <String, dynamic>{
      'title': instance.title,
      'iconPath': instance.iconPath,
      'isEnabled': instance.isEnabled,
      'isSetUp': instance.isSetUp,
      'views': instance.views,
      'accountInfo': instance.accountInfo,
    };
