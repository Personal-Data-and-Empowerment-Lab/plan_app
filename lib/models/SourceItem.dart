import 'package:json_annotation/json_annotation.dart';

part 'SourceItem.g.dart';

@JsonSerializable()
class SourceItem {
  SourceItem();

  factory SourceItem.fromJson(Map<String, dynamic> json) =>
      _$SourceItemFromJson(json);

  Map<String, dynamic> toJson() => _$SourceItemToJson(this);
}
