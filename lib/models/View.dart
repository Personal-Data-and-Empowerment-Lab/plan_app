import 'package:planv3/models/SourceItem.dart';
import 'package:planv3/models/ViewFilter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'View.g.dart';

@JsonSerializable()
class View {
  String title;
  bool isExpanded;
  int position;
  List<SourceItem> items;
  bool isEnabled;
  List<String> sources;
  List<ViewFilter> filters;

  View(this.title,
      {this.isExpanded,
      this.position,
      this.items,
      this.isEnabled,
      this.sources,
      this.filters});

  factory View.fromJson(Map<String, dynamic> json) => _$ViewFromJson(json);

  Map<String, dynamic> toJson() => _$ViewToJson(this);
}
