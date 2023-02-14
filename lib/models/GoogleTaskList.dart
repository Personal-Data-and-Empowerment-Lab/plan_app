import 'package:json_annotation/json_annotation.dart';
import 'package:planv3/entities/GoogleTaskListEntity.dart';

part 'GoogleTaskList.g.dart';

@JsonSerializable()
class GoogleTaskList {
  String title = "";
  String id;

  GoogleTaskList(this.title, this.id);

  static GoogleTaskList fromEntity(GoogleTaskListEntity entity) {
    return GoogleTaskList(entity.title, entity.id);
  }

  factory GoogleTaskList.fromJson(Map<String, dynamic> json) =>
      _$GoogleTaskListFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleTaskListToJson(this);
}
