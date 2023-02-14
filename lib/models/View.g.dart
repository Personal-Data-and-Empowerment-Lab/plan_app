// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'View.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

View _$ViewFromJson(Map<String, dynamic> json) {
  return View(
    json['title'] as String,
    isExpanded: json['isExpanded'] as bool,
    position: json['position'] as int,
    items: (json['items'] as List)
        ?.map((e) =>
            e == null ? null : SourceItem.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    isEnabled: json['isEnabled'] as bool,
    sources: (json['sources'] as List)?.map((e) => e as String)?.toList(),
    filters: (json['filters'] as List)
        ?.map((e) =>
            e == null ? null : ViewFilter.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ViewToJson(View instance) => <String, dynamic>{
      'title': instance.title,
      'isExpanded': instance.isExpanded,
      'position': instance.position,
      'items': instance.items,
      'isEnabled': instance.isEnabled,
      'sources': instance.sources,
      'filters': instance.filters,
    };
